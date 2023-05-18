# 一、RDD概述

## 1.1 什么是RDD

- RDD（Resilient Distributed Dataset）叫做弹性分布式数据集，是Spark中最基本的数据（计算）抽象
- 代码中是一个抽象类，它代表一个不可变、可分区、里面的元素可并行计算的集合

## 1.2 RDD的属性

- 一组分区（Partition），即数据集的基本组成单元
- 一个计算每个分区的函数
- RDD之间的依赖关系

```scala
@transient private var deps: Seq[Dependency[_]]
```

- 一个Partitioner，即RDD的分片函数

```scala
final def partitions: Array[Partition] = {
    checkpointRDD.map(_.partitions).getOrElse {
      if (partitions_ == null) {
        partitions_ = getPartitions
        partitions_.zipWithIndex.foreach { case (partition, index) =>
          require(partition.index == index,
            s"partitions($index).partition == ${partition.index}, but it should equal $index")
        }
      }
      partitions_
    }
  }
```

- 一个列表，存储存取每个Partition的优先位置（preferred location）

```scala
final def preferredLocations(split: Partition): Seq[String] = {
    checkpointRDD.map(_.getPreferredLocations(split)).getOrElse {
      getPreferredLocations(split)
    }
  }

// 数据本地化 -》 节点本地化 -》 机架本地化
```

## 1.3 RDD特点

- RDD表示只读的分区的数据集，对RDD进行改动，只能通过RDD的转换操作，由一个RDD得到一个新的RDD

- 新的RDD包含了从其他RDD衍生所必需的信息

- RDDs之间存在依赖，RDD的执行是按照血缘关系延时计算的

- 如果血缘关系较长，可以通过持久化RDD来切断血缘关系

- **分区**

  - RDD逻辑上是分区的，每个分区的数据是抽象存在的，计算的时候会通过一个compute函数得到每个分区的数据
  - 如果RDD是通过已有的文件系统构建，则compute函数是读取指定文件系统中的数据
  - 如果RDD是通过其他RDD转换而来，则compute函数是执行转换逻辑将其他RDD的数据进行转换

- **只读**

  - RDD是只读的，要想改变RDD中的数据，只能在现有的RDD基础上创建新的RDD
  - 由一个RDD转换到另一个RDD，可以通过丰富的操作算子实现，不再像MapReduce那样只能写map和reduce了
  - RDD的操作算子包括两类
    - 一类叫做transformations，它是用来将RDD进行转化，构建RDD的血缘关系
    - 另一类叫做actions，它是用来触发RDD的计算，得到RDD的相关计算结果或者将RDD保存的文件系统中

- **依赖**

  - RDDs通过操作算子进行转换，转换得到的新RDD包含了从其他RDDs衍生所必需的信息，RDDs之间维护着这种血缘关系，也称之为依赖

  - 依赖包括两种

    - 一种是窄依赖，RDDs之间分区是一一对应的
    - 另一种是宽依赖，下游RDD的每个分区与上游RDD(也称之为父RDD)的每个分区都有关，是多对多的关系

    ![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171751092.png)

- **缓存**

  - 如果在应用程序中多次使用同一个RDD，可以将该RDD缓存起来，该RDD只有在第一次计算的时候会根据血缘关系得到分区的数据，在后续其他地方用到该RDD的时候，会直接从缓存处取而不用再根据血缘关系计算，这样就加速后期的重用
  - 如下图所示，RDD-1经过一系列的转换后得到RDD-n并保存到hdfs，RDD-1在这一过程中会有个中间结果，如果将其缓存到内存，那么在随后的RDD-1转换到RDD-m这一过程中，就不会计算其之前的RDD-0了

  ![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171751398.png)

- **CheckPoint**

  - 虽然RDD的血缘关系天然地可以实现容错，当RDD的某个分区数据失败或丢失，可以通过血缘关系重建
  - 但是对于长时间迭代型应用来说，随着迭代的进行，RDDs之间的血缘关系会越来越长，一旦在后续迭代过程中出错，则需要通过非常长的血缘关系去重建，势必影响性能
  - 为此，RDD支持checkpoint将数据保存到持久化的存储中，这样就可以切断之前的血缘关系，因为checkpoint后的RDD不需要知道它的父RDDs了，它可以从checkpoint处拿到数据

# 二、RDD编程

## 2.1 编程模型

- 在Spark中，RDD被表示为对象，通过对象上的方法调用来对RDD进行转换。经过一系列的transformations定义RDD之后，就可以调用actions触发RDD的计算，action可以是向应用程序返回结果(count, collect等)，或者是向存储系统保存数据(saveAsTextFile等)
- 在Spark中，只有遇到action，才会执行RDD的计算(即延迟计算)，这样在运行时可以通过管道的方式传输多个转换
- 要使用Spark，开发者需要编写一个Driver程序，它被提交到集群以调度运行Worker
- 如下图所示。Driver中定义了一个或多个RDD，并调用RDD上的action，Worker则执行RDD分区计算任务

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171751586.png)

## 2.2 RDD的创建

- **从集合中创建**

  - 使用parallelize()从集合创建

  ```scala
  scala> val rdd = sc.parallelize(Array(1,2,3,4,5,6,7,8))
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[0] at parallelize at <console>:24
  ```

  - 使用makeRDD()从集合创建，其底层实现就是parallelize

  ```scala
  scala> val rdd = sc.makeRDD(Array(1,2,3,4,5,6,7,8))
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[1] at makeRDD at <console>:24
  ```

  ```scala
  // makeRDD和parallelize都有一个参数numSlices
  // 不指定的情况下会使用默认参数defaultParallelism
  // 如果配置了配置文件，则使用配置文件的值
  // 否则从totalCoreCount和2中取最大值
  override def defaultParallelism(): Int = {
      conf.getInt("spark.default.parallelism", math.max(totalCoreCount.get(), 2))
  }
  
  def getInt(key: String, defaultValue: Int): Int = {
      getOption(key).map(_.toInt).getOrElse(defaultValue)
  }
  
  // 具体的分片规则
  def positions(length: Long, numSlices: Int): Iterator[(Int, Int)] = {
    (0 until numSlices).iterator.map { i =>
      val start = ((i * length) / numSlices).toInt
      val end = (((i + 1) * length) / numSlices).toInt
      (start, end)
    }
  }
  ```

- **从外部存储创建**

  - 包括本地的文件系统，还有所有的Hadoop支持的数据集，比如HDFS、Cassandra、HBase等

  ```scala
  scala> val rdd2= sc.textFile("hdfs://hadoop102:9000/RELEASE")
  rdd2: org.apache.spark.rdd.RDD[String] = hdfs:// hadoop102:9000/RELEASE MapPartitionsRDD[4] at textFile at <console>:24
  ```

  ```scala
  // 使用textFile的时候有一个参数minPartitions
  // 不指定的情况下会使用默认参数defaultMinPartitions
  // defaultMinPartitions的取值为defaultParallelism和2的最小值
  def defaultMinPartitions: Int = math.min(defaultParallelism, 2)
  
  // 传递的分区参数为最小分区数，但是不一定是这个分区数
  // 取决于Hadoop读取文件时的分片规则
  ```

- **从其他创建**

  - 详见2.3（主要是节点的转换）

## 2.3 RDD的转换（面试开发重点）

> RDD整体上分为Value类型和Key-Value类型

### 2.3.1 Value类型

- **map(func)**

  - 返回一个新的RDD，该RDD由每一个输入元素经过func函数转换后组成

  ```scala
  // 创建一个1-10数组的RDD，将所有元素*2形成新的RDD
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper1")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10)
      val mapRDD: RDD[Int] = listRDD.map(_*2)
      mapRDD.collect().foreach(println)
  }
  ```

- **mapPartitions(func)**

  - 类似于map(func)，但独立地在RDD的每一个分区上运行，因此在类型为T的RDD上运行时，func的函数类型必须是Iterator[T] => Iterator[U]

  ```scala
  // 创建一个RDD，使每个元素*2组成新的RDD
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper2")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10)
      val mapPartitionsRDD: RDD[Int] = listRDD.mapPartitions(datas => {
          datas.map(_ * 2)
      })
      mapPartitionsRDD.collect().foreach(println)
  }
  ```

- **map(func)和mapPartitions(func)的区别**

  ![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171752218.png)

  ![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171752424.png)

  - 假设有N个元素，有M个分区，那么map(func)的函数将被调用N次，而mapPartitions(func)被调用M次，一个函数一次处理所有分区
  - mapPartitions(func)效率优于map算子，减少了发送到执行器执行交互的次数
  - 缺点是mapPartitions(func)可能会出现内存溢出的问题，因为执行器一次要接收一个分区的数据，有可能会装不下

- **mapPartitionsWithIndex(func)**

  - 类似于mapPartitions，但func带有一个整数参数表示分区的索引值，因此在类型为T的RDD上运行时，func的函数类型必须是(Int, Interator[T]) => Iterator[U]

  ```scala
  // 创建一个RDD，使每个元素跟所在分区形成一个元组组成一个新的RDD
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper3")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10)
      val tupleRDD: RDD[(Int, String)] = listRDD.mapPartitionsWithIndex {
          case (index, datas) => {
              datas.map((_, "分区号：" + index))
          }
      }
      tupleRDD.collect().foreach(println)
  }
  ```

- **flatMap(func)**

  - 类似于map，但是每一个输入元素可以被映射为0或多个输出元素（所以func应该返回一个序列，而不是单一元素）

  ```scala
  // 创建一个包含两个List的RDD，新的RDD为两个List拆分之后的
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper4")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[List[Int]] = sc.makeRDD(Array(List(1, 2), List(3, 4)))
      val flatMapRDD: RDD[Int] = listRDD.flatMap(datas => datas)
      flatMapRDD.collect().foreach(println)
  }
  ```

- **glom**

  - 将每一个分区形成一个数组，形成新的RDD类型时RDD[Array[T]]

  ```scala
  // 创建一个4个分区的RDD，并将每个分区的数据放到一个数组
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper5")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10, 4)
      val glomRDD: RDD[Array[Int]] = listRDD.glom()
      glomRDD.collect().foreach(datas => println(datas.mkString(",")))
  }
  ```

- **groupBy(func)**

  - 分组，按照传入函数的返回值进行分组。将相同的key对应的值放入一个迭代器

  ```scala
  // 创建一个RDD，按照元素模以2的值进行分组
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper6")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10, 4)
      val groupByRDD: RDD[(Int, Iterable[Int])] = listRDD.groupBy(i => i % 2)
      groupByRDD.collect().foreach(println)
  }
  ```

- **filter(func)**

  - 过滤。返回一个新的RDD，该RDD由经过func函数计算后返回值为true的输入元素组成

  ```scala
  // 创建一个RDD，过滤出新的RDD（只包含偶数）
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark02_Oper7")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10)
      val filterRDD: RDD[Int] = listRDD.filter(x => x % 2 == 0)
      filterRDD.collect().foreach(println)
  }
  ```

- **sample(withReplacement, fraction, seed)**

  - 以指定的随机种子随机抽样出数量为fraction的数据
  - withReplacement表示是抽出的数据是否放回，true为有放回的抽样，false为无放回的抽样
    - 有放回抽样，使用泊松分布
    - 无放回抽样，使用伯努利分布
  - seed用于指定随机数生成器种子

  ```scala
  def sample(
      withReplacement: Boolean,
      fraction: Double,
      seed: Long = Utils.random.nextLong): RDD[T] = {
    require(fraction >= 0,
      s"Fraction must be nonnegative, but got ${fraction}")
  
    withScope {
      require(fraction >= 0.0, "Negative fraction value: " + fraction)
      if (withReplacement) {
        new PartitionwiseSampledRDD[T, T](this, new PoissonSampler[T](fraction), true, seed)
      } else {
        new PartitionwiseSampledRDD[T, T](this, new BernoulliSampler[T](fraction), true, seed)
      }
    }
  }
  
  // 创建一个RDD，从中选择放回和不放回抽样
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark03_Oper8")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 10)
      val unreplaceRDD: RDD[Int] = listRDD.sample(false, 0.6, 1)
      val replaceRDD: RDD[Int] = listRDD.sample(true, 2, 1)
      unreplaceRDD.collect().foreach(println)
      replaceRDD.collect().foreach(println)
  }
  ```

- **distinct([numTasks])**

  - 对源RDD进行去重后返回一个新的RDD。默认情况下，只有8个并行任务来操作，但是可以传入一个可选的numTasks参数改变它

  ![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181003911.png)

  - distinct()：会将RDD中一个分区的数据打乱重组到其他不同的分区，称之为shuffle
  - 使用distinct()对数据去重，但是因为去重后会导致数据减少，所以可以改变默认的分区的数量

  ```scala
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark03_Oper9")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(List(1,1,1,2,2,2,3,3))
  		// 创建一个RDD，去除重复数据
      val distinctRDD1: RDD[Int] = listRDD.distinct()
      distinctRDD1.collect().foreach(println)
  	  // 创建一个RDD，去除重复数据，并放在两个分区中
  		val distinct2: RDD[Int] = listRDD.distinct(2)
      distinct2.collect().foreach(println)
  }
  ```

- **coalesce(numPartitions)**

  - 缩减分区数，用于大数据集过滤后，提高小数据集的执行效率
  - 这里的缩减分区，可以简单的理解为合并分区，将最后几个分区进行合并（所以没有打乱重组，没有执行shuffle）

  ```scala
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark03_Oper10")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 16, 4)
      println(listRDD.partitions.size)
      val coalesceRDD: RDD[Int] = listRDD.coalesce(3)
      println(coalesceRDD.partitions.size)
  }
  ```

- **repartition(numPartitions)**

  - 根据分区数，重新通过网络随机洗牌所有数据

  ```scala
  // 创建一个4个分区的RDD，对其重新分区
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark03_Oper11")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 16, 4)
      val repartitionRDD: RDD[Int] = listRDD.repartition(2)
      repartitionRDD.glom().collect().foreach(println)
  }
  ```

- **coalesce和repartition的区别**

  - coalesce重新分区，可以选择是否进行shuffle过程。由参数shuffle: Boolean = false/true决定
  - repartition实际上是调用的coalesce，默认是进行shuffle的

  ```scala
  def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
      coalesce(numPartitions, shuffle = true)
  }
  ```

- **sortBy(func, [ascending], [numTasks]**

  - 使用func先对数据进行处理，按照处理后的数据比较结果排序，默认为正序

  ```scala
  // 创建一个RDD，按照不同的规则进行排序
  
  def main(args: Array[String]): Unit = {
      val conf = new SparkConf().setMaster("local[*]").setAppName("Spark03_Oper12")
      val sc = new SparkContext(conf)
  
      val listRDD: RDD[Int] = sc.makeRDD(1 to 16, 4)
      val sortRDD: RDD[Int] = listRDD.sortBy(x => x, false)
      sortRDD.collect().foreach(println)
  }
  
  def sortBy[K](
      f: (T) => K,
      ascending: Boolean = true,
      numPartitions: Int = this.partitions.length)
      (implicit ord: Ordering[K], ctag: ClassTag[K]): RDD[T] = withScope {
    this.keyBy[K](f)
        .sortByKey(ascending, numPartitions)
        .values
  }
  ```

- **pipe(command, [envVars])**

  - 管道，针对每个分区，都执行一个shell脚本，返回输出的RDD

  ```scala
  // 编写一个脚本，使用管道将脚本作用于RDD上
  
  Shell脚本
  #!/bin/sh
  echo "AA"
  while read LINE; do
     echo ">>>"${LINE}
  done
  
  scala> val rdd = sc.parallelize(List("hi","Hello","how","are","you"),1)
  rdd: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[50] at parallelize at <console>:24
  scala> rdd.pipe("/opt/module/spark/pipe.sh").collect()
  res18: Array[String] = Array(AA, >>>hi, >>>Hello, >>>how, >>>are, >>>you)
  
  scala> val rdd = sc.parallelize(List("hi","Hello","how","are","you"),2)
  rdd: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[52] at parallelize at <console>:24
  scala> rdd.pipe("/opt/module/spark/pipe.sh").collect()
  res19: Array[String] = Array(AA, >>>hi, >>>Hello, AA, >>>how, >>>are, >>>you)
  ```

### 2.3.2 双Value类型交互

- **union(otherDataset)**

  - 对源RDD和参数RDD求并集后返回一个新的RDD

  ```scala
  scala> val rdd1 = sc.parallelize(1 to 5)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[0] at parallelize at <console>:24
  
  scala> val rdd2 = sc.parallelize(5 to 10)
  rdd2: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[1] at parallelize at <console>:24
  
  scala> val rdd3 = rdd1.union(rdd2)
  rdd3: org.apache.spark.rdd.RDD[Int] = UnionRDD[2] at union at <console>:28
  
  scala> rdd3.collect()
  res0: Array[Int] = Array(1, 2, 3, 4, 5, 5, 6, 7, 8, 9, 10)                      
  
  scala>
  ```

- **subtract(otherDataset)**

  - 计算差的一种函数，去除两个RDD中相同的元素，不同的RDD将保留下来

  ```scala
  scala> val rdd1 = sc.parallelize(3 to 8)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[3] at parallelize at <console>:24
  
  scala> val rdd2 = sc.parallelize(1 to 5)
  rdd2: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[4] at parallelize at <console>:24
  
  scala> rdd1.subtract(rdd2).collect()
  res2: Array[Int] = Array(6, 8, 7)
  
  scala>
  ```

- **intersection(otherDataset)**

  - 对源RDD和参数RDD求交集后返回一个新的RDD

  ```scala
  scala> val rdd1 = sc.parallelize(1 to 7)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[9] at parallelize at <console>:24
  
  scala> val rdd2 = sc.parallelize(5 to 10)
  rdd2: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[10] at parallelize at <console>:24
  
  scala> val rdd3 = rdd1.intersection(rdd2)
  rdd3: org.apache.spark.rdd.RDD[Int] = MapPartitionsRDD[16] at intersection at <console>:28
  
  scala> rdd3.collect()
  res3: Array[Int] = Array(6, 7, 5)
  
  scala>
  ```

- **cartesian(otherDataset)**

  - 笛卡尔积（尽量避免使用）

  ```scala
  scala> val rdd1 = sc.parallelize(1 to 3)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[17] at parallelize at <console>:24
  
  scala> val rdd2 = sc.parallelize(2 to 5)
  rdd2: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[18] at parallelize at <console>:24
  
  scala> rdd1.cartesian(rdd2).collect()
  res4: Array[(Int, Int)] = Array((1,2), (1,3), (1,4), (1,5), (2,2), (2,3), (3,2), (3,3), (2,4), (2,5), (3,4), (3,5))
  
  scala>
  ```

- **zip(otherDataset)**

  - 将两个RDD组合成Key/Value形式的RDD,这里默认两个RDD的partition数量以及元素数量都相同，否则会抛出异常

  ```scala
  scala> val rdd1 = sc.parallelize(Array(1,2,3),3)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[20] at parallelize at <console>:24
  
  scala> val rdd2 = sc.parallelize(Array("a","b","c"),3)
  rdd2: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[21] at parallelize at <console>:24
  
  scala> rdd1.zip(rdd2).collect()
  res5: Array[(Int, String)] = Array((1,a), (2,b), (3,c))
  
  scala> rdd2.zip(rdd1).collect()
  res6: Array[(String, Int)] = Array((a,1), (b,2), (c,3))
  
  scala>
  ```

### 2.3.3 Key-Value类型

- **partitionBy**

  - 对pairRDD进行分区操作，如果原有的partionRDD和现有的partionRDD是一致的话就不进行分区， 否则会生成ShuffleRDD，即会产生shuffle过程

  ```scala
  // 创建一个4个分区的RDD，对其重新分区
  scala> val rdd = sc.parallelize(Array((1,"aaa"),(2,"bbb"),(3,"ccc"),(4,"ddd")),4)
  rdd: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[24] at parallelize at <console>:24
  
  scala> var rdd2 = rdd.partitionBy(new org.apache.spark.HashPartitioner(2))
  rdd2: org.apache.spark.rdd.RDD[(Int, String)] = ShuffledRDD[25] at partitionBy at <console>:26
  
  scala> rdd2.glom.collect
  res7: Array[Array[(Int, String)]] = Array(Array((2,bbb), (4,ddd)), Array((1,aaa), (3,ccc)))
  
  class HashPartitioner(partitions: Int) extends Partitioner {
    require(partitions >= 0, s"Number of partitions ($partitions) cannot be negative.")
  
    def numPartitions: Int = partitions
  
    def getPartition(key: Any): Int = key match {
      case null => 0
      case _ => Utils.nonNegativeMod(key.hashCode, numPartitions)
    }
  
    override def equals(other: Any): Boolean = other match {
      case h: HashPartitioner =>
        h.numPartitions == numPartitions
      case _ =>
        false
    }
  
    override def hashCode: Int = numPartitions
  }
  
  def nonNegativeMod(x: Int, mod: Int): Int = {
      val rawMod = x % mod
      rawMod + (if (rawMod < 0) mod else 0)
    }
  ```

  - 这里利用到了一个HashPartitioner
  - 根据源码可以发现，他是根据key进行分区的
    - 如果key为null，则返回0
    - 否则，返回key的hashcode与分区数的取余（并且保证了结果不为负）
  - 可以对分区器进行重写

  ```scala
  object Spark04_Oper1 {
  
      def main(args: Array[String]): Unit = {
          val conf = new SparkConf().setMaster("local[*]").setAppName("Spark04_Oper1")
          val sc = new SparkContext(conf)
  
          val listRDD: RDD[(String, Int)] = sc.makeRDD(List(("a", 1), ("b", 2), ("C", 3)))
          val partRDD: RDD[(String, Int)] = listRDD.partitionBy(new MyPartitioner(3))
          partRDD.collect().foreach(println)
      }
  }
  
  class MyPartitioner(partitions: Int) extends Partitioner {
      override def numPartitions: Int = partitions
  
      override def getPartition(key: Any): Int = 1
  }
  ```

- **groupByKey**

  - groupByKey也是对每个key进行操作，但只生成一个sequence

  ```scala
  // 创建一个pairRDD，将相同key对应值聚合到一个sequence中，并计算相同key对应值的相加结果
  scala> val words = Array("one", "two", "two", "three", "three", "three")
  words: Array[String] = Array(one, two, two, three, three, three)
  
  scala> val wordPairsRDD = sc.parallelize(words).map(word => (word, 1))
  wordPairsRDD: org.apache.spark.rdd.RDD[(String, Int)] = MapPartitionsRDD[28] at map at <console>:26
  
  scala> val group = wordPairsRDD.groupByKey()
  group: org.apache.spark.rdd.RDD[(String, Iterable[Int])] = ShuffledRDD[29] at groupByKey at <console>:28
  
  scala> group.collect()
  res8: Array[(String, Iterable[Int])] = Array((two,CompactBuffer(1, 1)), (one,CompactBuffer(1)), (three,CompactBuffer(1, 1, 1)))
  
  scala> group.map(t => (t._1, t._2.sum))
  res9: org.apache.spark.rdd.RDD[(String, Int)] = MapPartitionsRDD[30] at map at <console>:31
  
  scala> res9.collect()
  res10: Array[(String, Int)] = Array((two,2), (one,1), (three,3))
  ```

- **reduceByKey(func, [numTasks])**

  - 在一个(K,V)的RDD上调用，返回一个(K,V)的RDD，使用指定的reduce函数，将相同key的值聚合到一起，reduce任务的个数可以通过第二个可选的参数来设置

  ```scala
  // 创建一个pairRDD，计算相同key对应值的相加结果
  scala> val rdd = sc.parallelize(List(("female",1), ("male",5), ("female",5), ("male",2)))
  rdd: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[0] at parallelize at <console>:24
  
  scala> rdd.reduceByKey
  reduceByKey   reduceByKeyLocally
  
  scala> rdd.reduceByKey(_+_).collect()
  res0: Array[(String, Int)] = Array((female,6), (male,7))
  ```

- **reduceByKey和groupByKey的区别**

  - reduceByKey：按照key进行聚合，在shuffle之前有combine（预聚合）操作，返回结果是RDD[k,v].
  - groupByKey：按照key进行分组，直接进行shuffle

  ![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181003042.png)

- **aggregateByKey**

  - (zeroValue:U,[partitioner: Partitioner]) (seqOp: (U, V) => U,combOp: (U, U) => U)
  - 在kv对的RDD中，按key将value进行分组合并，合并时，将每个value和初始值作为seq函数的参数，进行计算，返回的结果作为一个新的kv对，然后再将结果按照key进行合并，最后将每个分组的value传递给combine函数进行计算（先将前两个value进行计算，将返回结果和下一个value传给combine函数，以此类推），将key与计算结果作为一个新的kv对输出
  - 参数描述：
    - zeroValue：给每一个分区中的每一个key一个初始值
    - seqOp：函数用于在每一个分区中用初始值逐步迭代value
    - combOp：函数用于合并每个分区中同一个key的结果

  ```scala
  // 创建一个pairRDD，取出每个分区相同key对应值的最大值，然后相加
  scala> val rdd = sc.parallelize(List(("a",3),("a",2),("c",4),("b",3),("c",6),("c",8)),2)
  rdd: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[2] at parallelize at <console>:24
  
  scala> rdd.glom().collect()
  res1: Array[Array[(String, Int)]] = Array(Array((a,3), (a,2), (c,4)), Array((b,3), (c,6), (c,8)))
  
  scala> val agg = rdd.aggregateByKey(0)(math.max(_,_), _+_)
  agg: org.apache.spark.rdd.RDD[(String, Int)] = ShuffledRDD[4] at aggregateByKey at <console>:26
  
  scala> agg.collect()
  res2: Array[(String, Int)] = Array((b,3), (a,3), (c,12))
  
  scala>
  ```

  ![9](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181004759.png)

- **foldByKey**

  - (zeroValue: V)(func: (V, V) => V): RDD[(K, V)]
  - aggregateByKey的简化操作，seqop和combop相同

  ```scala
  // 创建一个pairRDD，计算相同key对应值的相加结果
  scala> val rdd = sc.parallelize(List((1,3),(1,2),(1,4),(2,3),(3,6),(3,8)),3)
  rdd: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[5] at parallelize at <console>:24
  
  scala> val agg = rdd.foldByKey(0)(_+_)
  agg: org.apache.spark.rdd.RDD[(Int, Int)] = ShuffledRDD[6] at foldByKey at <console>:26
  
  scala> agg.collect()
  res3: Array[(Int, Int)] = Array((3,14), (1,9), (2,3))
  ```

- **combineByKey[C]**

  - (createCombiner: V => C, mergeValue: (C, V) => C, mergeCombiners: (C, C) => C)
  - 对相同K，把V合并成一个集合
  - 参数描述：
    - createCombiner: combineByKey() 会遍历分区中的所有元素，因此每个元素的键要么还没有遇到过，要么就和之前的某个元素的键相同。如果这是一个新的元素,combineByKey()会使用一个叫作createCombiner()的函数来创建那个键对应的累加器的初始值
    - mergeValue: 如果这是一个在处理当前分区之前已经遇到的键，它会使用mergeValue()方法将该键的累加器对应的当前值与这个新的值进行合并
    - mergeCombiners: 由于每个分区都是独立处理的， 因此对于同一个键可以有多个累加器。如果有两个或者更多的分区都有对应同一个键的累加器， 就需要使用用户提供的 mergeCombiners() 方法将各个分区的结果进行合并

  ```scala
  // 创建一个pairRDD，根据key计算每种key的均值。（先计算每个key出现的次数以及可以对应值的总和，再相除得到结果）
  scala> val input = sc.parallelize(Array(("a", 88), ("b", 95), ("a", 91), ("b", 93), ("a", 95), ("b", 98)),2)
  input: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[7] at parallelize at <console>:24
  
  scala> val combine = input.combineByKey((_,1),(acc:(Int,Int),v)=>(acc._1+v,acc._2+1),(acc1:(Int,Int),acc2:(Int,Int))=>(acc1._1+acc2._1,acc1._2+acc2._2))
  combine: org.apache.spark.rdd.RDD[(String, (Int, Int))] = ShuffledRDD[8] at combineByKey at <console>:26
  
  scala> combine.collect
  res4: Array[(String, (Int, Int))] = Array((b,(286,3)), (a,(274,3)))
  
  scala> val result = combine.map{case (key,value) => (key,value._1/value._2.toDouble)}
  result: org.apache.spark.rdd.RDD[(String, Double)] = MapPartitionsRDD[9] at map at <console>:28
  
  scala>  result.collect()
  res5: Array[(String, Double)] = Array((b,95.33333333333333), (a,91.33333333333333))
  ```

  ![10](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181004339.png)

- **sortByKey([ascending], [numTasks])**

  - 在一个(K,V)的RDD上调用，K必须实现Ordered接口，返回一个按照key进行排序的(K,V)的RDD

  ```scala
  // 创建一个pairRDD，按照key的正序和倒序进行排序
  scala> val rdd = sc.parallelize(Array((3,"aa"),(6,"cc"),(2,"bb"),(1,"dd")))
  rdd: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[10] at parallelize at <console>:24
  
  scala> rdd.sortByKey(true).collect()
  res6: Array[(Int, String)] = Array((1,dd), (2,bb), (3,aa), (6,cc))
  
  scala> rdd.sortByKey(false).collect()
  res7: Array[(Int, String)] = Array((6,cc), (3,aa), (2,bb), (1,dd))
  ```

- **mapValues**

  - 针对于(K,V)形式的类型只对V进行操作

  ```scala
  // 创建一个pairRDD，并将value添加字符串"|||"
  scala> val rdd3 = sc.parallelize(Array((1,"a"),(1,"d"),(2,"b"),(3,"c")))
  rdd3: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[17] at parallelize at <console>:24
  
  scala> rdd3.mapValues(_+"|||").collect()
  res8: Array[(Int, String)] = Array((1,a|||), (1,d|||), (2,b|||), (3,c|||))
  ```

- **join(otherDataset, [numTasks])**

  - 在类型为(K,V)和(K,W)的RDD上调用，返回一个相同key对应的所有元素对在一起的(K,(V,W))的RDD
  - 如果第二个RDD中存在第一个RDD中不存在的key，则这个key会被忽略

  ```scala
  // 创建两个pairRDD，并将key相同的数据聚合到一个元组
  scala> val rdd = sc.parallelize(Array((1,"a"),(2,"b"),(3,"c")))
  rdd: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[19] at parallelize at <console>:24
  
  scala> val rdd1 = sc.parallelize(Array((1,4),(2,5),(3,6)))
  rdd1: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[20] at parallelize at <console>:24
  
  scala> rdd.join(rdd1).collect()
  res9: Array[(Int, (String, Int))] = Array((2,(b,5)), (1,(a,4)), (3,(c,6)))
  
  scala> val rdd2 = sc.parallelize(Array((1, "aaa"),(2, "bbb"),(3, "ccc")))
  rdd2: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[24] at parallelize at <console>:24
  
  scala> res9.join(rdd2).collect()
  <console>:33: error: value join is not a member of Array[(Int, (String, Int))]
         res9.join(rdd2).collect()
              ^
  
  scala> rdd.join(rdd1).join(rdd2).collect()
  res11: Array[(Int, ((String, Int), String))] = Array((2,((b,5),bbb)), (1,((a,4),aaa)), (3,((c,6),ccc)))
  ```

- **cogroup(otherDataset, [numTasks])**

  - 在类型为(K,V)和(K,W)的RDD上调用，返回一个(K,(Iterable<V>, Iterable<W>))类型的RDD

  ```scala
  // 创建两个pairRDD，并将key相同的数据聚合到一个迭代器
  scala> val rdd = sc.parallelize(Array((1,"a"),(2,"b"),(3,"c")))
  rdd: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[31] at parallelize at <console>:24
  
  scala> val rdd1 = sc.parallelize(Array((1,4),(2,5),(3,6)))
  rdd1: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[32] at parallelize at <console>:24
  
  scala> rdd.cogroup(rdd1).collect()
  res12: Array[(Int, (Iterable[String], Iterable[Int]))] = Array((2,(CompactBuffer(b),CompactBuffer(5))), (1,(CompactBuffer(a),CompactBuffer(4))), (3,(CompactBuffer(c),CompactBuffer(6))))
  
  scala> val rdd1 = sc.parallelize(Array((1,4),(2,5),(3,6)))
  rdd1: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[35] at parallelize at <console>:24
  
  scala> rdd.cogroup(rdd1).collect()
  res13: Array[(Int, (Iterable[String], Iterable[Int]))] = Array((4,(CompactBuffer(),CompactBuffer(7))), (2,(CompactBuffer(b),CompactBuffer(5))), (1,(CompactBuffer(a),CompactBuffer(4))), (3,(CompactBuffer(c),CompactBuffer(6))))
  
  scala> rdd.join(rdd1).collect()
  res14: Array[(Int, (String, Int))] = Array((2,(b,5)), (1,(a,4)), (3,(c,6)))
  ```

### 2.3.4 案例：统计每个省份广告被点击次数的TOP3

```scala
// 数据结构：时间戳，省份，城市，用户，广告，中间字段使用空格分割
// 样本数据如下
1516609143867 6 7 64 16
1516609143869 9 4 75 18
1516609143869 1 7 87 12
// 统计出每一个省份广告被点击次数的TOP3
def main(args: Array[String]): Unit = {
        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark4_Oper")
        val sc = new SparkContext(conf)

        // 读取数据生成RDD：TS，Province，City，User，AD
        val line = sc.textFile("in/agent.log")

        // 按照最小粒度聚合：((Province, AD), 1)
        val provinceAdToOne = line.map{x =>
            val fields = x.split(" ")
            ((fields(1), fields(4)), 1)
        }

        // 计算每个省中每个广告被点击的总数：((Province, AD), sum)
        val provinceAdToSum = provinceAdToOne.reduceByKey(_+_)

        // 将省份作为key，广告加点击数作为value：(Province, (AD, sum))
        val provinceToAdSum = provinceAdToSum.map(x => (x._1._1, (x._1._2, x._2)))

        // 将同一个省份的所有广告进行聚合(Province, List((AD1, sum), (AD2, sum)...)
        val provinceGroup = provinceToAdSum.groupByKey()

        // 对同一个省份所有广告的集合进行排序并取前3条，排序规则为广告点击总数
        val provinceAdTop3 = provinceGroup.mapValues {x =>
            x.toList.sortWith((x,y) => x._2 > y._2).take(3)
        }

        // 将数据拉取到Driver端并打印
        provinceAdTop3.collect().foreach(println)
    }
```

## 2.4 Action

- **reduce(func)**

  - 通过func函数聚集RDD中的所有元素，先聚合分区内数据，再聚合分区间数据

  ```scala
  // 创建一个RDD，将所有元素聚合得到结果
  scala> val rdd1 = sc.makeRDD(1 to 10,2)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[0] at makeRDD at <console>:24
  
  scala> rdd1.reduce(_+_)
  res0: Int = 55                                                                  
  
  scala> val rdd2 = sc.makeRDD(Array(("a",1),("a",3),("c",3),("d",5)))
  rdd2: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[1] at makeRDD at <console>:24
  
  scala> rdd2.reduce((x,y)=>(x._1 + y._1,x._2 + y._2))
  res1: (String, Int) = (aacd,12)
  ```

- **collect()**

  - 在驱动程序中，以数组的形式返回数据集的所有元素

  ```scala
  // 创建一个RDD，并将RDD内容收集到Driver端打印
  scala> val rdd = sc.parallelize(1 to 10)
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[2] at parallelize at <console>:24
  
  scala> rdd.collect()
  res2: Array[Int] = Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  ```

- **count()**

  - 返回RDD中元素的个数

  ```scala
  // 创建一个RDD，统计该RDD的条数
  scala> val rdd = sc.parallelize(1 to 10)
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[3] at parallelize at <console>:24
  
  scala> rdd.count()
  res3: Long = 10
  ```

- **first()**

  - 返回RDD中的第一个元素

  ```scala
  // 创建一个RDD，返回该RDD中的第一个元素
  scala> val rdd = sc.parallelize(1 to 10)
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[4] at parallelize at <console>:24
  
  scala> rdd.first()
  res4: Int = 1
  ```

- **take(n)**

  - 返回一个由RDD的前n个元素组成的数组

  ```scala
  // 创建一个RDD，统计该RDD的条数
  scala> val rdd = sc.parallelize(Array(2,5,4,6,8,3))
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[5] at parallelize at <console>:24
  
  scala> rdd.take(3)
  res5: Array[Int] = Array(2, 5, 4)
  ```

- **takeOrdered(n)**

  - 返回该RDD排序后的前n个元素组成的数组

  ```scala
  // 创建一个RDD，统计该RDD的条数
  scala> val rdd = sc.parallelize(Array(2,5,4,6,8,3))
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[6] at parallelize at <console>:24
  
  scala> rdd.takeOrdered(3)
  res6: Array[Int] = Array(2, 3, 4)
  ```

- **aggregate**

  - (zeroValue: U)(seqOp: (U, T) ⇒ U, combOp: (U, U) ⇒ U)
  - aggregate函数将每个分区里面的元素通过seqOp和初始值进行聚合，然后用combine函数将每个分区的结果和初始值(zeroValue)进行combine操作。这个函数最终返回的类型不需要和RDD中元素类型一致

  ```scala
  // 创建一个RDD，将所有元素相加得到结果
  scala> var rdd1 = sc.makeRDD(1 to 10,2)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[8] at makeRDD at <console>:24
  
  scala> rdd1.aggregate(0)(_+_,_+_)
  res7: Int = 55
  
  scala> rdd1.aggregate(10)(_+_,_+_)
  res8: Int = 85
  ```

- **fold(num)(func)**

  - 折叠操作，aggregate的简化操作，seqop和combop一样

  ```scala
  // 创建一个RDD，将所有元素相加得到结果
  scala> var rdd1 = sc.makeRDD(1 to 10,2)
  rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[9] at makeRDD at <console>:24
  
  scala> rdd1.fold(0)(_+_)
  res9: Int = 55
  
  scala> rdd1.fold(10)(_+_)
  res10: Int = 85
  ```

- **saveAsTextFile(path)**

  - 将数据集的元素以textfile的形式保存到HDFS文件系统或者其他支持的文件系统，对于每个元素，Spark将会调用toString方法，将它装换为文件中的文本

- **saveAsSequenceFile(path)**

  - 将数据集中的元素以Hadoop sequencefile的格式保存到指定的目录下，可以使HDFS或者其他Hadoop支持的文件系统

- **saveAsObjectFile(path)**

  - 用于将RDD中的元素序列化成对象，存储到文件中

- **countByKey()**

  - 针对(K,V)类型的RDD，返回一个(K,Int)的map，表示每一个key对应的元素个数

  ```scala
  // 创建一个PairRDD，统计每种key的个数
  scala> val rdd = sc.parallelize(List((1,3),(1,2),(1,4),(2,3),(3,6),(3,8)),3)
  rdd: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[10] at parallelize at <console>:24
  
  scala> rdd.countByKey()
  res11: scala.collection.Map[Int,Long] = Map(3 -> 2, 1 -> 3, 2 -> 1)
  ```

- **foreach(func)**

  - 在数据集的每一个元素上，运行函数func进行更新

  ```scala
  // 创建一个RDD，对每个元素进行打印
  scala> var rdd = sc.makeRDD(1 to 5,2)
  rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[13] at makeRDD at <console>:24
  
  scala> rdd.foreach(println)
  1
  2
  3
  4
  5
  ```

  ![11](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181005813.png)

## 2.5 RDD中的函数传递

> 在实际开发中我们往往需要自己定义一些对于RDD的操作，那么此时需要主要的是，初始化工作是在Driver端进行的，而实际运行程序是在Executor端进行的，这就涉及到了跨进程通信，是需要序列化的

### 2.5.1 传递一个方法

```scala
object Spark05_Serializable {

    def main(args: Array[String]): Unit = {
        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark05_Serializable")
        val sc = new SparkContext(conf)

        val rdd: RDD[String] = sc.parallelize(Array("hadoop", "spark", "hive", "atguigu"))
        val search = new Search("h")
        val match1: RDD[String] = search.getMatch1(rdd)
        match1.collect().foreach(println)
    }
}

class Search(query: String) {

    def isMatch(s: String) = {
        s.contains(query)
    }

    def getMatch1(rdd: RDD[String]) = {
        rdd.filter(isMatch)
    }

    def getMatch2(rdd: RDD[String]) = {
        rdd.filter(x => x.contains(query))
    }
}

Exception in thread "main" org.apache.spark.SparkException: Task not serializable
	at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:298)
	at org.apache.spark.util.ClosureCleaner$.org$apache$spark$util$ClosureCleaner$$clean(ClosureCleaner.scala:288)
	at org.apache.spark.util.ClosureCleaner$.clean(ClosureCleaner.scala:108)
	at org.apache.spark.SparkContext.clean(SparkContext.scala:2101)
	at org.apache.spark.rdd.RDD$$anonfun$filter$1.apply(RDD.scala:387)
	at org.apache.spark.rdd.RDD$$anonfun$filter$1.apply(RDD.scala:386)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:151)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:112)
	at org.apache.spark.rdd.RDD.withScope(RDD.scala:362)
	at org.apache.spark.rdd.RDD.filter(RDD.scala:386)
	at com.cjing.spark.Search.getMatch1(Spark05_Serializable.scala:26)
	at com.cjing.spark.Spark05_Serializable$.main(Spark05_Serializable.scala:14)
	at com.cjing.spark.Spark05_Serializable.main(Spark05_Serializable.scala)
Caused by: java.io.NotSerializableException: com.cjing.spark.Search
Serialization stack:
	- object not serializable (class: com.cjing.spark.Search, value: com.cjing.spark.Search@377c68c6)
	- field (class: com.cjing.spark.Search$$anonfun$getMatch1$1, name: $outer, type: class com.cjing.spark.Search)
	- object (class com.cjing.spark.Search$$anonfun$getMatch1$1, <function1>)
	at org.apache.spark.serializer.SerializationDebugger$.improveException(SerializationDebugger.scala:40)
	at org.apache.spark.serializer.JavaSerializationStream.writeObject(JavaSerializer.scala:46)
	at org.apache.spark.serializer.JavaSerializerInstance.serialize(JavaSerializer.scala:100)
	at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:295)
	... 12 more
def getMatch1(rdd: RDD[String]) = {
    rdd.filter(isMatch)
}
```

- 在这个方法中所调用的方法isMatch()是定义在Search这个类中的，实际上调用的是this. isMatch()，this表示Search这个类的对象，程序在运行过程中需要将Search对象序列化以后从Driver端传递到Executor端
- 解决方案

```scala
使类继承scala.Serializable即可
class Search() extends Serializable{...}
```

### 2.5.2 传递一个属性

```scala
object Spark05_Serializable {

    def main(args: Array[String]): Unit = {
        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark05_Serializable")
        val sc = new SparkContext(conf)

        val rdd: RDD[String] = sc.parallelize(Array("hadoop", "spark", "hive", "atguigu"))
        val search = new Search("h")
        val match1: RDD[String] = search.getMatch2(rdd)
        match1.collect().foreach(println)
    }
}

class Search(query: String) {

    def isMatch(s: String) = {
        s.contains(query)
    }

    def getMatch1(rdd: RDD[String]) = {
        rdd.filter(isMatch)
    }

    def getMatch2(rdd: RDD[String]) = {
        rdd.filter(x => x.contains(query))
    }
}

Exception in thread "main" org.apache.spark.SparkException: Task not serializable
	at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:298)
	at org.apache.spark.util.ClosureCleaner$.org$apache$spark$util$ClosureCleaner$$clean(ClosureCleaner.scala:288)
	at org.apache.spark.util.ClosureCleaner$.clean(ClosureCleaner.scala:108)
	at org.apache.spark.SparkContext.clean(SparkContext.scala:2101)
	at org.apache.spark.rdd.RDD$$anonfun$filter$1.apply(RDD.scala:387)
	at org.apache.spark.rdd.RDD$$anonfun$filter$1.apply(RDD.scala:386)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:151)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:112)
	at org.apache.spark.rdd.RDD.withScope(RDD.scala:362)
	at org.apache.spark.rdd.RDD.filter(RDD.scala:386)
	at com.cjing.spark.Search.getMatch2(Spark05_Serializable.scala:30)
	at com.cjing.spark.Spark05_Serializable$.main(Spark05_Serializable.scala:14)
	at com.cjing.spark.Spark05_Serializable.main(Spark05_Serializable.scala)
Caused by: java.io.NotSerializableException: com.cjing.spark.Search
Serialization stack:
	- object not serializable (class: com.cjing.spark.Search, value: com.cjing.spark.Search@3c4bc9fc)
	- field (class: com.cjing.spark.Search$$anonfun$getMatch2$1, name: $outer, type: class com.cjing.spark.Search)
	- object (class com.cjing.spark.Search$$anonfun$getMatch2$1, <function1>)
	at org.apache.spark.serializer.SerializationDebugger$.improveException(SerializationDebugger.scala:40)
	at org.apache.spark.serializer.JavaSerializationStream.writeObject(JavaSerializer.scala:46)
	at org.apache.spark.serializer.JavaSerializerInstance.serialize(JavaSerializer.scala:100)
	at org.apache.spark.util.ClosureCleaner$.ensureSerializable(ClosureCleaner.scala:295)
	... 12 more
def getMatch2(rdd: RDD[String]) = {
    rdd.filter(x => x.contains(query))
}
```

- 在这个方法中所调用的方法query是定义在Search这个类中的字段，实际上调用的是this. query，this表示Search这个类的对象，程序在运行过程中需要将Search对象序列化以后从Driver端传递到Executor端
- 这里也可以在getMatch2中定义一个局部变量q，令q=query，这样就变成传递一个字符串，而字符串本身已经实现了序列化

## 2.6 RDD依赖关系

### 2.6.1 Lineage

- RDD只支持粗粒度转换，即在大量记录上执行的单个操作。将创建RDD的一系列Lineage（血统）记录下来，以便恢复丢失的分区。RDD的Lineage会记录RDD的元数据信息和转换行为，当该RDD的部分分区数据丢失时，它可以根据这些信息来重新运算和恢复丢失的数据分区

```scala
scala> val rdd1 = sc.makeRDD(1 to 10)
rdd1: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[0] at makeRDD at <console>:24

scala> val rdd2 = rdd1.map((_,1))
rdd2: org.apache.spark.rdd.RDD[(Int, Int)] = MapPartitionsRDD[1] at map at <console>:26

scala> val rdd3 = rdd2.reduceByKey(_+_)
rdd3: org.apache.spark.rdd.RDD[(Int, Int)] = ShuffledRDD[2] at reduceByKey at <console>:28

scala> rdd3.toDebugString
res0: String =
(2) ShuffledRDD[2] at reduceByKey at <console>:28 []
 +-(2) MapPartitionsRDD[1] at map at <console>:26 []
    |  ParallelCollectionRDD[0] at makeRDD at <console>:24 []

scala> rdd3.dependencies
res1: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@536905ed)
```

- RDD和它依赖的父RDD（s）的关系有两种不同的类型，即窄依赖（narrow dependency）和宽依赖（wide dependency）

### 2.6.2 窄依赖

- 窄依赖指的是每一个父RDD的Partition最多被子RDD的一个Partition使用，窄依赖我们形象的比喻为独生子女

![111](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181007307.png)

### 2.6.3 宽依赖

- 宽依赖指的是多个子RDD的Partition会依赖同一个父RDD的Partition，会引起**`shuffle，`**总结：宽依赖我们形象的比喻为超生

![222](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181006060.png)

### 2.6.4 DAG（重点）

- DAG（Directed Acyclic Graph）叫做有向无环图，原始的RDD通过一系列的转换就形成了DAG，根据RDD之间的依赖关系的不同将DAG划分成不同的Stage，对于窄依赖，partition的转换处理在Stage中完成计算。对于宽依赖，由于有Shuffle的存在，只能在parent RDD处理完成后，才能开始接下来的计算，因此`宽依赖`是划分Stage的依据

![12](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181007238.png)

### 2.6.5 任务划分（面试重点）

- RDD任务切分中间分为：Application、Job、Stage和Task
  - Application：初始化一个SparkContext即生成一个Application（会有一个ApplicationMaster，一个类创建或初始化了一个SparkContext就称为Driver类）
  - Job：一个Action算子就会生成一个Job（ActiveJob）
  - Stage：根据RDD之间的依赖关系的不同将Job划分成不同的Stage，遇到一个宽依赖则划分一个Stage
  - Task：Stage是一个TaskSet，将Stage划分的结果发送到不同的Executor执行即为一个Task
    - 同一 阶段中到底有多少个Task取决于它最后的这个RDD中的分区数
  - Application->Job->Stage-> Task每一层都是1对n的关系
    - 一个main方法中会有多个Action算子，每个Action算子对应一个Job，所以Application和Job是1对n的关系
    - 一个Job中会根据RDD之间的依赖关系划分成不同的State，所以Job和State是1对n的关系
    - 一个State中最后的这个RDD的分区数有多个，所以State和Task是1对n的关系

![13](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181007474.png)

![14](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181007061.png)

## 2.7 RDD缓存

- RDD通过persist方法或cache方法可以将前面的计算结果缓存，默认情况下 persist() 会把数据以序列化的形式缓存在 JVM 的堆空间中
- 但是并不是这两个方法被调用时立即缓存，而是触发后面的action时，该RDD将会被缓存在计算节点的内存中，并供后面重用

```scala
// 通过查看源码发现cache最终也是调用了persist方法
// 区别在于persist方法是可以传递参数的（存储级别：默认的是MEMORY_ONLY）

def persist(): this.type = persist(StorageLevel.MEMEORY_ONLY)
def cache(): this.type = persist()

// 默认的存储级别都是仅在内存存储一份，Spark的存储级别还有好多种
// 存储级别在object StorageLevel中定义的
// 在存储级别的末尾加上“_2”来把持久化数据存为两份
object StorageLevel {
  val NONE = new StorageLevel(false, false, false, false)
  val DISK_ONLY = new StorageLevel(true, false, false, false)
  val DISK_ONLY_2 = new StorageLevel(true, false, false, false, 2)
  val MEMORY_ONLY = new StorageLevel(false, true, false, true)
  val MEMORY_ONLY_2 = new StorageLevel(false, true, false, true, 2)
  val MEMORY_ONLY_SER = new StorageLevel(false, true, false, false) //序列化
  val MEMORY_ONLY_SER_2 = new StorageLevel(false, true, false, false, 2)
  val MEMORY_AND_DISK = new StorageLevel(true, true, false, true)
  val MEMORY_AND_DISK_2 = new StorageLevel(true, true, false, true, 2)
  val MEMORY_AND_DISK_SER = new StorageLevel(true, true, false, false)
  val MEMORY_AND_DISK_SER_2 = new StorageLevel(true, true, false, false, 2)
  val OFF_HEAP = new StorageLevel(true, true, true, false, 1) //堆外内存
```

| 级别                | 使用的空间 | CPU时间 | 是否在内存中 | 是否在磁盘上 | 备注                                                         |
| ------------------- | ---------- | ------- | ------------ | ------------ | ------------------------------------------------------------ |
| MEMORY_ONLY         | 高         | 低      | 是           | 否           |                                                              |
| MEMORY_ONLY_SER     | 低         | 高      | 是           | 否           |                                                              |
| MEMORY_AND_DISK     | 高         | 中等    | 部分         | 部分         | 如果数据在内存中放不下，则溢写到磁盘上                       |
| MEMORY_AND_DISK_SER | 低         | 高      | 部分         | 部分         | 如果数据在内存中放不下，则溢写到磁盘上，在内存中存放序列化后的数据 |
| DISK_ONLY           | 低         | 高      | 否           | 是           |                                                              |

- 缓存有可能丢失，或者存储于内存的数据由于内存不足而被删除，RDD的缓存容错机制保证了即使缓存丢失也能保证计算的正确执行。通过基于RDD的一系列转换，丢失的数据会被重算，由于RDD的各个Partition是相对独立的，因此只需要计算丢失的部分即可，并不需要重算全部Partition
- 因此，即使使用了cache也会保留RDD的血缘关系，防止cache失效

```scala
scala> val rdd = sc.makeRDD(Array("atguigu"))
rdd: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[3] at makeRDD at <console>:24

scala> val nocache = rdd.map(_.toString+System.currentTimeMillis)
nocache: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[4] at map at <console>:26

scala> nocache.collect
res1: Array[String] = Array(atguigu1595420849096)

scala> nocache.collect
res2: Array[String] = Array(atguigu1595420849955)

scala> nocache.collect
res3: Array[String] = Array(atguigu1595420851215)

scala> val cache =  rdd.map(_.toString+System.currentTimeMillis).cache
cache: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[5] at map at <console>:26

scala> cache.collect
res4: Array[String] = Array(atguigu1595420866463)

scala> cache.collect
res5: Array[String] = Array(atguigu1595420866463)

scala> cache.collect
res6: Array[String] = Array(atguigu1595420866463)
```

## 2.8 RDD CheckPoint

- Spark中对于数据的保存除了持久化操作之外，还提供了一种检查点的机制，检查点（本质是通过将RDD写入Disk做检查点）是为了通过lineage做容错的辅助，lineage过长会造成容错成本过高，这样就不如在中间阶段做检查点容错，如果之后有节点出现问题而丢失分区，从做检查点的RDD开始重做Lineage，就会减少开销。检查点通过将数据写入到HDFS文件系统实现了RDD的检查点功能。
- 为当前RDD设置检查点。该函数将会创建一个二进制的文件，并存储到checkpoint目录中，该目录是用SparkContext.setCheckpointDir()设置的。
- `在checkpoint的过程中，该RDD的所有依赖于父RDD中的信息将全部被移除。对RDD进行checkpoint操作并不会马上被执行，必须执行Action操作才能触发`

# 三、键值对RDD数据分区器

> Spark目前支持Hash分区和Range分区，用户也可以自定义分区，Hash分区为当前的默认分区，Spark中分区器直接决定了RDD中分区的个数、RDD中每条数据经过Shuffle过程属于哪个分区和Reduce的个数

- 注意
  - 只有Key-Value类型的RDD才有分区器的，非Key-Value类型的RDD分区器的值是None
  - 每个RDD的分区ID范围：0~numPartitions-1，决定这个值是属于那个分区的

## 3.1 获取RDD分区

- 可以通过使用RDD的partitioner 属性来获取 RDD 的分区方式。它会返回一个 scala.Option 对象， 通过get方法获取其中的值

```scala
def getPartition(key: Any): Int = key match {
  case null => 0
  case _ => Utils.nonNegativeMod(key.hashCode, numPartitions)
}
def nonNegativeMod(x: Int, mod: Int): Int = {
  val rawMod = x % mod
  rawMod + (if (rawMod < 0) mod else 0)
}

scala> val pairs = sc.parallelize(List((1,1),(2,2),(3,3)))
pairs: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[6] at parallelize at <console>:24

scala> pairs.partitioner
res7: Option[org.apache.spark.Partitioner] = None

scala> import org.apache.spark.HashPartitioner
import org.apache.spark.HashPartitioner

scala> val partitioned = pairs.partitionBy(new HashPartitioner(2))
partitioned: org.apache.spark.rdd.RDD[(Int, Int)] = ShuffledRDD[7] at partitionBy at <console>:27

scala> partitioned.partitioner
res8: Option[org.apache.spark.Partitioner] = Some(org.apache.spark.HashPartitioner@2)
```

## 3.2 Hash分区

- HashPartitioner分区的原理：对于给定的key，计算其hashCode，并除以分区的个数取余，如果余数小于0，则用余数+分区的个数（否则加0），最后返回的值就是这个key所属的分区ID

```scala
scala> val nopar = sc.parallelize(List((1,3),(1,2),(2,4),(2,3),(3,6),(3,8)),8)
nopar: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[8] at parallelize at <console>:25

scala> nopar.mapPartitionsWithIndex((index,iter)=>{ Iterator(index.toString+" : "+iter.mkString("|")) }).collect
res9: Array[String] = Array("0 : ", 1 : (1,3), 2 : (1,2), 3 : (2,4), "4 : ", 5 : (2,3), 6 : (3,6), 7 : (3,8))

scala> val hashpar = nopar.partitionBy(new org.apache.spark.HashPartitioner(7))
hashpar: org.apache.spark.rdd.RDD[(Int, Int)] = ShuffledRDD[10] at partitionBy at <console>:27

scala>  hashpar.count
res10: Long = 6

scala> hashpar.partitioner
res11: Option[org.apache.spark.Partitioner] = Some(org.apache.spark.HashPartitioner@7)

scala> hashpar.mapPartitions(iter => Iterator(iter.length)).collect()
res12: Array[Int] = Array(0, 2, 2, 2, 0, 0, 0)
```

## 3.3 Ranger分区

- HashPartitioner分区弊端：可能导致每个分区中数据量的不均匀（数据倾斜），极端情况下会导致某些分区拥有RDD的全部数据
- RangePartitioner作用：将一定范围内的数映射到某一个分区内，尽量保证每个分区中数据量的均匀，而且分区与分区之间是有序的，一个分区中的元素肯定都是比另一个分区内的元素小或者大，但是分区内的元素是不能保证顺序的。简单的说就是将一定范围内的数映射到某一个分区内。实现过程为：
  - 第一步：先从整个RDD中抽取出样本数据，将样本数据排序，计算出每个分区的最大key值，形成一个Array[KEY]类型的数组变rangeBounds
  - 第二步：判断key在rangeBounds中所处的范围，给出该key值在下一个RDD中的分区id下标；该分区器要求RDD中的KEY类型必须是可以排序的
- 在spark中使用的很少，因为要使用Ranger分区就必须保证数据是可以排序的，并且可以比较，所以有这个限制在里面

## 3.4 自定义分区

- 要实现自定义的分区器，你需要继承 org.apache.spark.Partitioner 类并实现下面三个方法
  - numPartitions: Int:返回创建出来的分区数
  - getPartition(key: Any): Int:返回给定键的分区编号(0到numPartitions-1)
  - equals():Java 判断相等性的标准方法。这个方法的实现非常重要，Spark 需要用这个方法来检查你的分区器对象是否和其他分区器实例相同，这样 Spark 才可以判断两个 RDD 的分区方式是否相同

```scala
scala> val data = sc.parallelize(Array((1,1),(2,2),(3,3),(4,4),(5,5),(6,6)))
data: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[12] at parallelize at <console>:25

scala> :paste
// Entering paste mode (ctrl-D to finish)

class CustomerPartitioner(numParts:Int) extends org.apache.spark.Partitioner{

  //覆盖分区数
  override def numPartitions: Int = numParts

  //覆盖分区号获取函数
  override def getPartition(key: Any): Int = {
    val ckey: String = key.toString
    ckey.substring(ckey.length-1).toInt%numParts
  }
}

// Exiting paste mode, now interpreting.

defined class CustomerPartitioner

scala> val par = data.partitionBy(new CustomerPartitioner(2))
par: org.apache.spark.rdd.RDD[(Int, Int)] = ShuffledRDD[13] at partitionBy at <console>:28

scala> par.mapPartitionsWithIndex((index,items)=>items.map((index,_))).collect
res13: Array[(Int, (Int, Int))] = Array((0,(2,2)), (0,(4,4)), (0,(6,6)), (1,(1,1)), (1,(3,3)), (1,(5,5)))
```

- 使用自定义的 Partitioner 是很容易的:只要把它传给 partitionBy() 方法即可。Spark 中有许多依赖于数据混洗的方法，比如 join() 和 groupByKey()，它们也可以接收一个可选的 Partitioner 对象来控制输出数据的分区方式

# 四、数据读取与保存

- Spark的数据读取及数据保存可以从两个维度来作区分：
  - 文件格式
    - Text文件
    - Json文件
    - Csv文件
    - Sequence文件
    - Object文件
  - 文件系统
    - 本地文件系统
    - HDFS
    - HBASE
    - 数据库

## 4.1 文件类数据读取与保存

- **Text文件**

  ```scala
  // 数据读取
  scala> val hdfsFile = sc.textFile("hdfs://hadoop102:9000/fruit.txt")
  hdfsFile: org.apache.spark.rdd.RDD[String] = hdfs://hadoop102:9000/fruit.txt MapPartitionsRDD[21] at textFile at <console>:24
  // 数据保存
  scala> hdfsFile.saveAsTextFile("/fruitOut")
  ```

- **Json文件**

  - 如果JSON文件中每一行就是一个JSON记录，那么可以通过将JSON文件当做文本文件来读取，然后利用相关的JSON库对每一条数据进行JSON解析
  - 注意：使用RDD读取JSON文件处理很复杂，同时SparkSQL集成了很好的处理JSON文件的方式，所以应用中多是采用SparkSQL处理JSON文件

  ```scala
  import org.apache.spark.rdd.RDD
  import org.apache.spark.{SparkConf, SparkContext}
  import scala.util.parsing.json.JSON
  
  object Spark06 {
  
      def main(args: Array[String]): Unit = {
          val conf = new SparkConf().setMaster("local[*]").setAppName("Spark06")
          val sc = new SparkContext(conf)
  
          val json = sc.textFile("in/people.json")
          val result  = json.map(JSON.parseFull)
          result.foreach(println)
      }
  }
  
  // people.json
  {"username": "user1", "age": 1}
  {"username": "user2", "age": 2}
  {"username": "user3", "age": 3}
  {"username": "user4", "age": 4}
  
  // 执行结果
  Some(Map(username -> user1, age -> 1.0))
  Some(Map(username -> user4, age -> 4.0))
  Some(Map(username -> user2, age -> 2.0))
  Some(Map(username -> user3, age -> 3.0))
  ```

- **Sequence文件**

  - SequenceFile文件是Hadoop用来存储二进制形式的key-value对而设计的一种平面文件(Flat File)。Spark 有专门用来读取 SequenceFile 的接口。在 SparkContext 中，可以调用 sequenceFile[ keyClass, valueClass](path)
  - 注意：SequenceFile文件只针对PairRDD

- **对象文件**

  - 对象文件是将对象序列化后保存的文件，采用Java的序列化机制。可以通过objectFile[k,v]函数接收一个路径，读取对象文件，返回对应的 RDD，也可以通过调用saveAsObjectFile() 实现对对象文件的输出。因为是序列化所以要指定类型

## 4.2 文件系统类数据读取与保存

- **HDFS**

  - Spark的整个生态系统与Hadoop是完全兼容的,所以对于Hadoop所支持的文件类型或者数据库类型,Spark也同样支持.另外,由于Hadoop的API有新旧两个版本,所以Spark为了能够兼容Hadoop所有的版本,也提供了两套创建操作接口.对于外部存储创建操作而言,hadoopRDD和newHadoopRDD是最为抽象的两个函数接口,主要包含以下四个参数.
    - 输入格式(InputFormat): 制定数据输入的类型,如TextInputFormat等,新旧两个版本所引用的版本分别是org.apache.hadoop.mapred.InputFormat和org.apache.hadoop.mapreduce.InputFormat(NewInputFormat)
    - 键类型: 指定[K,V]键值对中K的类型
    - 值类型: 指定[K,V]键值对中V的类型
    - 分区值: 指定由外部存储生成的RDD的partition数量的最小值,如果没有指定,系统会使用默认值defaultMinSplits

- **MySQL数据库连接**

  ```scala
  package com.atguigu
  
  import java.sql.DriverManager
  
  import org.apache.spark.rdd.JdbcRDD
  import org.apache.spark.{SparkConf, SparkContext}
  
  object MysqlRDD {
  
   def main(args: Array[String]): Unit = {
  
     //1.创建spark配置信息
     val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("JdbcRDD")
  
     //2.创建SparkContext
     val sc = new SparkContext(sparkConf)
  
     //3.定义连接mysql的参数
     val driver = "com.mysql.jdbc.Driver"
     val url = "jdbc:mysql://hadoop102:3306/rdd"
     val userName = "root"
     val passWd = "000000"
  
     //创建JdbcRDD
     val rdd = new JdbcRDD(sc, () => {
       Class.forName(driver)
       DriverManager.getConnection(url, userName, passWd)
     },
       "select * from `rddtable` where `id`>=?;",
       1,
       10,
       1,
       r => (r.getInt(1), r.getString(2))
     )
  
  	 //打印最后结果
     println(rdd.count())
     rdd.foreach(println)
  
     sc.stop()
   }
  }
  
  // MySql写入
  def main(args: Array[String]) {
    val sparkConf = new SparkConf().setMaster("local[2]").setAppName("HBaseApp")
    val sc = new SparkContext(sparkConf)
    val data = sc.parallelize(List("Female", "Male","Female"))
  
    data.foreachPartition(insertData)
  }
  
  def insertData(iterator: Iterator[String]): Unit = {
  Class.forName ("com.mysql.jdbc.Driver").newInstance()
    val conn = java.sql.DriverManager.getConnection("jdbc:mysql://hadoop102:3306/rdd", "root", "000000")
    iterator.foreach(data => {
      val ps = conn.prepareStatement("insert into rddtable(name) values (?)")
      ps.setString(1, data) 
      ps.executeUpdate()
    })
  }
  ```

- **HBase数据库**

  ```scala
  package com.atguigu
  
  import org.apache.hadoop.conf.Configuration
  import org.apache.hadoop.hbase.HBaseConfiguration
  import org.apache.hadoop.hbase.client.Result
  import org.apache.hadoop.hbase.io.ImmutableBytesWritable
  import org.apache.hadoop.hbase.mapreduce.TableInputFormat
  import org.apache.spark.rdd.RDD
  import org.apache.spark.{SparkConf, SparkContext}
  import org.apache.hadoop.hbase.util.Bytes
  
  object HBaseSpark {
  
    def main(args: Array[String]): Unit = {
  
      //创建spark配置信息
      val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("JdbcRDD")
  
      //创建SparkContext
      val sc = new SparkContext(sparkConf)
  
      //构建HBase配置信息
      val conf: Configuration = HBaseConfiguration.create()
      conf.set("hbase.zookeeper.quorum", "hadoop102,hadoop103,hadoop104")
      conf.set(TableInputFormat.INPUT_TABLE, "rddtable")
  
      //从HBase读取数据形成RDD
      val hbaseRDD: RDD[(ImmutableBytesWritable, Result)] = sc.newAPIHadoopRDD(
        conf,
        classOf[TableInputFormat],
        classOf[ImmutableBytesWritable],
        classOf[Result])
  
      val count: Long = hbaseRDD.count()
      println(count)
  
      //对hbaseRDD进行处理
      hbaseRDD.foreach {
        case (_, result) =>
          val key: String = Bytes.toString(result.getRow)
          val name: String = Bytes.toString(result.getValue(Bytes.toBytes("info"), Bytes.toBytes("name")))
          val color: String = Bytes.toString(result.getValue(Bytes.toBytes("info"), Bytes.toBytes("color")))
          println("RowKey:" + key + ",Name:" + name + ",Color:" + color)
      }
  
      //关闭连接
      sc.stop()
    }
  
  }
  
  // HBase写入
  def main(args: Array[String]) {
  //获取Spark配置信息并创建与spark的连接
    val sparkConf = new SparkConf().setMaster("local[*]").setAppName("HBaseApp")
  	val sc = new SparkContext(sparkConf)
  
  //创建HBaseConf
    val conf = HBaseConfiguration.create()
    val jobConf = new JobConf(conf)
    jobConf.setOutputFormat(classOf[TableOutputFormat])
    jobConf.set(TableOutputFormat.OUTPUT_TABLE, "fruit_spark")
  
  //构建Hbase表描述器
    val fruitTable = TableName.valueOf("fruit_spark")
    val tableDescr = new HTableDescriptor(fruitTable)
    tableDescr.addFamily(new HColumnDescriptor("info".getBytes))
  
  //创建Hbase表
    val admin = new HBaseAdmin(conf)
    if (admin.tableExists(fruitTable)) {
      admin.disableTable(fruitTable)
      admin.deleteTable(fruitTable)
    }
    admin.createTable(tableDescr)
  
  //定义往Hbase插入数据的方法
    def convert(triple: (Int, String, Int)) = {
      val put = new Put(Bytes.toBytes(triple._1))
      put.addImmutable(Bytes.toBytes("info"), Bytes.toBytes("name"), Bytes.toBytes(triple._2))
      put.addImmutable(Bytes.toBytes("info"), Bytes.toBytes("price"), Bytes.toBytes(triple._3))
      (new ImmutableBytesWritable, put)
    }
  
  //创建一个RDD
    val initialRDD = sc.parallelize(List((1,"apple",11), (2,"banana",12), (3,"pear",13)))
  
  //将RDD内容写到HBase
    val localData = initialRDD.map(convert)
  
    localData.saveAsHadoopDataset(jobConf)
  }
  ```

# 五、RDD编程进阶

## 5.1 累加器

- 累加器用来对信息进行聚合，通常在向 Spark传递函数时，比如使用 map() 函数或者用 filter() 传条件时，可以使用驱动器程序中定义的变量，但是集群中运行的每个任务都会得到这些变量的一份新的副本，更新这些副本的值也不会影响驱动器中的对应变量。如果我们想实现所有分片处理时更新共享变量的功能，那么累加器可以实现我们想要的效果

- **系统累加器**

  - 通过在驱动器中调用SparkContext.accumulator(initialValue)方法，创建出存有初始值的累加器。返回值为 org.apache.spark.Accumulator[T] 对象，其中 T 是初始值 initialValue 的类型。Spark闭包里的执行器代码可以使用累加器的 += 方法(在Java中是 add)增加累加器的值。 驱动器程序可以调用累加器的value属性(在Java中使用value()或setValue())来访问累加器的值
  - 注意：工作节点上的任务不能访问累加器的值。从这些任务的角度来看，累加器是一个只写变量
  - 对于要在行动操作中使用的累加器，Spark只会把每个任务对各累加器的修改应用一次。因此，如果想要一个无论在失败还是重复计算时都绝对可靠的累加器，我们必须把它放在 foreach() 这样的行动操作中。转化操作中累加器可能会发生不止一次更新

  ```scala
  def main(args: Array[String]): Unit = {
          val conf = new SparkConf().setMaster("local[*]").setAppName("Spark08_ShareData")
          val sc = new SparkContext(conf)
  
          val dataRDD: RDD[Int] = sc.makeRDD(List(1,2,3,4),2)
  
          // 使用累加器来共享变量，来累加数据
          // 创建累加器对象
          val accumulator: LongAccumulator = sc.longAccumulator
  
          dataRDD.foreach(accumulator.add(_))
          
          // 获取累加器的值
          println(accumulator.value)
  
          sc.stop()
      }
  ```

- **自定义累加器**

  - 自定义累加器类型的功能在1.X版本中就已经提供了，但是使用起来比较麻烦，在2.0版本后，累加器的易用性有了较大的改进，而且官方还提供了一个新的抽象类：AccumulatorV2来提供更加友好的自定义类型累加器的实现方式。实现自定义类型累加器需要继承AccumulatorV2并至少覆写下例中出现的方法，下面这个累加器可以用于在程序运行过程中收集一些文本类信息，最终以Set[String]的形式返回

  ```scala
  object Spark09_Accumulator {
  
      def main(args: Array[String]): Unit = {
          val conf = new SparkConf().setMaster("local[*]").setAppName("Spark09_Accumulator")
          val sc = new SparkContext(conf)
  
          // 创建累加器
          val accumulator = new WordAccumulator
          // 注册累加器
          sc.register(accumulator)
  
          val listRDD: RDD[String] = sc.makeRDD(List("hadoop", "hive", "hbase", "scala", "spark"), 2)
          listRDD.foreach(accumulator.add(_))
          
          println(accumulator.value)
  
          sc.stop()
      }
  }
  
  // 声明累加器
  // 1.继承AccumulatorV2
  // 2.实现抽象方法
  class WordAccumulator extends AccumulatorV2[String, util.ArrayList[String]] {
  
      val list = new util.ArrayList[String]()
  
      // 当前的累加器是否为初始化装填
      override def isZero: Boolean = list.isEmpty
  
      // 复制累加器对象
      override def copy(): AccumulatorV2[String, util.ArrayList[String]] = {
          new WordAccumulator()
      }
  
      // 重置累加器对象
      override def reset(): Unit = list.clear()
  
      // 向累加器中增加数据
      override def add(v: String): Unit = {
          if (v.contains("h")) {
              list.add(v)
          }
      }
  
      // 合并
      override def merge(other: AccumulatorV2[String, util.ArrayList[String]]): Unit = {
          list.addAll(other.value)
      }
  
      // 获取累加器的结果
      override def value: util.ArrayList[String] = list
  }
  ```

## 5.2 广播变量（调优策略）

- 广播变量用来高效分发较大的对象。向所有工作节点发送一个较大的只读值，以供一个或多个Spark操作使用。比如，如果你的应用需要向所有节点发送一个较大的只读查询表，甚至是机器学习算法中的一个很大的特征向量，广播变量用起来都很顺手。 在多个并行操作中使用同一个变量，但是 Spark会为每个任务分别发送

```scala
scala> val broadcastVar = sc.broadcast(Array(1, 2, 3))
broadcastVar: org.apache.spark.broadcast.Broadcast[Array[Int]] = Broadcast(35)

scala> broadcastVar.value
res33: Array[Int] = Array(1, 2, 3)
```

- 使用广播变量的过程如下：
  - 通过对一个类型 T 的对象调用 SparkContext.broadcast 创建出一个 Broadcast[T] 对象。 任何可序列化的类型都可以这么实现
  - 通过 value 属性访问该对象的值(在 Java 中为 value() 方法)
  - 变量只会被发到各个节点一次，应作为只读值处理(修改这个值不会影响到别的节点)

# 六、扩展

## 6.1 RDD相关概念关系

![15](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181009621.png)

- 输入可能以多个文件的形式存储在HDFS上，每个File都包含了很多块，称为Block。当Spark读取这些文件作为输入时，会根据具体数据格式对应的InputFormat进行解析，一般是将若干个Block合并成一个输入分片，称为InputSplit，注意InputSplit不能跨越文件。随后将为这些输入分片生成具体的Task。InputSplit与Task是一一对应的关系。随后这些具体的Task每个都会被分配到集群上的某个节点的某个Executor去执行。
  - 每个节点可以起一个或多个Executor
  - 每个Executor由若干core组成，每个Executor的每个core一次只能执行一个Task
  - 每个Task执行的结果就是生成了目标RDD的一个partiton
- 注意: 这里的core是虚拟的core而不是机器的物理CPU核，可以理解为就是Executor的一个工作线程。而 Task被执行的并发度 = Executor数目 * 每个Executor核数。至于partition的数目：
  - 对于数据读入阶段，例如textFile，输入文件被划分为多少InputSplit就会需要多少初始Task
  - 在Map阶段partition数目保持不变
  - 在Reduce阶段，RDD的聚合会触发shuffle操作，聚合后的RDD的partition数目跟具体操作有关，例如repartition操作会聚合成指定分区数，还有一些算子是可配置的
- RDD在计算的时候，每个分区都会起一个task，所以rdd的分区数目决定了总的的task数目。申请的计算节点（Executor）数目和每个计算节点核数，决定了你同一时刻可以并行执行的task。
- 比如的RDD有100个分区，那么计算的时候就会生成100个task，你的资源配置为10个计算节点，每个两2个核，同一时刻可以并行的task数目为20，计算这个RDD就需要5个轮次。如果计算资源不变，你有101个task的话，就需要6个轮次，在最后一轮中，只有一个task在执行，其余核都在空转。如果资源不变，你的RDD只有2个分区，那么同一时刻只有2个task运行，其余18个核空转，造成资源浪费。这就是在spark调优中，增大RDD分区数目，增大任务并行度的做法。