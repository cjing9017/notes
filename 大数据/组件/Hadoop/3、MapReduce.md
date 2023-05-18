# 一、MapReduce概述

## 1.1 MapReduce优缺点

- 优点
  - `MapReduce 易于编程`：它简单的实现一些接口，就可以完成一个分布式程序，这个分布式程序可以分布到大量廉价的PC机器上运行。也就是说你写一个分布式程序，跟写一个简单的串行程序是一模一样的。就是因为这个特点使得MapReduce编程变得非常流行
  - `良好的扩展性`：当你的计算资源不能得到满足的时候，你可以通过简单的增加机器来扩展它的计算能力
  - `高容错性`：MapReduce设计的初衷就是使程序能够部署在廉价的PC机器上，这就要求它具有很高的容错性。比如其中一台机器挂了，它可以把上面的计算任务转移到另外一个节点上运行，不至于这个任务运行失败，而且这个过程不需要人工参与，而完全是由Hadoop内部完成的
  - `适合PB级以上海量数据的离线处理`：可以实现上千台服务器集群并发工作，提高数据处理能力
- 缺点
  - `不擅长实时计算`：MapReduce无法像MySQL一样，在毫秒或者秒级内返回结果
  - `不擅长流式计算`：流式计算的输入数据是动态的，而MapReduce的输入数据集是静态的，不能动态变化。这是因为MapReduce自身的设计特点决定了数据源必须是静态的
  - `不擅长DAG（有向图）计算`：多个应用程序存在依赖关系，后一个应用程序的输入为前一个的输出。在这种情况下，MapReduce并不是不能做，而是使用后，每个MapReduce作业的输出结果都会写入到磁盘，会造成大量的磁盘IO，导致性能非常的低下

## 1.2 MapReduce核心思想

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171730330.png)

- 分布式的运算程序往往需要分成两个阶段：
  - 第一个阶段的MapTask并发实例，完全并行运行，互不相干
  - 第二个阶段的ReduceTask并发实例，互不相干，但是他们的数据依赖于上一个阶段的所有MapTask并发实例的输出
- MapReduce编程模型只能包含一个Map阶段和一个Reduce阶段，如果用户的业务逻辑非常复杂，那就只能多个MapReduce程序，串行运行

## 1.3 MapReduce进程

一个完整的MapReduce程序在分布式运行时有三类实例进程：

- MrAppMaster：负责整个程序的过程调度及状态协调
- MapTask：负责Map阶段多的整个数据处理流程
- ReduceTask：负责Reduce阶段的整个数据处理流程

## 1.4 常用数据序列化类型

| Java类型 | Hadoop Writable类型 |
| -------- | ------------------- |
| Boolean  | BooleanWritable     |
| Byte     | ByteWritable        |
| Int      | IntWritable         |
| Float    | FloatWritable       |
| Long     | LongWritable        |
| Double   | DoubleWritable      |
| String   | Text                |
| Map      | MapWritable         |
| Array    | ArrayWritable       |

# 二、MapReduce框架原理

## 2.1 InputFormat数据输入

### 2.1.1 数据切片与MapTask并行度决定机制

> MapTask的并行度决定Map阶段任务处理并发度，进而影响整个Job的处理速度

- **数据块：**Block是HDFS物理上把数据分成一块一块
- **数据切片：**数据切片只是在逻辑上对输入进行分片，并不会在磁盘上将其切分成片进行存储

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171732125.png)

MapTask并行度决定机制

### 2.1.2 Job提交流程

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171732389.png)

Job提交流程源码分析

### 2.1.3 FileInputFormat切片机制

1. 程序先找到你数据存储的目录
2. 开始遍历处理（规划切片）目录下的每一个文件
3. 遍历第一个文件ss.txt
   1. 获取文件大小fs.sizeOf(ss.txt)
   2. 计算切片大小：computeSplitSize(Math.max(minSize,Math.min(maxSize,blocksize)))
   3. 默认情况下，切片大小=blocksize
   4. 开始切，形成第1个切片：ss.txt—0:128M 第2个切片ss.txt—128:256M 第3个切片ss.txt—256M:300M（每次切片时，都要判断切完剩下的部分是否大于块的1.1倍，不大于1.1倍就划分一块切片）
   5. 将切片信息写到一个切片规划文件中
   6. 整个切片的核心过程在getSplit()方法中完成
   7. InputSplit只记录了切片的元数据信息，比如起始位置、长度以及所在的节点列表等
4. 提交切片规划文件到YARN上，YARN上的MrAppMaster就可以根据切片规划文件计算开启MapTask个数

- 源码中计算切片大小的公式
  - Math.max(minSize, Math.min(maxSize, blockSize))
  - mapreduce.input.fileinputformat.split.minsize=1 默认值为1
  - mapreduce.input.fileinputformat.split.maxsize= Long.MAXValue 默认值Long.MAXValue
  - 因此，默认情况下，切片大小=blocksize
- 切片大小设置
  - maxsize（切片最大值）：参数如果调得比blockSize小，则会让切片变小，而且就等于配置的这个参数的值
  - minsize（切片最小值）：参数调的比blockSize大，则可以让切片变得比blockSize还大

## 2.2 Shuffle内部机制

### 2.2.1 Partition分区

> ReduceTask的数量和分区的数量没有直接关系，ReduceTask的数量是我们在驱动类中手动设置的，通过job.setNumReduceTasks(num)设置ReduceTask的数量

对于默认的Partitioner分区来说，默认的分区是根据key的hashcode对ReduceTask的个数取模得到的，用户没法控制哪个key存储到那个分区，源码如下：

```java
public class HashPartitioner<K, V> extends Partitioner<K, V> {

  public int getPartition(K key, V value, int numReduceTasks) {
    return (key.hashCode() & Integer.MAX_VALUE) % numReduceTasks;
  }
}
```

- 说明
  - 如果是用户自定义分区类（控制哪些key存放到哪个分区），需要继承Partitioner，重写getPartition()方法
  - 在利用key的hashcode对numReduceTasks取模之前，先将hashcode和Integer.MAX_VALUE进行按位与运算的原因在于，如果此时hashcode的值为负的，那么直接进行取模运算就会导致出错，因为分区号的取值范围为[0, numReduceTasks)
- 分区总结
  - 如果ReduceTask的数量 > getPartition的结果数，则会多产生几个空的输出文件part-r-000xx
  - 如果1< ReduceTask的数量 < getPartition的结果数，则有一部分分区数据无处安放，会Exception
  - 如果ReduceTask的数量=1，则不管MapTask端输出多少个分区文件，最终结果都交给这一个ReduceTask，最终也就只会产生一个结果文件 part-r-00000
  - 分区号必须从零开始，逐一累加

### 2.2.2 WritableComparable排序

- 对于MapTask：它会将处理的结果暂时放到环形缓冲区中，当环形缓冲区使用率达到一定阈值后，再对缓冲区中的数据进行一次快速排序，并将这些有序数据溢写到磁盘上，而当数据处理完毕后，它会对磁盘上所有文件进行归并排序
- 对于ReduceTask：它从每个MapTask上远程拷贝相应的数据文件，如果文件大小超过一定阈值，则溢写磁盘上，否则存储在内存中。如果磁盘上文件数目达到一定阈值，则进行一次归并排序以生成一个更大文件；如果内存中文件大小或者数目超过一定阈值，则进行一次合并后将数据溢写到磁盘上。当所有数据拷贝完毕后，ReduceTask统一对内存和磁盘上的所有数据进行一次归并排序
- 排序的分类
  - 部分排序
  - 全排序
  - 辅助排序
  - 二次排序

### 2.2.3 Combiner合并

- Combiner是MR程序中Mapper和Reducer之外的一种组件
- Combiner组件的父类就是Reducer
- Combiner和Reducer的区别在于运行的位置
  - Combiner是在每一个MapTask所在的节点运行
  - Reducer是接受全局所有Mapper的输出结果
- Combiner的意义就是对每一个MapTask的输出进行汇总，以减小网络传输量
- Combiner能够应用的前提就是不能影响最终的业务逻辑，而且，Combiner的输出kv应该和Reducer的输入kv类型要对应起来
- Combiner应用于Mapper到Reducer之间的三次排序中的前两次排序之后
  - 在map方法将数据写入缓冲区溢出后，进行了分区排序，此时每个分区中可能会有相同的键，因此，进行了一次Combiner合并
  - 对多个溢出文件进行归并排序后，相同分区合并后可能会有相同的键，因此，进行了一次Combiner合并

## 2.3 Shuffle工作机制

![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171732536.png)

1. map方法将<k, v>数据写入到环形缓冲区中，在进入缓冲区的时候会获得一个分区号p
2. 这里的分区和排序也是一个二次排序的过程
3. 当环形缓冲区中的使用率达到一个阈值，此时会将数据溢写到磁盘中
4. 在数据溢写之前
   1. 根据之前获取的分区号p进行分区
   2. 对每个分区的数据进行排序（快速排序）
   3. 并且利用Combiner对分区内的数据进行合并
5. 最终会得到多个溢写的文件
6. 将多个溢写的文件数据利用归并排序进行合并，同时再次对同一个分区的数据利用Combiner进行合并，最终落盘
7. ReduceTask根据自己的分区号，去各个MapTask机器上取相应的结果分区数据
8. ReduceTask会取到同一个分区的来自不同MapTask的结果文件，ReduceTask会将这些文件利用归并排序进行合并
9. 最终，我们利用排序，则相同的key必定是相邻的，可以根据相邻的key是否相同来判断是否为同一分组

- 环形缓冲区（逻辑上）
  - 大小默认100M
  - 设计成环形的原因：没有固定的头尾，可以从任意的位置进行写
  - 写数据的过程：
    - 从任意一点开始，一边写kv，另外一边写索引
    - 当环形缓冲区利用了80%时，从剩余的20%中找到任意一个位置，同样的一边写kv，另外一边写索引
  - 二次排序就发生在环形缓冲区当中，交换的是索引而不是kv值来达到排序的目的

## 2.4 MapTask工作机制

![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171733133.png)

MapReduce详细工作流程（一）

- 首先，有一个输入文件要进行处理
- 那么，文件处理的第一步，在客户端完成切片工作，生成一些相应信息，比如说切片信息、JAR包本身和我们的配置信息，这三个文件放在提交Job的临时目录里面，这个东西是要给Yarn看的
- Yarn拿到这些信息，根据切片信息计算出MapTask启动的数量（也就是说MapTask的并行度是由切片数量决定的）
- MapTask拿到自己的切片之后，生成一个InputFormat对象，然后调用它的getRecordReader()方法获取一个RecordReader，这个RecordReader就负责把这个切片读成<k, v>
- 然后，将这个<k, v>值输给了我们的Mappper的map()方法
- map()方法中就是我们所写的处理逻辑，经过处理以后生成的<k, v>值被收集到了一个叫做outputCollector对象中（并且这里一定是以序列化的方式收集）
- outputCollector把这些数据收集到了一个叫环形缓冲区的地方，这个环形缓冲区存储数据的时候是在任意一个位置找一个点开始，从一边写数据，另外一边写索引，一直写到80%满的时候停止，从剩余的20%中再找个位置开始写；
- 那么这之前的80%区域开始发生溢写过程，首先会发生一次全排序，这个排序过程是一个二次排序，首先按照分区排序，分区内按照key排序，于是这个结果就是分区且分区内有序，然后把这个结果以文件形式写入到磁盘中
- 那么多次溢写就会生成多个的溢写文件
- 最后，MapTask利用归并排序，将这些文件合并为一个文件，这个文件的特点是分区且分区内有序，到此为止MapTask的任务就结束了
- 假如，中间启用了Combiner，那么Combiner起效的两次位置：
  - 第一次：溢写阶段在分区且分区内排好序以后，在落盘之前启用了一次Combiner，这个时候落盘后的文件的特点是分区内重复的key被合并了
  - 第二次：多个溢写的文件，在合并成一个文件的过程中会启用一次Combiner
- Combiner启用的目的就是为了减少MapTask的输出

## 2.5 ReduceTask工作机制

![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171733493.png)

Map Reduce详细工作流程（二）

- 多个MapTask都会有这样的一个分区且分区内有序的文件，往后就是Reduce阶段
- 此时，会启动我们设置好数量的ReduceTask，一般我们设置的数量和分区的数量是一样的
- 每个ReduceTask都从所有MapTask中下载相应的分区的数据（即ReduceTask1会下载分区1的数据，ReduceTask2会下载分区2的数据）
- 下载过来以后，每一个ReduceTask中的数据都是对应的同一个分区的数据，那么多个来自MapTask的文件会通过归并排序合并为一个文件，这个文件就是我们的Reducer的输入文件
- 每次ReduceTask将同一组（这里的分组规则我们可以自定义）的数据输入给Reducer中的reduce方法
- 经过reduce()方法处理的数据，最终会走到OutputFormat，然后再走到RecordWriter，RecordWriter调用write方法写入到磁盘中
- 分区和分组
  - 分区发生在MapTask阶段，目的是为了告诉我们的数据应该去往哪一个ReduceTask
  - 分组发生在ReduceTask阶段，分组是针对同一个区进行分组，分组的目的是不同组的数据会分批次的进入reduce()方法处理

## 2.6 OutputFormat数据输出

OutputFormat是MapReduce输出的基类，所有实现MapReduce输出都实现了OutputFormat接口，常见的OutputFormat实现类如下：

- TextOutputFormat：
  - 默认的输出格式
  - 它把每条记录写为文本行
  - 它的键和值可以是任意类型，因为TextOutputFormat调用toString()方法把他们转换为字符串
- SequenceFileOutputFormat
  - 将SequenceFileOutputFormat输出作为后续MapReduce任务的输入，这便是一种很好的输出格式，因为它的格式紧凑，很容易被压缩
- 自定义OutputFormat
  - 根据用户需求，自定义实现输出
  - 自定义OutputFormat步骤
    - 自定义一个类继承FileOutputFormat
    - 改写RecordWriter，具体改写输出数据的方法write()

## 2.7 Join的应用

### 2.7.1 Reduce Join

- Map端的主要工作
  - 为来自不同表或文件的key/value对，打标签以区别不同来源的记录
  - 然后利用连接字段作为key，其余部分和新加的标志作为value，最后进行输出
- Reduce端的主要工作
  - 在Reduce端以连接字段作为key的分组已经完成，我们只需要在每个分组中将那些来源不同文件的记录（在Map阶段已经打标志）分开
  - 最后进行合并就可以了

### 2.7.2 Map Join

- 使用场景
  - Map Join适用于一张表十分小（15M以下）、一张表很大的场景
  - 因为Mapper端不能得到全部的数据，所以需要将小表先缓存进内存，于是对于这张很大的表来说，这张小表就是完全可见的
- 优点（在Reduce端处理过多的表，非常容易产生数据倾斜，怎么办？）
  - 因为是在Map端进行Join，所以就没有了Reduce的处理，也就没有了Shuffle这个过程，因此，大大提升了速度，并且没有了数据倾斜的问题
  - 在Map端缓存多张表，提前处理业务逻辑，这样增加Map端业务，减少Reduce端数据的压力，尽可能的减少数据倾斜
- 具体办法：采用DistributedCache
  - 在Mapper的setup阶段，将文件读取到缓存集合中
  - 在驱动函数中加载缓存
    - // 缓存普通文件到Task运行节点
    - job.addCacheFile(new URI("file://e:/cache/pd.txt"));

## 2.8 MapReduce开发总结

- 输入数据接口：InputFormat
  - 默认使用的实现类是：TextInputFormat
  - TextInputFormat：一次读一行文本，然后将该行的起始偏移量作为key，行内容作为value返回
  - KeyValueTextInput：每一行均为一条记录，被分隔符分割为key，value（默认分隔符是tab：\t）
  - NlineInputFormat：按照指定的行数N来划分切片
  - CombineTextInputFormat：可以把多个小文件合并成一个切片处理，提高处理效率
  - 用户还可以自定义InputFormat
- 逻辑处理接口：Mapper
  - 用户根据业务需求实现其中三个方法：
    - map()
    - setup()
    - cleanup()
- Partitioner分区
  - 有默认实现HashPartioner：逻辑是根据key的哈希值和numReduces来返回一个分区号；key.hashCode() & Integer.MAX_VALUE % numReduces
  - 如果业务上有特别的需求，可以自定义分区
- Comparable排序
  - 当我们用自定义的对象作为key来输出时，就必须要实现WritableComparable接口，重写其中的compareTo()方法
  - 部分排序：对最终输出的每一个文件进行内部排序
  - 全排序：对所有数据进行排序，通常只有一个Reduce
  - 二次排序：排序的条件有两个
- Combiner合并
  - Combiner合并可以提高程序执行效率，减少IO传输；但是使用时必须不能影响原有的业务处理结果
- Reduce端分组：GroupingComparator
  - 在Reduce端对key进行分组
  - 应用：在接收的key为bean对象时，想让一个或几个字段相同（全部字段比较不相同）的key进入到同一个reduce方法时，可以采用分组排序
- 逻辑处理接口：Reducer
  - 用户根据业务需求实现其中三个方法：
    - reduce()
    - setup()
    - cleanup()
- 输出数据接口：OutputFormat
  - 默认实现类是TextOutputFormat：将每一个kv对，向目标文本文件输出一行
  - SequenceFileOutputFormat：作为后续MapReduce任务的输入，这是一种好的输出格式，因为它的格式紧凑，很容易被压缩
  - 用户可以自定义OutputFormat

# 三、Hadoop数据压缩

## 3.1 压缩概述

- 压缩技术能够有效减少底层存储系统（HDFS）读写字节数
- 压缩提高了网络带宽和磁盘空间的效率
- 在运行MR程序时，I/O操作、网络数据传输、 Shuffle和Merge要花大量的时间，尤其是数据规模很大和工作负载密集的情况下，因此，使用数据压缩显得非常重要
- 鉴于磁盘I/O和网络带宽是Hadoop的宝贵资源，数据压缩对于节省资源、最小化磁盘I/O和网络传输非常有帮助
- 可以在任意MapReduce阶段启用压缩
- 不过，尽管压缩与解压操作的CPU开销不高，其性能的提升和资源的节省并非没有代价

## 3.2 压缩策略和原则

- 压缩是提高Hadoop运行效率的一种优化策略
- 通过对Mapper、Reducer运行过程的数据进行压缩，以减少磁盘IO，提高MR程序运行速度
- 注意：采用压缩技术减少了磁盘IO，但同时增加了CPU运算负担，所以，压缩特性运用得当能提高性能，但运用不当也可能降低性能
- 压缩基本原则：
  - 运算密集型的job，少用压缩
  - IO密集型的job，多用压缩

## 3.3 MR支持的压缩编码

| 压缩格式 | hadoop自带？ | 算法    | 文件扩展名 | 是否可切分 | 换成压缩格式后，原来的程序是否需要修改 |
| -------- | ------------ | ------- | ---------- | ---------- | -------------------------------------- |
| DEFLATE  | 是，直接使用 | DEFLATE | .deflate   | 否         | 和文本处理一样，不需要修改             |
| Gzip     | 是，直接使用 | DEFLATE | .gz        | 否         | 和文本处理一样，不需要修改             |
| bzip2    | 是，直接使用 | bzip2   | .bz2       | 是         | 和文本处理一样，不需要修改             |
| LZO      | 否，需要安装 | LZO     | .lzo       | 是         | 需要建索引，还需要指定输入格式         |
| Snappy   | 否，需要安装 | Snappy  | .snappy    | 否         | 和文本处理一样，不需要修改             |

## 3.4 压缩的方式

- Gzip压缩
  - 优点：
    - 压缩率比较高，而且压缩/解压速度也比较快
    - Hadoop本身支持，在应用中处理Gzip格式的文件就和直接处理文本一样
    - 大部分Linux系统都自带Gzip命令，使用方便
  - 缺点：不支持Split
  - 应用场景：当每个文件压缩之后在130M以内的（1个块大小内），都可以考虑用Gzip压缩格式，例如说一天或者一个小时的日志压缩成一个Gzip文件
- Bzip2压缩
  - 优点：
    - 支持Split
    - 具有很高的压缩率，比Gzip压缩率都高
    - Hadoop本身自带，使用方便
  - 缺点：压缩/解压速度慢
  - 应用场景：
    - 适合对速度要求不高，但需要较高的压缩率的时候
    - 或者输出之后的数据比较大，处理之后的数据需要压缩存档减少磁盘空间并且以后数据用得比较少的情况
    - 或者对单个很大的文本文件想压缩减少存储空间，同时又需要支持Split，而且兼容之前的应用程序的情况
- Lzo压缩
  - 优点：
    - 压缩/解压速度也比较快，合理的压缩率
    - 支持Split，是Hadoop中最流行的压缩格式
    - 可以在Linux系统下安装lzop命令，使用方便
  - 缺点：
    - 压缩率比Gzip要低一些
    - Hadoop本身不支持，需要安装
    - 在应用中对Lzo格式的文件需要做一些特殊处理（为了支持Split需要建索引，还需要指定InputFormat为Lzo格式）
  - 应用场景：一个很大的文本文件，压缩之后还大于200M以上的可以考虑，而且单个文件越大，Lzo优点越越明显
- Snappy压缩
  - 优点：高速压缩速度和合理的压缩率
  - 缺点：
    - 不支持Split
    - 压缩率比Gzip要低
    - Hadoop本身不支持，需要安装
  - 应用场景：
    - 当MapReduce作业的Map输出的数据比较大的时候，作为Map到Reduce的中间数据的压缩格式
    - 或者作为一个MapReduce作业的输出和另外一个MapReduce作业的输入

## 3.5 压缩位置

![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171734418.png)

# 四、其他

## 4.1 环形缓冲区

![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171734283.png)

- Mapper的输出是数据流（一条数据一条数据输出）
- Reducer的输入是工作流（所有的数据一起输入的）
- Shuffle的过程发生在ReduceTask阶段
- 在Mapper的输出之后发生了一个排序的过程
- 环形缓冲区
  - MapOutputBuffer核心是kvbuffer，是一个字节数组bye[]，被叫做环形缓冲区（默认大小100MB）
  - 环形缓冲区使用方法是逐次输出数据到缓冲区，空间满就溢写spill，注意不能让缓冲区满到不能写入
  - 采用异步的方式，开启两个线程，一个负责写，一个负责溢写