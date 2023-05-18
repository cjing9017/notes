# 一、HDFS的定义

- HDFS（Hadoop Distributed File System），它是一个文件系统，用于存储文件，通过目录树来定位文件
- 其次，它是分布式的，由很多服务器联合起来实现其功能，集群中的服务器有各自的角色
- HDFS的使用场景：
  - 适合一次写入，多次读出的场景，且不支持文件的修改
  - 适合用来做数据分析，并不适合用来做网盘应用

# 二、HDFS的优缺点

- 优点
  - 高容错性：
    - 数据自动保存多个副本，它通过增加副本的形式，提高容错性
    - 某一个副本丢失以后，它可以自动恢复
  - 适合处理大数据：
    - 数据规模：能够处理数据规模达到GB、TB甚至PB级别的数据
    - 文件规模：能够处理百万规模以上的文件数量，数量相当之大
  - 可构建在廉价的机器上，通过多副本机制，提高可靠性
- 缺点
  - 不适合低延时数据访问，比如毫秒级的存储数据，是做不到的
  - 无法高效的对大量小文件进行存储
    - 存储大量小文件的话，它会占用NameNode大量的内存来存储文件目录和块信息，这样是不可取的，因为NameNode的内存总是有限的
    - 小文件存储的寻址时间会超过读取时间，它违反了HDFS的设计目标
  - 不支持并发写入、文件随机修改
    - 一个文件只能有一个写，不允许多个线程同时写
    - 仅支持数据追加，不支持文件的随机修改

# 三、HDFS组成架构

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171726584.png)

- NameNode（nn）：就是Master，它是一个主管、管理者：
  - 管理HDFS的名称空间
  - 配置副本策略
  - 管理数据块（Block）映射信息
  - 处理客户端读写请求
- DataNode：就是Slave，NameNode下达命令，DataNode执行实际的操作
  - 存储实际的数据块
  - 执行数据块的读/写操作
- Client：就是客户端
  - 文件切分，文件上传HDFS的时候，Client将文件切分成一个一个的Block，然后进行上传
  - 与NameNode交互，获取文件的位置信息
  - 与DataNode交互，读取或者写入数据
  - Client提供一些命令来管理HDFS，比如NameNode格式化
  - Client可以通过一些命令来访问HDFS，比如对HDFS增删查改操作
- Secondary NameNode：并非NameNode的热备，当NameNode挂掉的时候，它并不能马上替换NameNode并提供服务
  - 辅助NameNode，分担其工作量，比如定期合并Fsimage和Edits，并推送给NameNode
  - 在紧急情况下，可辅助恢复NameNode

# 四、HDFS文件块大小（重点）

- HDFS中的文件在物理上是分块存储（Block），块的大小可以通过配置参数( `dfs.blocksize`)来规定，`默认大小在Hadoop2.x版本中是128M，老版本中是64M`
- HDFS的块设置太小，会增加寻址时间，程序一直在找块的开始位置
- 如果块设置的太大，从磁盘传输数据的时间会明显大于定位这个块开始位置所需的时间。导致程序在处理这块数据时，会非常慢
- HDFS块的大小设置主要取决于磁盘传输速率

# 五、HDFS数据流

- **写数据流程**

  ![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171726102.png)

  1. 客户端通过Distributed FileSystem模块向NameNode请求上传文件，NameNode检查目标文件是否已存在，父目录是否存在
  2. NameNode返回是否可以上传
  3. 客户端请求第一个 Block上传到哪几个DataNode服务器上
  4. NameNode返回3个DataNode节点，分别为dn1、dn2、dn3
  5. 客户端通过FSDataOutputStream模块请求dn1上传数据，dn1收到请求会继续调用dn2，然后dn2调用dn3，将这个通信管道建立完成
  6. dn1、dn2、dn3逐级应答客户端
  7. 客户端开始往dn1上传第一个Block（先从磁盘读取数据放到一个本地内存缓存），以Packet为单位，dn1收到一个Packet就会传给dn2，dn2传给dn3；dn1每传一个packet会放入一个应答队列等待应答
  8. 当一个Block传输完成之后，客户端再次请求NameNode上传第二个Block的服务器。（重复执行3-7步）

- **读数据流程**

  ![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171727652.png)

  1. 客户端通过Distributed FileSystem向NameNode请求下载文件，NameNode通过查询元数据，找到文件块所在的DataNode地址
  2. 挑选一台DataNode（就近原则，然后随机）服务器，请求读取数据
  3. DataNode开始传输数据给客户端（从磁盘里面读取数据输入流，以Packet为单位来做校验）
  4. 客户端以Packet为单位接收，先在本地缓存，然后写入目标文件

# 六、NameNode和SecondaryNameNode（重点）

- **NameNode中的元数据存储在哪里**

  - NameNode节点因为经常需要进行随机访问，还有响应客户请求，所以如果存储在节点的磁盘中，必然效率低下，因此，元数据需要存放在内存中
  - 但是，如果只存在内存中，一旦断电，元数据丢失，整个集群就无法工作了，因此，产生了在磁盘中备份元数据的FsImage
  - 这样又会带来新的问题，当在内存中的元数据更新时，如果同时更新FsImage，就会导致效率过低，但如果不更新，就会发生一致性问题，一旦NameNode节点断电，就会产生数据丢失，因此，引入Edits文件(只进行追加操作，效率很高)
  - 每当元数据有更新或者添加元数据时，修改内存中的元数据并追加到Edits中，这样，一旦NameNode节点断电，可以通过FsImage和Edits的合并，合成元数据
  - 但是，如果长时间添加数据到Edits中，会导致该文件数据过大，效率降低，而且一旦断电，恢复元数据需要的时间过长，因此，需要定期进行FsImage和Edits的合并
  - 如果这个操作由NameNode节点完成，又会效率过低，因此，引入一个新的节点SecondaryNamenode，专门用于FsImage和Edits的合并

- **NN和2NN工作机制**

  ![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171727506.png)

  - 第一阶段：NameNode启动
    1. 第一次启动NameNode格式化后，创建Fsimage和Edits文件。如果不是第一次启动，直接加载编辑日志和镜像文件到内存
    2. 客户端对元数据进行增删改的请求
    3. NameNode记录操作日志，更新滚动日志
    4. NameNode在内存中对元数据进行增删改
  - 第二阶段：Secondary  NameNode工作
    1. Secondary NameNode询问NameNode是否需要CheckPoint。直接带回NameNode是否检查结果
    2. Secondary NameNode请求执行CheckPoint
    3. NameNode滚动正在写的Edits日志
    4. 将滚动前的编辑日志和镜像文件拷贝到Secondary NameNode
    5. Secondary NameNode加载编辑日志和镜像文件到内存，并合并
    6. 生成新的镜像文件fsimage.chkpoint
    7. 拷贝fsimage.chkpoint到NameNode
    8. NameNode将fsimage.chkpoint重新命名成fsimage

- NN和2NN工作机制详解

  - Fsimage：NameNode内存中元数据序列化后形成的文件
  - Edits：记录客户端更新元数据信息的每一步操作（可通过Edits运算出元数据）
  - NameNode启动时，先滚动Edits并生成一个空的edits.inprogress，然后加载Edits和Fsimage到内存中，此时NameNode内存就持有最新的元数据信息。Client开始对NameNode发送元数据的增删改的请求，这些请求的操作首先会被记录到edits.inprogress中（查询元数据的操作不会被记录在Edits中，因为查询操作不会更改元数据信息），如果此时NameNode挂掉，重启后会从Edits中读取元数据的信息。然后，NameNode会在内存中执行元数据的增删改的操作
  - 由于Edits中记录的操作会越来越多，Edits文件会越来越大，导致NameNode在启动加载Edits时会很慢，所以需要对Edits和Fsimage进行合并（所谓合并，就是将Edits和Fsimage加载到内存中，照着Edits中的操作一步步执行，最终形成新的Fsimage）。SecondaryNameNode的作用就是帮助NameNode进行Edits和Fsimage的合并工作
  - SecondaryNameNode首先会询问NameNode是否需要CheckPoint（触发CheckPoint需要满足两个条件中的任意一个，定时时间到和Edits中数据写满了）。直接带回NameNode是否检查结果
  - SecondaryNameNode执行CheckPoint操作，首先会让NameNode滚动Edits并生成一个空的edits.inprogress，滚动Edits的目的是给Edits打个标记，以后所有新的操作都写入edits.inprogress，其他未合并的Edits和Fsimage会拷贝到SecondaryNameNode的本地，然后将拷贝的Edits和Fsimage加载到内存中进行合并，生成fsimage.chkpoint，然后将fsimage.chkpoint拷贝给NameNode，重命名为Fsimage后替换掉原来的Fsimage。NameNode在启动时就只需要加载之前未合并的Edits和Fsimage即可，因为合并过的Edits中的元数据信息已经被记录在Fsimage中

- **Fsimage和Edits解析**

  - NameNode被格式化之后，将在/opt/module/hadoop-2.7.2/data/tmp/dfs/name/current目录中产生如下文件：
    - fsimage_0000000000000000000
    - fsimage_0000000000000000000.md5
    - seen_txid
    - VERSION
  - Fsimage文件：HDFS文件系统元数据的一个永久性的检查点，其中包含HDFS文件系统的所有目录和文件inode的序列化信息
  - Edits文件：存放HDFS文件系统的所有更新操作的路径，文件系统客户端执行的所有写操作首先会被记录到Edits文件中
  - seen_txid文件保存的是一个数字，就是最后一个edits_的数字
  - 每次NameNode启动的时候都会将Fsimage文件读入内存，加载Edits里面的更新操作，保证内存中的元数据信息是最新的、同步的，可以看成NameNode启动的时候就将Fsimage和Edits文件进行了合并

- **CheckPoint时间设置**

  - 通常情况下，SecondaryNameNode每隔一小时执行一次

- **NameNode故障处理**

  - 将SecondaryNameNode中数据拷贝到NameNode存储数据的目录
  - 使用-importCheckpoint选项启动NameNode守护进程，从而将SecondaryNameNode中数据拷贝到NameNode目录中

- **集群安全模式**

  - `NameNode启动`：NameNode启动时，首先将镜像文件（Fsimage）载入内存，并执行编辑日志（Edits）中的各项操作。一旦在内存中成功建立文件系统元数据的映像，则创建一个新的Fsimage文件和一个空的编辑日志。此时，NameNode开始监听DataNode请求。这个过程期间，NameNode一直运行在安全模式，即NameNode的文件系统对于客户端来说是只读的
  - `DataNode启动`：系统中的数据块的位置并不是由NameNode维护的，而是以块列表的形式存储在DataNode中。在系统的正常操作期间，NameNode会在内存中保留所有块位置的映射信息。在安全模式下，各个DataNode会向NameNode发送最新的块列表信息，NameNode了解到足够多的块位置信息之后，即可高效运行文件系统
  - `安全模式退出判断`：如果满足“最小副本条件”，NameNode会在30秒钟之后就退出安全模式。所谓的最小副本条件指的是在整个文件系统中99.9%的块满足最小副本级别（默认值：dfs.replication.min=1）。在启动一个刚刚格式化的HDFS集群时，因为系统中还没有任何块，所以NameNode不会进入安全模式

# 七、DataNode（重点）

- **DataNode工作机制**

  ![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171727050.png)

  - 一个数据块在DataNode上以文件形式存储在磁盘上，包括两个文件，一个是数据本身，一个是元数据包括数据块的长度，块数据的校验和，以及时间戳
  - DataNode启动后向NameNode注册，通过后，周期性（1小时）的向NameNode上报所有的块信息
  - 心跳是每3秒一次，心跳返回结果带有NameNode给该DataNode的命令如复制块数据到另一台机器，或删除某个数据块。如果超过10分钟没有收到某个DataNode的心跳，则认为该节点不可用
  - 集群运行中可以安全加入和退出一些机器

- **数据完整性**

  - 当DataNode读取Block的时候，它会计算CheckSum
  - 如果计算后的CheckSum，与Block创建时值不一样，说明Block已经损坏
  - Client读取其他DataNode上的Block
  - DataNode在其文件创建后周期验证CheckSum，如图3-16所示

  ![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171727900.png)

- **掉线时限参数设置**

  ![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171728492.png)

  - 需要注意的是hdfs-site.xml 配置文件中的：
    - heartbeat.recheck.interval的单位为毫秒
    - dfs.heartbeat.interval的单位为秒

- **服役新数据节点**

- **退役旧数据节点**

  - 添加白名单：添加到白名单的主机节点，都允许访问NameNode，不在白名单的主机节点，都会被退出
  - 黑名单退役：在黑名单上的主机都会被强制退出

- **DataNode多目录配置**

  - DataNode也可以配置成多个目录，每个目录存储的数据不一样
  - 即：数据不是副本

# 八、小文件存档

- **HDFS存储小文件弊端**

  - 每个文件均按块存储，每个块的元数据存储在NameNode的内存中，因此HDFS存储小文件会非常低效
  - 因为大量的小文件会耗尽NameNode中的大部分内存
  - 但注意，存储小文件所需要的磁盘容量和数据块的大小无关
    - 例如，一个1MB的文件设置为128MB的块存储，实际使用的是1MB的磁盘空间，而不是128MB

- **解决存储小文件办法之一**

  - HDFS存档文件或HAR文件，是一个更高效的文件存档工具，它将文件存入HDFS块，在减少NameNode内存使用的同时，允许对文件进行透明的访问
  - 具体说来，HDFS存档文件对内还是一个一个独立文件，对NameNode而言却是一个整体，减少了NameNode的内存

  ![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171728441.png)

# 九、HDFS-HA自动故障转移工作机制

- HA
  - 所谓HA（High Available），即高可用（7*24小时不中断服务）
  - 实现高可用最关键的策略是消除单点故障
  - HA严格来说应该分成各个组件的HA机制：
    - HDFS的HA
    - YARN的HA
- NameNode主要在以下两个方面影响HDFS集群
  - NameNode机器发生意外，如宕机，集群将无法使用，直到管理员重启
  - NameNode机器需要升级，包括软件、硬件升级，此时集群也将无法使用
- 工作机制
  - 通过双NameNode消除单点故障
- 工作要点
  - 元数据管理方式需要改变
    - 内存中各自保存一份元数据
    - Edits日志只有Active状态的NameNode节点可以做写操作
    - 两个NameNode都可以读取Edits
    - 共享的Edits放在一个共享存储中管理（qjournal和NFS两个主流实现）
  - 需要一个状态管理功能模块
    - 实现了一个zkfailover，常驻在每一个namenode所在的节点，每一个zkfailover负责监控自己所在NameNode节点，利用zk进行状态标识，当需要进行状态切换时，由zkfailover来负责切换，切换时需要防止brain split现象的发生
  - 必须保证两个NameNode之间能够ssh无密码登录
  - 隔离（Fence），即同一时刻仅仅有一个NameNode对外提供服务
- **故障转移机制**