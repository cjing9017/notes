# 一、Spark Streaming概述

## 1.1 Spark Streaming是什么

- Spark Streaming用于流式数据的处理。Spark Streaming支持的数据输入源很多，例如：Kafka、Flume、Twitter、ZeroMQ和简单的TCP套接字等等。数据输入后可以用Spark的高度抽象原语如：map、reduce、join、window等进行运算。而结果也能保存在很多地方，如HDFS，数据库等

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181014578.png)

- 和Spark基于RDD的概念很相似，Spark Streaming使用离散化流(discretized stream)作为抽象表示，叫作DStream。DStream 是随时间推移而收到的数据的序列。在内部，每个时间区间收到的数据都作为 RDD 存在，而DStream是由这些RDD所组成的序列(因此得名“离散化”)

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181014075.png)

## 1.2 Spark Streaming特点

- 易用
- 容错
- 易聚合到Spark体系

## 1.3 Spark Streaming架构

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181014631.png)

- 有一个长期运行的接收器，用于将输入的数据流封装为DStream后，传输给Driver，Driver处理接收到的数据后开始向Executor进行分配任务

# 二、DStream入门

## 2.1 WordCount案例实操

```scala
package com.cjing.spark.streaming

import org.apache.spark.SparkConf
import org.apache.spark.streaming.dstream.{DStream, ReceiverInputDStream}
import org.apache.spark.streaming.{Seconds, StreamingContext}

class SparkStreaming01_WordCount {

    def main(args: Array[String]): Unit = {
        // Spark配置对象呢
        val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkStreaming01_WordCount ")

        // 实时数据分析环境对象
        val streamingContext = new StreamingContext(sparkConf, Seconds(3))

        // 从指定的端口中采集数据
        val socketDStream: ReceiverInputDStream[String] = context.socketTextStream("hadoop102", 9999)

        // 将采集的数据进行分解（扁平化）
        val wordDStream: DStream[String] = socketDStream.flatMap(line=>line.split(" "))

        // 将数据进行结构的转变，方便统计分析
        val mapDStream: DStream[(String, Int)] = wordDStream.map((_,1))

        // 将转换结构后的数据进行聚合处理
        val wordToSumDStream: DStream[(String, Int)] = mapDStream.reduceByKey(_+_)

        // 将结果打印出来
        wordDStream.print()

        // 不能停止采集程序

        // 启动采集器
        streamingContext.start()
        
        // Driver等待采集器的执行
        streamingContext.awaitTermination()
    }

}
```

## 2.2 WordCount解析

- Discretized Stream是Spark Streaming的基础抽象，代表持续性的数据流和经过各种Spark原语操作后的结果数据流。在内部实现上，DStream是一系列连续的RDD来表示。每个RDD含有一段时间间隔内的数据，如下图：

![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181014517.png)

- 对数据的操作也是按照RDD为单位来进行的

![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181014748.png)

- 计算过程由Spark engine来完成

![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181015980.png)

# 三、DStream创建

- Spark Streaming原生支持一些不同的数据源。一些“核心”数据源已经被打包到Spark Streaming 的 Maven 工件中，而其他的一些则可以通过 spark-streaming-kafka 等附加工件获取。每个接收器都以 Spark 执行器程序中一个长期运行的任务的形式运行，因此会占据分配给应用的 CPU 核心。此外，我们还需要有可用的 CPU 核心来处理数据。这意味着如果要运行多个接收器，就必须至少有和接收器数目相同的核心数，还要加上用来完成计算所需要的核心数。例如，如果我们想要在流计算应用中运行 10 个接收器，那么至少需要为应用分配 11 个 CPU 核心。所以如果在本地模式运行，不要使用local[1]

## 3.1 文件数据源

- 文件数据流：能够读取所有HDFS API兼容的文件系统文件，通过fileStream方法进行读取，Spark Streaming 将会监控 dataDirectory 目录并不断处理移动进来的文件，记住目前不支持嵌套目录

```scala
streamingContext.textFileStream(dataDirectory)
```

- 注意事项：
  - 文件需要有相同的数据格式
  - 件进入 dataDirectory的方式需要通过移动或者重命名来实现
  - 一旦文件移动进目录，则不能再修改，即便修改了也不会读取新数据

```scala
//（1）在HDFS上建好目录
[atguigu@hadoop102 spark]$ hadoop fs -mkdir /fileStream

//（2）在/opt/module/data创建三个文件
[atguigu@hadoop102 data]$ touch a.tsv
[atguigu@hadoop102 data]$ touch b.tsv
[atguigu@hadoop102 data]$ touch c.tsv

添加如下数据：
Hello	atguigu
Hello	spark

//（3）编写代码
package com.atguigu

import org.apache.spark.SparkConf
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.streaming.dstream.DStream

object FileStream {

  def main(args: Array[String]): Unit = {

    //1.初始化Spark配置信息
Val sparkConf = new SparkConf().setMaster("local[*]")
.setAppName("StreamWordCount")

    //2.初始化SparkStreamingContext
    val ssc = new StreamingContext(sparkConf, Seconds(5))

	//3.监控文件夹创建DStream
    val dirStream = ssc.textFileStream("hdfs://hadoop102:9000/fileStream")

    //4.将每一行数据做切分，形成一个个单词
    val wordStreams = dirStream.flatMap(_.split("\\t"))

    //5.将单词映射成元组（word,1）
    val wordAndOneStreams = wordStreams.map((_, 1))

    //6.将相同的单词次数做统计
    val wordAndCountStreams] = wordAndOneStreams.reduceByKey(_ + _)

    //7.打印
    wordAndCountStreams.print()

    //8.启动SparkStreamingContext
    ssc.start()
    ssc.awaitTermination()
  }
}

//（4）启动程序并向fileStream目录上传文件
[atguigu@hadoop102 data]$ hadoop fs -put ./a.tsv /fileStream
[atguigu@hadoop102 data]$ hadoop fs -put ./b.tsv /fileStream
[atguigu@hadoop102 data]$ hadoop fs -put ./c.tsv /fileStream

//（5）获取计算结果
-------------------------------------------
Time: 1539073810000 ms
-------------------------------------------

-------------------------------------------
Time: 1539073815000 ms
-------------------------------------------
(Hello,4)
(spark,2)
(atguigu,2)

-------------------------------------------
Time: 1539073820000 ms
-------------------------------------------
(Hello,2)
(spark,1)
(atguigu,1)

-------------------------------------------
Time: 1539073825000 ms
-------------------------------------------
```

## 3.2 RDD队列（了解）

- 测试过程中，可以通过使用ssc.queueStream(queueOfRDDs)来创建DStream，每一个推送到这个队列中的RDD，都会作为一个DStream处理

```scala
// 1）需求：循环创建几个RDD，将RDD放入队列。通过SparkStream创建Dstream，计算WordCount

// 2）编写代码
package com.atguigu

import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming.dstream.{DStream, InputDStream}
import org.apache.spark.streaming.{Seconds, StreamingContext}

import scala.collection.mutable

object RDDStream {

  def main(args: Array[String]) {

    //1.初始化Spark配置信息
    val conf = new SparkConf().setMaster("local[*]").setAppName("RDDStream")

    //2.初始化SparkStreamingContext
    val ssc = new StreamingContext(conf, Seconds(4))

    //3.创建RDD队列
    val rddQueue = new mutable.Queue[RDD[Int]]()

    //4.创建QueueInputDStream
    val inputStream = ssc.queueStream(rddQueue,oneAtATime = false)

    //5.处理队列中的RDD数据
    val mappedStream = inputStream.map((_,1))
    val reducedStream = mappedStream.reduceByKey(_ + _)

    //6.打印结果
    reducedStream.print()

    //7.启动任务
    ssc.start()

//8.循环创建并向RDD队列中放入RDD
    for (i <- 1 to 5) {
      rddQueue += ssc.sparkContext.makeRDD(1 to 300, 10)
      Thread.sleep(2000)
    }

    ssc.awaitTermination()
  }
}

// 3）结果展示
-------------------------------------------
Time: 1539075280000 ms
-------------------------------------------
(4,60)
(0,60)
(6,60)
(8,60)
(2,60)
(1,60)
(3,60)
(7,60)
(9,60)
(5,60)

-------------------------------------------
Time: 1539075284000 ms
-------------------------------------------
(4,60)
(0,60)
(6,60)
(8,60)
(2,60)
(1,60)
(3,60)
(7,60)
(9,60)
(5,60)

-------------------------------------------
Time: 1539075288000 ms
-------------------------------------------
(4,30)
(0,30)
(6,30)
(8,30)
(2,30)
(1,30)
(3,30)
(7,30)
(9,30)
(5,30)

-------------------------------------------
Time: 1539075292000 ms
-------------------------------------------
```

## 3.3 自定义数据源

- 需要继承Receiver，并实现onStart、onStop方法来自定义数据源采集

```scala
// 自定义数据源，实现监控某个端口号，获取该端口号内容
package com.cjing.spark.streaming

import java.io.{BufferedReader, InputStreamReader}

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.dstream.{DStream, ReceiverInputDStream}
import org.apache.spark.streaming.receiver.Receiver
import org.apache.spark.streaming.{Seconds, StreamingContext}

import scala.tools.nsc.io.Socket

class SparkStreaming02_MyReceiver {

    def main(args: Array[String]): Unit = {
        // Spark配置对象呢
        val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkStreaming02_MyReceiver")

        // 实时数据分析环境对象
        val streamingContext = new StreamingContext(sparkConf, Seconds(3))

        val receiverDStream: ReceiverInputDStream[String] = streamingContext.receiverStream(new MyReceiver("hadoop102", 9999))

        // 从指定的端口中采集数据
        // val socketDStream: ReceiverInputDStream[String] = streamingContext.socketTextStream("hadoop102", 9999)

        // 将采集的数据进行分解（扁平化）
        val wordDStream: DStream[String] = receiverDStream.flatMap(line=>line.split(" "))

        // 将数据进行结构的转变，方便统计分析
        val mapDStream: DStream[(String, Int)] = wordDStream.map((_,1))

        // 将转换结构后的数据进行聚合处理
        val wordToSumDStream: DStream[(String, Int)] = mapDStream.reduceByKey(_+_)

        // 将结果打印出来
        wordDStream.print()

        // 不能停止采集程序

        // 启动采集器
        streamingContext.start()

        // Driver等待采集器的执行
        streamingContext.awaitTermination()
    }

}

// 声明采集器
class MyReceiver(host:String, port:Int) extends Receiver[String](StorageLevel.MEMORY_ONLY) {

    var socket: java.net.Socket = null

    def reveive() = {
        socket = new java.net.Socket(host, port)
        val reader = new BufferedReader(new InputStreamReader(socket.getInputStream, "UTF-8"))
        var line:String = null
        while ((line == reader.readLine()) != null) {
            // 将采集的数据存储到采集器的内部进行转换
            if ("END".equals(line)) {
                return
            } else {
                this.store(line)
            }
        }
    }

    override def onStart(): Unit = {
        new Thread(new Runnable {
            override def run(): Unit = {
                reveive()
            }
        }).start()
    }

    override def onStop(): Unit = {
        if (socket != null) {
            socket.close()
            socket = null
        }
    }
}
```

## 3.4 Kafka数据源（重点）

```scala
object SparkStreaming03_KafkaSource {

    def main(args: Array[String]): Unit = {
        // Spark配置对象呢
        val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkStreaming03_KafkaSource")

        // 实时数据分析环境对象
        val streamingContext = new StreamingContext(sparkConf, Seconds(3))

        // 保存数据的状态，需要设定检查点路径
        streamingContext.sparkContext.setCheckpointDir("cp")

        val kafkaDStream: ReceiverInputDStream[(String, String)] = KafkaUtils.createStream(
            streamingContext,
            "hadoop102:2181",
            "hadoop",
            Map("hadoop" -> 3)
        )

        // 将采集的数据进行分解（扁平化）
        val wordDStream: DStream[String] = kafkaDStream.flatMap(t => t._2.split(" "))

        // 将数据进行结构的转变，方便统计分析
        val mapDStream: DStream[(String, Int)] = wordDStream.map((_,1))

        mapDStream.updateStateByKey{
            case (seq, buffer) => {
                val sum = buffer.getOrElse(0) + seq.sum
                Option(sum)
            }
        }

        // 将结果打印出来
        wordDStream.print()

        // 不能停止采集程序

        // 启动采集器
        streamingContext.start()

        // Driver等待采集器的执行
        streamingContext.awaitTermination()
    }

}
```

# 四、DStream转换

- DStream上的原语与RDD的类似，分为Transformations（转换）和Output Operations（输出）两种，此外转换操作中还有一些比较特殊的原语，如：updateStateByKey()、transform()以及各种Window相关的原语。

## 4.1 无状态转化操作

- 无状态转化操作就是把简单的RDD转化操作应用到每个批次上，也就是转化DStream中的每一个RDD。部分无状态转化操作列在了下表中。注意，针对键值对的DStream转化操作(比如 reduceByKey())要添加import StreamingContext._才能在Scala中使用

![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181015184.png)

- 需要记住的是，尽管这些函数看起来像作用在整个流上一样，但事实上每个DStream在内部是由许多RDD(批次)组成，且无状态转化操作是分别应用到每个RDD上的。例如，reduceByKey()会归约每个时间区间中的数据，但不会归约不同区间之间的数据
- 举个例子，在之前的wordcount程序中，我们只会统计5秒内接收到的数据的单词个数，而不会累加
- 无状态转化操作也能在多个DStream间整合数据，不过也是在各个时间区间内。例如，键 值对DStream拥有和RDD一样的与连接相关的转化操作，也就是cogroup()、join()、leftOuterJoin() 等。我们可以在DStream上使用这些操作，这样就对每个批次分别执行了对应的RDD操作
- 我们还可以像在常规的Spark 中一样使用 DStream的union() 操作将它和另一个DStream 的内容合并起来，也可以使用StreamingContext.union()来合并多个流。

## 4.2 有状态转化操作（重点）

### 4.2.1 UpdateStateByKey

- UpdateStateByKey原语用于记录历史记录，有时，我们需要在 DStream 中跨批次维护状态(例如流计算中累加wordcount)。针对这种情况，updateStateByKey() 为我们提供了对一个状态变量的访问，用于键值对形式的 DStream。给定一个由(键，事件)对构成的 DStream，并传递一个指定如何根据新的事件 更新每个键对应状态的函数，它可以构建出一个新的 DStream，其内部数据为(键，状态) 对
- updateStateByKey() 的结果会是一个新的 DStream，其内部的 RDD 序列是由每个时间区间对应的(键，状态)对组成的
- updateStateByKey操作使得我们可以在用新信息进行更新时保持任意的状态。为使用这个功能，你需要做下面两步： 1. 定义状态，状态可以是一个任意的数据类型。 2. 定义状态更新函数，用此函数阐明如何使用之前的状态和来自输入流的新值对状态进行更新
- **使用updateStateByKey需要对检查点目录进行配置，会使用检查点来保存状态**
- 更新版的wordcount：

```scala
object SparkStreaming03_KafkaSource {

    def main(args: Array[String]): Unit = {
        // Spark配置对象呢
        val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkStreaming03_KafkaSource")

        // 实时数据分析环境对象
        val streamingContext = new StreamingContext(sparkConf, Seconds(3))

        // 保存数据的状态，需要设定检查点路径
        streamingContext.sparkContext.setCheckpointDir("cp")

        val kafkaDStream: ReceiverInputDStream[(String, String)] = KafkaUtils.createStream(
            streamingContext,
            "hadoop102:2181",
            "hadoop",
            Map("hadoop" -> 3)
        )

        // 将采集的数据进行分解（扁平化）
        val wordDStream: DStream[String] = kafkaDStream.flatMap(t => t._2.split(" "))

        // 将数据进行结构的转变，方便统计分析
        val mapDStream: DStream[(String, Int)] = wordDStream.map((_,1))

        mapDStream.updateStateByKey{
            case (seq, buffer) => {
                val sum = buffer.getOrElse(0) + seq.sum
                Option(sum)
            }
        }

        // 将结果打印出来
        wordDStream.print()

        // 不能停止采集程序

        // 启动采集器
        streamingContext.start()

        // Driver等待采集器的执行
        streamingContext.awaitTermination()
    }

}
```

### 4.2.2 Window Operations

- Window Operations可以设置窗口的大小和滑动窗口的间隔来动态的获取当前Steaming的允许状态。基于窗口的操作会在一个比 StreamingContext 的批次间隔更长的时间范围内，通过整合多个批次的结果，计算出整个窗口的结果

![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181015244.png)

- 注意：所有基于窗口的操作都需要两个参数，分别为窗口时长以及滑动步长，两者都必须是 StreamContext 的批次间隔的整数倍
- 窗口时长控制每次计算最近的多少个批次的数据，其实就是最近的 windowDuration/batchInterval 个批次。如果有一个以 10 秒为批次间隔的源 DStream，要创建一个最近 30 秒的时间窗口(即最近 3 个批次)，就应当把 windowDuration 设为 30 秒。而滑动步长的默认值与批次间隔相等，用来控制对新的 DStream 进行计算的间隔。如果源 DStream 批次间隔为 10 秒，并且我们只希望每两个批次计算一次窗口结果， 就应该把滑动步长设置为 20 秒
- 关于Window的操作有如下原语：
  - window(windowLength, slideInterval): 基于对源DStream窗化的批次进行计算返回一个新的Dstream
  - countByWindow(windowLength, slideInterval)：返回一个滑动窗口计数流中的元素
  - reduceByWindow(func, windowLength, slideInterval)：通过使用自定义函数整合滑动区间流元素来创建一个新的单元素流
  - reduceByKeyAndWindow(func, windowLength, slideInterval, [numTasks])：当在一个(K,V)对的DStream上调用此函数，会返回一个新(K,V)对的DStream，此处通过对滑动窗口中批次数据使用reduce函数来整合每个key的value值。Note:默认情况下，这个操作使用Spark的默认数量并行任务(本地是2)，在集群模式中依据配置属性(spark.default.parallelism)来做grouping。你可以通过设置可选参数numTasks来设置不同数量的tasks
  - reduceByKeyAndWindow(func, invFunc, windowLength, slideInterval, [numTasks])：这个函数是上述函数的更高效版本，每个窗口的reduce值都是通过用前一个窗的reduce值来递增计算。通过reduce进入到滑动窗口数据并”反向reduce”离开窗口的旧数据来实现这个操作。一个例子是随着窗口滑动对keys的“加”“减”计数。通过前边介绍可以想到，这个函数只适用于”可逆的reduce函数”，也就是这些reduce函数有相应的”反reduce”函数(以参数invFunc形式传入)。如前述函数，reduce任务的数量通过可选参数来配置。注意：为了使用这个操作，[检查点](http://spark.apache.org/docs/latest/streaming-programming-guide.html#checkpointing)必须可用
  - countByValueAndWindow(windowLength,slideInterval, [numTasks])：对(K,V)对的DStream调用，返回(K,Long)对的新DStream，其中每个key的值是其在滑动窗口中频率。如上，可配置reduce任务数量
- reduceByWindow() 和 reduceByKeyAndWindow() 让我们可以对每个窗口更高效地进行归约操作。它们接收一个归约函数，在整个窗口上执行，比如 +。除此以外，它们还有一种特殊形式，通过只考虑新进入窗口的数据和离开窗口的数据，让 Spark 增量计算归约结果。这种特殊形式需要提供归约函数的一个逆函数，比 如 + 对应的逆函数为 -。对于较大的窗口，提供逆函数可以大大提高执行效率

## 4.3 其他重要操作

- **Transform**

  - Transform原语允许DStream上执行任意的RDD-to-RDD函数。即使这些函数并没有在DStream的API中暴露出来，通过该函数可以方便的扩展Spark API。该函数每一批次调度一次。其实也就是对DStream中的RDD应用转换
  - 比如下面的例子，在进行单词统计的时候，想要过滤掉spam的信息。

  ```scala
  val spamInfoRDD = ssc.sparkContext.newAPIHadoopRDD(...) // RDD containing spam information
  
  val cleanedDStream = wordCounts.transform { rdd =>
    rdd.join(spamInfoRDD).filter(...) // join data stream with spam information to do data cleaning
    ...
  }
  ```

- **Join**

  - 连接操作（leftOuterJoin, rightOuterJoin, fullOuterJoin也可以），可以连接Stream-Stream，windows-stream to windows-stream、stream-dataset
  - Stream-Stream Joins

  ```scala
  val stream1: DStream[String, String] = ...
  val stream2: DStream[String, String] = ...
  val joinedStream = stream1.join(stream2)
  
  val windowedStream1 = stream1.window(Seconds(20))
  val windowedStream2 = stream2.window(Minutes(1))
  val joinedStream = windowedStream1.join(windowedStream2)
  ```

  - Stream-dataset joins

  ```scala
  val dataset: RDD[String, String] = ...
  val windowedStream = stream.window(Seconds(20))...
  val joinedStream = windowedStream.transform { rdd => rdd.join(dataset) }
  ```

# 五、DStream输出

- 输出操作指定了对流数据经转化操作得到的数据所要执行的操作(例如把结果推入外部数据库或输出到屏幕上)。与RDD中的惰性求值类似，如果一个DStream及其派生出的DStream都没有被执行输出操作，那么这些DStream就都不会被求值。如果StreamingContext中没有设定输出操作，整个context就都不会启动
- 输出操作如下：
  - print()：在运行流程序的驱动结点上打印DStream中每一批次数据的最开始10个元素。这用于开发和调试。在Python API中，同样的操作叫print()
  - saveAsTextFiles(prefix, [suffix])：以text文件形式存储这个DStream的内容。每一批次的存储文件名基于参数中的prefix和suffix。”prefix-Time_IN_MS[.suffix]”
  - saveAsObjectFiles(prefix, [suffix])：以Java对象序列化的方式将Stream中的数据保存为 SequenceFiles . 每一批次的存储文件名基于参数中的为"prefix-TIME_IN_MS[.suffix]". Python中目前不可用
  - saveAsHadoopFiles(prefix, [suffix])：将Stream中的数据保存为 Hadoop files. 每一批次的存储文件名基于参数中的为"prefix-TIME_IN_MS[.suffix]"。 Python API Python中目前不可用
  - `foreachRDD(func)`：这是最通用的输出操作，即将函数 func 用于产生于 stream的每一个RDD。其中参数传入的函数func应该实现将每一个RDD中数据推送到外部系统，如将RDD存入文件或者通过网络将其写入数据库。注意：函数func在运行流应用的驱动中被执行，同时其中一般函数RDD操作从而强制其对于流RDD的运算
- 通用的输出操作foreachRDD()，它用来对DStream中的RDD运行任意计算。这和transform() 有些类似，都可以让我们访问任意RDD。在foreachRDD()中，可以重用我们在Spark中实现的所有行动操作
- 比如，常见的用例之一是把数据写到诸如MySQL的外部数据库中。 注意：
  - 连接不能写在driver层面
  - 如果写在foreach则每个RDD都创建，得不偿失
  - 增加foreachPartition，在分区创建