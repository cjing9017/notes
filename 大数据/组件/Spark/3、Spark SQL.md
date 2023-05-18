# 一、Spark SQL概述

## 1.1 什么是Spark SQL

- Spark SQL是Spark用来处理结构化数据的一个模块，它提供了2个编程抽象：DataFrame和DataSet，并且作为分布式SQL查询引擎的作用
- Hive它是将Hive SQL转换成MapReduce然后提交到集群上执行，大大简化了编写MapReduc的程序的复杂性，由于MapReduce这种计算模型执行效率比较慢。所有Spark SQL的应运而生，它是将Spark SQL转换成RDD，然后提交到集群执行，执行效率非常快！
- 原来的RDD是没有结构的，所以Spark SQL中增加了结构，从而提供了两个编程抽象：DataFrame和DataSet
- RDD是DataFrame和DataSet的底层抽象

## 1.2 Spark SQL的特点

- 易整合
- 统一的数据访问方式
- 兼容Hive
- 标准的数据连接

## 1.3 什么是DataFrame

- 与RDD类似，DataFrame也是一个分布式数据容器。然而DataFrame更像传统数据库的二维表格，除了数据以外，还记录数据的结构信息，即schema。同时，与Hive类似，DataFrame也支持嵌套数据类型（struct、array和map）。从API易用性的角度上看，DataFrame API提供的是一套高层的关系操作，比函数式的RDD API要更加友好，门槛更低

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181011009.png)

- 上图直观地体现了DataFrame和RDD的区别。左侧的RDD[Person]虽然以Person为类型参数，但Spark框架本身不了解Person类的内部结构。而右侧的DataFrame却提供了详细的结构信息，使得Spark SQL可以清楚地知道该数据集中包含哪些列，每列的名称和类型各是什么。DataFrame是为数据提供了Schema的视图。可以把它当做数据库中的一张表来对待，DataFrame也是懒执行的
- 性能上比RDD要高，主要原因：优化的执行计划，查询计划通过Spark catalyst optimiser进行优化

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181011878.png)

- 为了说明查询优化，我们来看上图展示的人口数据分析的示例。图中构造了两个DataFrame，将它们join之后又做了一次filter操作。如果原封不动地执行这个执行计划，最终的执行效率是不高的。因为join是一个代价较大的操作，也可能会产生一个较大的数据集。如果我们能将filter下推到 join下方，先对DataFrame进行过滤，再join过滤后的较小的结果集，便可以有效缩短执行时间。而Spark SQL的查询优化器正是这样做的。简而言之，逻辑查询计划优化就是一个利用基于关系代数的等价变换，将高成本的操作替换为低成本操作的过程。

## 1.4 什么是DataSet

- 是Dataframe API的一个扩展，是Spark最新的数据抽象
- 用户友好的API风格，既具有类型安全检查也具有Dataframe的查询优化特性
- Dataset支持编解码器，当需要访问非堆上的数据时可以避免反序列化整个对象，提高了效率
- 样例类被用来在Dataset中定义数据的结构信息，样例类中每个属性的名称直接映射到DataSet中的字段名称
- Dataframe是Dataset的特列，DataFrame=Dataset[Row] ，所以可以通过as方法将Dataframe转换为Dataset。Row是一个类型，跟Car、Person这些的类型一样，所有的表结构信息我都用Row来表示
- DataSet是强类型的。比如可以有Dataset[Car]，Dataset[Person]
- DataFrame只是知道字段，但是不知道字段的类型，所以在执行这些操作的时候是没办法在编译的时候检查是否类型失败的，比如你可以对一个String进行减法操作，在执行的时候才报错，而DataSet不仅仅知道字段，而且知道字段类型，所以有更严格的错误检查。就跟JSON对象和类对象之间的类比

# 二、Spark SQL编程

## 2.1 SparkSession新的起始点

- 在老的版本中，SparkSQL提供两种SQL查询起始点：一个叫SQLContext，用于Spark自己提供的SQL查询；一个叫HiveContext，用于连接Hive的查询
- SparkSession是Spark最新的SQL查询起始点，实质上是SQLContext和HiveContext的组合，所以在SQLContext和HiveContext上可用的API在SparkSession上同样是可以使用的。SparkSession内部封装了sparkContext，所以计算实际上是由sparkContext完成的

## 2.2 DataFrame

- **创建**

  - 在Spark SQL中SparkSession是创建DataFrame和执行SQL的入口，创建DataFrame有三种方式：

    - 通过Spark的数据源进行创建

    ```scala
    // Spark数据源进行创建的文件格式
    scala> spark.read.
    csv      jdbc   load     options   parquet   table   textFile      
    format   json   option   orc       schema    text
    
    // 读取json文件创建DataFrame
    scala> val df = spark.read.json("file:///opt/module/spark/input/2.json")
    df: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
    
    scala> df.show
    +---+-----+
    |age| name|
    +---+-----+
    | 20|chen1|
    | 20|chen2|
    | 20|chen3|
    +---+-----+
    
    // 创建临时视图
    scala> df.createTempView("student")
    
    // 利用SQL语句查询数据
    scala> spark.sql("select * from student").show
    +---+-----+
    |age| name|
    +---+-----+
    | 20|chen1|
    | 20|chen2|
    | 20|chen3|
    +---+-----+
    ```

    - 从一个存在的RDD进行转换
    - 还可以从Hive Table进行查询返回

- **SQL风格语法**

  ```scala
  // 创建一个DataFrame
  scala> val df = spark.read.json("/opt/module/spark/examples/src/main/resources/people.json")
  df: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
  
  // 对DataFrame创建一个临时表
  scala> df.createOrReplaceTempView("people")
  
  // 通过SQL语句实现查询全表
  scala> val sqlDF = spark.sql("SELECT * FROM people")
  sqlDF: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
  
  // 结果展示
  scala> sqlDF.show
  +----+-------+
  | age|   name|
  +----+-------+
  |null|Michael|
  |  30|   Andy|
  |  19| Justin|
  +----+-------+
  
  // 注意：临时表是Session范围内的，Session退出后，表就失效了
  // 如果想应用范围内有效，可以使用全局表
  // 注意使用全局表时需要全路径访问，如：global_temp.people
  // 对于DataFrame创建一个全局表
  scala> df.createGlobalTempView("people")
  
  // 通过SQL语句实现查询全表
  scala> spark.sql("SELECT * FROM global_temp.people").show()
  +----+-------+
  | age|   name|
  +----+-------+
  |null|Michael|
  |  30|   Andy|
  |  19| Justin|
  
  scala> spark.newSession().sql("SELECT * FROM global_temp.people").show()
  +----+-------+
  | age|   name|
  +----+-------+
  |null|Michael|
  |  30|   Andy|
  |  19| Justin|
  +----+-------+
  ```

- **DSL风格语法**

  ```scala
  // 创建一个DateFrame
  scala> spark.read.
  csv   format   jdbc   json   load   option   options   orc   parquet   schema   table   text   textFile
  
  // 查看DataFrame的Schema信息
  scala> df.printSchema
  root
   |-- age: long (nullable = true)
   |-- name: string (nullable = true)
  
  // 只查看”name”列数据
  scala> df.select("name").show()
  +-------+
  |   name|
  +-------+
  |Michael|
  |   Andy|
  | Justin|
  +-------+
  
  // 查看”name”列数据以及”age+1”数据
  scala> df.select($"name", $"age" + 1).show()
  +-------+---------+
  |   name|(age + 1)|
  +-------+---------+
  |Michael|     null|
  |   Andy|       31|
  | Justin|       20|
  +-------+---------+
  
  // 查看”age”大于”21”的数据
  scala> df.filter($"age" > 21).show()
  +---+----+
  |age|name|
  +---+----+
  | 30|Andy|
  +---+----+
  
  // 按照”age”分组，查看数据条数
  scala> df.groupBy("age").count().show()
  +----+-----+
  | age|count|
  +----+-----+
  |  19|     1|
  |null|     1|
  |  30|     1|
  +----+-----+
  ```

- **RDD转换为DataFrame**

  ```scala
  // 注意：如果需要RDD与DF或者DS之间操作
  // 那么都需要引入 import spark.implicits._ 
  //【spark不是包名，而是sparkSession对象的名称】
  // 前置条件：导入隐式转换并创建一个RDD
  scala> import spark.implicits._
  import spark.implicits._
  
  scala> val peopleRDD = sc.textFile("examples/src/main/resources/people.txt")
  peopleRDD: org.apache.spark.rdd.RDD[String] = examples/src/main/resources/people.txt MapPartitionsRDD[3] at textFile at <console>:27
  
  // 通过手动确定转换
  scala> peopleRDD.map{x=>val para = x.split(",");(para(0),para(1).trim.toInt)}.toDF("name","age")
  res1: org.apache.spark.sql.DataFrame = [name: string, age: int]
  
  // 通过反射确定（需要用到样例类）
  // 创建一个样例类
  scala> case class People(name:String, age:Int)
  
  // 根据样例类将RDD转换为DataFrame
  scala> peopleRDD.map{ x => val para = x.split(",");People(para(0),para(1).trim.toInt)}.toDF
  res2: org.apache.spark.sql.DataFrame = [name: string, age: int]
  
  // 通过编程的方式（了解）
  // 导入所需的类型
  scala> import org.apache.spark.sql.types._
  import org.apache.spark.sql.types._
  
  // 创建Schema
  scala> val structType: StructType = StructType(StructField("name", StringType) :: StructField("age", IntegerType) :: Nil)
  structType: org.apache.spark.sql.types.StructType = StructType(StructField(name,StringType,true), StructField(age,IntegerType,true))
  
  // 导入所需的类型
  scala> import org.apache.spark.sql.Row
  import org.apache.spark.sql.Row
  
  // 根据给定的类型创建二元组RDD
  scala> val data = peopleRDD.map{ x => val para = x.split(",");Row(para(0),para(1).trim.toInt)}
  data: org.apache.spark.rdd.RDD[org.apache.spark.sql.Row] = MapPartitionsRDD[6] at map at <console>:33
  
  // 根据数据及给定的schema创建DataFrame
  scala> val dataFrame = spark.createDataFrame(data, structType)
  dataFrame: org.apache.spark.sql.DataFrame = [name: string, age: int]
  ```

- **DataFrame转换为RDD**

  ```scala
  // 直接调用rdd即可
  // 创建一个DataFrame
  scala> val df = spark.read.json("/opt/module/spark/examples/src/main/resources/people.json")
  df: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
  
  // 将DataFrame转换为RDD
  scala> val dfToRDD = df.rdd
  dfToRDD: org.apache.spark.rdd.RDD[org.apache.spark.sql.Row] = MapPartitionsRDD[19] at rdd at <console>:29
  
  // 打印RDD
  scala> dfToRDD.collect
  res13: Array[org.apache.spark.sql.Row] = Array([Michael, 29], [Andy, 30], [Justin, 19])
  ```

## 2.3 DataSet

- **创建**

  ```scala
  1）创建一个样例类
  scala> case class Person(name: String, age: Long)
  defined class Person
  
  2）创建DataSet
  scala> val caseClassDS = Seq(Person("Andy", 32)).toDS()
  caseClassDS: org.apache.spark.sql.Dataset[Person] = [name: string, age: bigint]
  ```

- **RDD转换为DataSet**

  ```scala
  SparkSQL能够自动将包含有case类的RDD转换成DataFrame，case类定义了table的结构，case类属性通过反射变成了表的列名。
  1）创建一个RDD
  scala> val peopleRDD = sc.textFile("examples/src/main/resources/people.txt")
  peopleRDD: org.apache.spark.rdd.RDD[String] = examples/src/main/resources/people.txt MapPartitionsRDD[3] at textFile at <console>:27
  
  2）创建一个样例类
  scala> case class Person(name: String, age: Long)
  defined class Person
  
  3）将RDD转化为DataSet
  scala> peopleRDD.map(line => {val para = line.split(",");Person(para(0),para(1).trim.toInt)}).toDS()
  ```

- **DataSet转换为RDD**

  ```scala
  调用rdd方法即可
  1）创建一个DataSet
  scala> val DS = Seq(Person("Andy", 32)).toDS()
  DS: org.apache.spark.sql.Dataset[Person] = [name: string, age: bigint]
  
  2）将DataSet转换为RDD
  scala> DS.rdd
  res11: org.apache.spark.rdd.RDD[Person] = MapPartitionsRDD[15] at rdd at <console>:28
  ```

## 2.4 DataFrame与DataSet的互操作

- **DataSet转DataFrame**

  ```scala
  这个很简单，因为只是把case class封装成Row
  （1）导入隐式转换
  import spark.implicits._
  
  （2）转换
  val testDF = testDS.toDF
  ```

- **DataFrame转DataSet**

  ```scala
  1. DataFrame转换为DataSet
  1）创建一个DateFrame
  scala> val df = spark.read.json("examples/src/main/resources/people.json")
  df: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
  
  2）创建一个样例类
  scala> case class Person(name: String, age: Long)
  defined class Person
  
  3）将DateFrame转化为DataSet
  scala> df.as[Person]
  res14: org.apache.spark.sql.Dataset[Person] = [age: bigint, name: string]
  
  2. DataSet转换为DataFrame
  1）创建一个样例类
  scala> case class Person(name: String, age: Long)
  defined class Person
  
  2）创建DataSet
  scala> val ds = Seq(Person("Andy", 32)).toDS()
  ds: org.apache.spark.sql.Dataset[Person] = [name: string, age: bigint]
  
  3）将DataSet转化为DataFrame
  scala> val df = ds.toDF
  df: org.apache.spark.sql.DataFrame = [name: string, age: bigint]
  
  4）展示
  scala> df.show
  +----+---+
  |name|age|
  +----+---+
  |Andy| 32|
  +----+---+
  ```

## 2.5 RDD、DataFrame、DataSet

- 在SparkSQL中Spark为我们提供了两个新的抽象，分别是DataFrame和DataSet。他们和RDD有什么区别呢？首先从版本的产生上来看：

- RDD (Spark1.0) —> Dataframe(Spark1.3) —> Dataset(Spark1.6)

- 如果同样的数据都给到这三个数据结构，他们分别计算之后，都会给出相同的结果。不同是的他们的执行效率和执行方式。

- 在后期的Spark版本中，DataSet会逐步取代RDD和DataFrame成为唯一的API接口

- **三者的共性**

  - RDD、DataFrame、Dataset全都是spark平台下的分布式弹性数据集，为处理超大型数据提供便利
  - 三者都有惰性机制，在进行创建、转换，如map方法时，不会立即执行，只有在遇到Action如foreach时，三者才会开始遍历运算
  - 三者都会根据spark的内存情况自动缓存运算，这样即使数据量很大，也不用担心会内存溢出
  - 三者都有partition的概念
  - 三者有许多共同的函数，如filter，排序等
  - 在对DataFrame和Dataset进行操作许多操作都需要这个包进行支持import spark.implicits._
  - DataFrame和Dataset均可使用模式匹配获取各个字段的值和类型

  ```scala
  DataFrame:
  testDF.map{
        case Row(col1:String,col2:Int)=>
          println(col1);println(col2)
          col1
        case _=>
          ""
      }
  
  Dataset:
  case class Coltest(col1:String,col2:Int)extends Serializable //定义字段名和类型
      testDS.map{
        case Coltest(col1:String,col2:Int)=>
          println(col1);println(col2)
          col1
        case _=>
          ""
      }
  ```

- **三者的区别**

  ```scala
  1. RDD:
  	1）RDD一般和spark mlib同时使用
  	2）RDD不支持sparksql操作
  
  2. DataFrame:
  	1）与RDD和Dataset不同，DataFrame每一行的类型固定为Row
  每一列的值没法直接访问，只有通过解析才能获取各个字段的值，如：
  testDF.foreach{
    line =>
      val col1=line.getAs[String]("col1")
      val col2=line.getAs[String]("col2")
  }
  	2）DataFrame与Dataset一般不与spark mlib同时使用
  	3）DataFrame与Dataset均支持sparksql的操作，比如select，groupby之类，还能注册临时表/视窗，进行sql语句操作，如：
  dataDF.createOrReplaceTempView("tmp")
  spark.sql("select  ROW,DATE from tmp where DATE is not null order by DATE").show(100,false)
  	4）DataFrame与Dataset支持一些特别方便的保存方式，比如保存成csv
  可以带上表头，这样每一列的字段名一目了然
  //保存
  val saveoptions = Map("header" -> "true", "delimiter" -> "\\t", "path" -> "hdfs://hadoop102:9000/test")
  datawDF.write.format("com.atguigu.spark.csv").mode(SaveMode.Overwrite).options(saveoptions).save()
  //读取
  val options = Map("header" -> "true", "delimiter" -> "\\t", "path" -> "hdfs://hadoop102:9000/test")
  val datarDF= spark.read.options(options).format("com.atguigu.spark.csv").load()
  利用这样的保存方式，可以方便的获得字段名和列的对应，而且分隔符（delimiter）可以自由指定。
  
  3. Dataset:
  	1）Dataset和DataFrame拥有完全相同的成员函数，区别只是每一行的数据类型不同。
  	2）DataFrame也可以叫Dataset[Row],每一行的类型是Row，不解析每一行
  究竟有哪些字段，各个字段又是什么类型都无从得知，只能用上面提到
  的getAS方法或者共性中的第七条提到的模式匹配拿出特定字段
  而Dataset中，每一行是什么类型是不一定的，在自定义了case class之后可
  以很自由的获得每一行的信息
  case class Coltest(col1:String,col2:Int)extends Serializable //定义字段名和类型
  /**
   rdd
   ("a", 1)
   ("b", 1)
   ("a", 1)
  **/
  val test: Dataset[Coltest]=rdd.map{line=>
        Coltest(line._1,line._2)
      }.toDS
  test.map{
        line=>
          println(line.col1)
          println(line.col2)
      }
  可以看出，Dataset在需要访问列中的某个字段时是非常方便的，然而，如果
  要写一些适配性很强的函数时，如果使用Dataset，行的类型又不确定，可能
  是各种case class，无法实现适配，这时候用DataFrame即Dataset[Row]就能
  比较好的解决问题
  ```

## 2.6 IDEA创建Spark SQL程序

```scala
object SparkSQL01_Demo {

    def main(args: Array[String]): Unit = {
        // SparkSQL

        // SparkConf
        val sparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkSQL01_Demo")

        // SparkContext
        // SparkSession
        // 创建SparkSQL的环境对象
        // val spark: SparkSession = new SparkSession(sparkConf)
        val spark: SparkSession = SparkSession.builder().config(sparkConf).getOrCreate()
        val frame: DataFrame = spark.read.json("in/people.json")

        // 将DataFrame转换为一张表
        // df.createOrReplaceTempView("user")

        // 采用sql的语法来访问数据
        // spark.sql("select * from user").show

        // 创建RDD
        val rdd: RDD[(Int, String, Int)] = spark.sparkContext.makeRDD(
            List((1, "zhangsan", 20), (2, "lisi", 30), (3, "wangwu", 40)))

        // 进入转换之前，需要引入隐式转换规则
        // 这里的spark不是包名的含义，是SparkSession对象的名字
        import spark.implicits._

        // 转换为DF
        val df: DataFrame = rdd.toDF("id", "name", "age")

        // 转换为DS
        val ds: Dataset[User] = df.as[User]

        // 转换为DF
        val df1: DataFrame = ds.toDF()

        // 转换为RDD
        val rdd1: RDD[Row] = df1.rdd

        rdd1.foreach(row => println(row.getInt(0)))

        spark.stop()
    }
}

case class User(id:Int, name:String, age:Int)
```

## 2.7 用户自定义函数

- 在Shell窗口中可以通过spark.udf功能用户可以自定义函数

- 用户自定义UDF函数

  ```scala
  scala> val df = spark.read.json("file:///opt/module/spark/input/2.json")
  df: org.apache.spark.sql.DataFrame = [age: bigint, name: string]
  
  scala> df.createTempView("user")
  
  scala> df.show
  +---+-----+
  |age| name|
  +---+-----+
  | 20|chen1|
  | 20|chen2|
  | 20|chen3|
  +---+-----+
  
  scala> spark.sql("select name from user").show
  +-----+
  | name|
  +-----+
  |chen1|
  |chen2|
  |chen3|
  +-----+
  
  scala> spark.udf.register("addName", (x:String) => "Name:"+x)
  res4: org.apache.spark.sql.expressions.UserDefinedFunction = UserDefinedFunction(<function1>,StringType,Some(List(StringType)))
  
  scala> spark.sql("select addName(name) from user").show
  +-----------------+
  |UDF:addName(name)|
  +-----------------+
  |       Name:chen1|
  |       Name:chen2|
  |       Name:chen3|
  +-----------------+
  ```

- 用户自定义聚合函数

  - 强类型的Dataset和弱类型的DataFrame都提供了相关的聚合函数， 如 count()，countDistinct()，avg()，max()，min()。除此之外，用户可以设定自己的自定义聚合函数
  - 弱类型用户自定义聚合函数：通过继承UserDefinedAggregateFunction来实现用户自定义聚合函数
  - 下面展示一个求平均工资的自定义聚合函数

  ```scala
  package com.cjing.spark.sql
  
  import org.apache.spark.SparkConf
  import org.apache.spark.rdd.RDD
  import org.apache.spark.sql.expressions.{MutableAggregationBuffer, UserDefinedAggregateFunction}
  import org.apache.spark.sql.types.{DataType, DoubleType, LongType, StructType}
  import org.apache.spark.sql.{DataFrame, Row, SparkSession}
  
  object SparkSQL02_UDAF {
  
      def main(args: Array[String]): Unit = {
          // SparkConf
          val sparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkSQL01_Demo")
          // 创建SparkSQL的环境对象
          // val spark: SparkSession = new SparkSession(sparkConf)
          val spark: SparkSession = SparkSession.builder().config(sparkConf).getOrCreate()
  
          // 进入转换之前，需要引入隐式转换规则
          // 这里的spark不是包名的含义，是SparkSession对象的名字
          import spark.implicits._
  
          // 创建聚合函数对象
          val udaf = new MyAgeAvgFunction
          spark.udf.register("avgAge", udaf)
  
          val frame: DataFrame = spark.read.json("in/people.json")
          frame.createOrReplaceTempView("user")
          spark.sql("select avgAge(age) from user").show
  
          spark.stop()
      }
  }
  
  // 声明用户自定义聚合函数
  // 1) 继承UserDefinedAggregateFunction
  // 2) 实现方法
  class MyAgeAvgFunction extends UserDefinedAggregateFunction {
  
      // 函数输入的数据结构
      override def inputSchema: StructType = {
          new StructType().add("age", LongType)
      }
  
      // 计算时的数据结构
      override def bufferSchema: StructType = {
          new StructType().add("sum", LongType).add("count", LongType)
      }
  
      // 函数返回的数据类型
      override def dataType: DataType = DoubleType
  
      // 函数是否稳定
      override def deterministic: Boolean = true
  
      // 计算之间的缓冲区的初始化
      override def initialize(buffer: MutableAggregationBuffer): Unit = {
          // 没有名称，只有结构
          buffer(0) = 0L
          buffer(1) = 0L
      }
  
      // 根据查询结构来更新缓冲区数据
      override def update(buffer: MutableAggregationBuffer, input: Row): Unit = {
          // sum
          buffer(0) = buffer.getLong(0) + input.getLong(0)
          // count
          buffer(1) = buffer.getLong(1) + 1
      }
  
      // 将多个结点的缓冲区合并
      override def merge(buffer1: MutableAggregationBuffer, buffer2: Row): Unit = {
          // sum
          buffer1(0) = buffer1.getLong(0) + buffer2.getLong(0)
          // count
          buffer1(1) = buffer1.getLong(1) + buffer2.getLong(1)
      }
  
      // 计算最终需要返回的结果
      override def evaluate(buffer: Row): Any = {
          buffer.getLong(0).toDouble / buffer.getLong(1)
      }
  }
  ```

  - 强类型用户自定义聚合函数：通过继承Aggregator来实现强类型自定义聚合函数
  - 同样是求平均工资

  ```scala
  package com.cjing.spark.sql
  
  import org.apache.spark.SparkConf
  import org.apache.spark.rdd.RDD
  import org.apache.spark.sql.expressions.{Aggregator, MutableAggregationBuffer, UserDefinedAggregateFunction}
  import org.apache.spark.sql.types.{DataType, DoubleType, LongType, StructType}
  import org.apache.spark.sql._
  
  object SparkSQL03_UDAF_Class {
  
      def main(args: Array[String]): Unit = {
          // SparkConf
          val sparkConf = new SparkConf().setMaster("local[*]").setAppName("SparkSQL03_UDAF_Class")
          // 创建SparkSQL的环境对象
          // val spark: SparkSession = new SparkSession(sparkConf)
          val spark: SparkSession = SparkSession.builder().config(sparkConf).getOrCreate()
  
          // 进入转换之前，需要引入隐式转换规则
          // 这里的spark不是包名的含义，是SparkSession对象的名字
          import spark.implicits._
  
          // 创建聚合函数对象
          val udaf = new MyAgeAvgClassFunction
  
          // 将聚合函数转换为查询的列
          val avgCol: TypedColumn[UserBean, Double] = udaf.toColumn.name("avgAge")
  
          val frame: DataFrame = spark.read.json("in/people.json")
          val userDS: Dataset[UserBean] = frame.as[UserBean]
  
          // 应用函数
          userDS.select(avgCol).show()
  
          spark.stop()
      }
  }
  
  case class UserBean(username:String, age:BigInt)
  case class AvgBuffer(var sum:BigInt, var count:Int)
  
  // 声明用户自定义聚合函数（强类型）
  // 1) 继承 Aggregator, 设定泛型
  // 2) 实现方法
  class MyAgeAvgClassFunction extends Aggregator[UserBean, AvgBuffer, Double] {
  
      // 初始化
      override def zero: AvgBuffer = {
          AvgBuffer(0, 0)
      }
  
      /**
        * 聚合数据
        * @param b
        * @param a
        * @return
        */
      override def reduce(b: AvgBuffer, a: UserBean): AvgBuffer = {
          b.sum = b.sum + a.age
          b.count = b.count + 1
  
          b
      }
  
      // 缓冲区的合并操作
      override def merge(b1: AvgBuffer, b2: AvgBuffer): AvgBuffer = {
          b1.sum = b1.sum + b2.sum
          b1.count = b1.count + b2.count
  
          b1
      }
  
      // 完成计算
      override def finish(reduction: AvgBuffer): Double = {
          reduction.sum.toDouble / reduction.count
      }
  
      override def bufferEncoder: Encoder[AvgBuffer] = Encoders.product
  
      override def outputEncoder: Encoder[Double] = Encoders.scalaDouble
  }
  ```

# 三、Spark SQL数据源

## 3.1 通用加载/保存方法

- **手动指定选项**

  - Spark SQL的默认数据源为Parquet格式。数据源为Parquet文件时，Spark SQL可以方便的执行所有的操作。修改配置项spark.sql.sources.default，可修改默认数据源格式

  ```scala
  val df = spark.read.load("examples/src/main/resources/users.parquet") 
  df.select("name", "favorite_color").write.save("namesAndFavColors.parquet")
  ```

  - 当数据源格式不是parquet格式文件时，需要手动指定数据源的格式。数据源格式需要指定全名（例如：org.apache.spark.sql.parquet），如果数据源格式为内置格式，则只需要指定简称定json, parquet, jdbc, orc, libsvm, csv, text来指定数据的格式。
  - 可以通过SparkSession提供的read.load方法用于通用加载数据，使用write和save保存数据

  ```scala
  val peopleDF = spark.read.format("json").load("examples/src/main/resources/people.json")
  peopleDF.write.format("parquet").save("hdfs://hadoop102:9000/namesAndAges.parquet")
  ```

- **文件保存选项**

  - 可以采用SaveMode执行存储操作，SaveMode定义了对数据的处理模式。需要注意的是，这些保存模式不使用任何锁定，不是原子操作。此外，当使用Overwrite方式执行时，在输出新数据之前原数据就已经被删除

  | Scala/Java                      | Any Language     | Meaning              |
  | ------------------------------- | ---------------- | -------------------- |
  | SaveMode.ErrorIfExists(default) | "error"(default) | 如果文件存在，则报错 |
  | SaveMode.Append                 | "append"         | 追加                 |
  | SaveMode.Overwrite              | "overwrite"      | 覆写                 |
  | SaveMode.Ignore                 | "ignore"         | 数据存在，则忽略     |

## 3.2 JSON文件

- Spark SQL 能够自动推测 JSON数据集的结构，并将它加载为一个Dataset[Row]. 可以通过SparkSession.read.json()去加载一个 一个JSON 文件
- 注意：这个JSON文件不是一个传统的JSON文件，每一行都得是一个JSON串

```scala
{"name":"Michael"}
{"name":"Andy", "age":30}
{"name":"Justin", "age":19}

// Primitive types (Int, String, etc) and Product types (case classes) encoders are
// supported by importing this when creating a Dataset.
import spark.implicits._

// A JSON dataset is pointed to by path.
// The path can be either a single text file or a directory storing text files
val path = "examples/src/main/resources/people.json"
val peopleDF = spark.read.json(path)

// The inferred schema can be visualized using the printSchema() method
peopleDF.printSchema()
// root
//  |-- age: long (nullable = true)
//  |-- name: string (nullable = true)

// Creates a temporary view using the DataFrame
peopleDF.createOrReplaceTempView("people")

// SQL statements can be run by using the sql methods provided by spark
val teenagerNamesDF = spark.sql("SELECT name FROM people WHERE age BETWEEN 13 AND 19")
teenagerNamesDF.show()
// +------+
// |  name|
// +------+
// |Justin|
// +------+

// Alternatively, a DataFrame can be created for a JSON dataset represented by
// a Dataset[String] storing one JSON object per string
val otherPeopleDataset = spark.createDataset(
"""{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
val otherPeople = spark.read.json(otherPeopleDataset)
otherPeople.show()
// +---------------+----+
// |        address|name|
// +---------------+----+
// |[Columbus,Ohio]| Yin|
```

## 3.3 Parquet文件

- Parquet是一种流行的列式存储格式，可以高效地存储具有嵌套字段的记录。Parquet格式经常在Hadoop生态圈中被使用，它也支持Spark SQL的全部数据类型。Spark SQL 提供了直接读取和存储 Parquet 格式文件的方法

```scala
importing spark.implicits._
import spark.implicits._

val peopleDF = spark.read.json("examples/src/main/resources/people.json")

peopleDF.write.parquet("hdfs://hadoop102:9000/people.parquet")

val parquetFileDF = spark.read.parquet("hdfs:// hadoop102:9000/people.parquet")

parquetFileDF.createOrReplaceTempView("parquetFile")

val namesDF = spark.sql("SELECT name FROM parquetFile WHERE age BETWEEN 13 AND 19")
namesDF.map(attributes => "Name: " + attributes(0)).show()
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+
```

## 3.4 JDBC

- Spark SQL可以通过JDBC从关系型数据库中读取数据的方式创建DataFrame，通过对DataFrame一系列的计算后，还可以将数据再写回关系型数据库中。
- 注意:**需要将相关的数据库驱动放到spark的类路径下**

```scala
//（1）启动spark-shell
$ bin/spark-shell

//（2）从Mysql数据库加载数据方式一
val jdbcDF = spark.read
.format("jdbc")
.option("url", "jdbc:mysql://hadoop102:3306/rdd")
.option("dbtable", "rddtable")
.option("user", "root")
.option("password", "000000")
.load()

//（3）从Mysql数据库加载数据方式二
val connectionProperties = new Properties()
connectionProperties.put("user", "root")
connectionProperties.put("password", "000000")
val jdbcDF2 = spark.read
.jdbc("jdbc:mysql://hadoop102:3306/rdd", "rddtable", connectionProperties)

//（4）将数据写入Mysql方式一
jdbcDF.write
.format("jdbc")
.option("url", "jdbc:mysql://hadoop102:3306/rdd")
.option("dbtable", "dftable")
.option("user", "root")
.option("password", "000000")
.save()

//（5）将数据写入Mysql方式二
jdbcDF2.write
.jdbc("jdbc:mysql://hadoop102:3306/rdd", "db", connectionProperties)
```

## 3.5 Hive数据库

- Apache Hive是Hadoop上的SQL引擎，Spark SQL编译时可以包含Hive支持，也可以不包含。包含Hive支持的Spark SQL可以支持Hive表访问、UDF(用户自定义函数)以及 Hive 查询语言(HiveQL/HQL)等。需要强调的一点是，如果要在Spark SQL中包含Hive的库，并不需要事先安装Hive。一般来说，最好还是在编译Spark SQL时引入Hive支持，这样就可以使用这些特性了。如果你下载的是二进制版本的 Spark，它应该已经在编译时添加了 Hive 支持

- 若要把Spark SQL连接到一个部署好的Hive上，你必须把hive-site.xml复制到 Spark的配置文件目录中($SPARK_HOME/conf)。即使没有部署好Hive，Spark SQL也可以运行。 需要注意的是，如果你没有部署好Hive，Spark SQL会在当前的工作目录中创建出自己的Hive 元数据仓库，叫作 metastore_db。此外，如果你尝试使用 HiveQL 中的 CREATE TABLE (并非 CREATE EXTERNAL TABLE)语句来创建表，这些表会被放在你默认的文件系统中的 /user/hive/warehouse 目录中(如果你的 classpath 中有配好的 hdfs-site.xml，默认的文件系统就是 HDFS，否则就是本地文件系统)

- **内嵌Hive应用**

  - 如果要使用内嵌的Hive，什么都不用做，直接用就可以了
  - 可以通过添加参数初次指定数据仓库地址：--conf spark.sql.warehouse.dir=hdfs://hadoop102/spark-wearhouse
  - 注意：如果你使用的是内部的Hive，在Spark2.0之后，spark.sql.warehouse.dir用于指定数据仓库的地址，如果你需要是用HDFS作为路径，那么需要将core-site.xml和hdfs-site.xml 加入到Spark conf目录，否则只会创建master节点上的warehouse目录，查询时会出现文件找不到的问题，这是需要使用HDFS，则需要将metastore删除，重启集群

- **外部Hive应用**

  - 如果想连接外部已经部署好的Hive，需要通过以下几个步骤
    - 将Hive中的hive-site.xml拷贝或者软连接到Spark安装目录下的conf目录下
    - 打开spark shell，注意带上访问Hive元数据库的JDBC客户端

  ```scala
  $ bin/spark-shell --jars mysql-connector-java-5.1.27-bin.jar
  ```

- **运行Spark SQL CLI**

  - Spark SQL CLI可以很方便的在本地运行Hive元数据服务以及从命令行执行查询任务。在Spark目录下执行如下命令启动Spark SQL CLI：

  ```scala
  ./bin/spark-sql
  ```

- **代码中使用Hive**

  ```scala
  //（1）添加依赖：
  <!-- <https://mvnrepository.com/artifact/org.apache.spark/spark-hive> -->
  <dependency>
      <groupId>org.apache.spark</groupId>
      <artifactId>spark-hive_2.11</artifactId>
      <version>2.1.1</version>
  </dependency>
  <!-- <https://mvnrepository.com/artifact/org.apache.hive/hive-exec> -->
  <dependency>
      <groupId>org.apache.hive</groupId>
      <artifactId>hive-exec</artifactId>
      <version>1.2.1</version>
  </dependency>
  
  //（2）创建SparkSession
  val warehouseLocation: String = new File("spark-warehouse").getAbsolutePath
  
  val spark = SparkSession
  .builder()
  .appName("Spark Hive Example")
  // 注意：内置Hive需要指定一个Hive仓库地址。若使用的是外部Hive，则需要将hive-site.xml添加到ClassPath下。
  .config("spark.sql.warehouse.dir", warehouseLocation)
  // 添加hive支持
  .enableHiveSupport()
  .getOrCreate()
  ```