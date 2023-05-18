# 一、什么是Spark

Spark是一种基于内存的快速、通用、可扩展的大数据分析引擎

# 二、Spark内置模块

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171743828.png)

Spark内置模块

- `Spark Core`：实现了Spark的基本功能，包含任务调度、内存管理、错误恢复、与存储系统交互等模块。Spark Core中还包含了对弹性分布式数据集(Resilient Distributed DataSet，简称RDD)的API定义
- `Spark SQL`：是Spark用来操作结构化数据的程序包。通过Spark SQL，我们可以使用 SQL或者Apache Hive版本的SQL方言(HQL)来查询数据。Spark SQL支持多种数据源，比如Hive表、Parquet以及JSON等
- `Spark Streaming`：是Spark提供的对实时数据进行流式计算的组件。提供了用来操作数据流的API，并且与Spark Core中的 RDD API高度对应
- `Spark MLlib`：提供常见的机器学习(ML)功能的程序库。包括分类、回归、聚类、协同过滤等，还提供了模型评估、数据 导入等额外的支持功能
- `集群管理器`：Spark 设计为可以高效地在一个计算节点到数千个计算节点之间伸缩计算。为了实现这样的要求，同时获得最大灵活性，Spark支持在各种集群管理器(Cluster Manager)上运行，包括Hadoop YARN、Apache Mesos，以及Spark自带的一个简易调度器，叫作独立调度器
- Spark得到了众多大数据公司的支持，这些公司包括Hortonworks、IBM、Intel、Cloudera、MapR、Pivotal、百度、阿里、腾讯、京东、携程、优酷土豆。当前百度的Spark已应用于大搜索、直达号、百度大数据等业务；阿里利用GraphX构建了大规模的图计算和图挖掘系统，实现了很多生产系统的推荐算法；腾讯Spark集群达到8000台的规模，是当前已知的世界上最大的Spark集群

# 三、Spark特点

- 快：与Hadoop的MapReduce相比，Spark基于内存的运算要快100倍以上，基于硬盘的运算也要快10倍以上；Spark实现了高效的DAG执行引擎，可以通过基于内存来高效处理数据流，计算的中间结果是存在于内存中的
- 易用：Spark支持Java、Python和Scala的API，还支持超过80中高级算法，使用户可以快速构建不同的应用；而且Spark支持交互式的Python和Scala的Shell，可以非常方便的在这些Shell中使用Spark集群来验证解决问题的方法
- 通用：Spark提供了统一的解决方案；Spark可以用于批处理、交互式查询、实时流处理、机器学习和图计算；这些不同类型的处理都可以在同一个应用中无缝使用，减少了开发和维护的人力成本和部署平台的物力成本
- 兼容性：Spark可以非常方便的与其他的开源产品进行融合；比如，Spark额可以使用Hadoop的Yarn和Apache Mesos作为他的资源管理和调度器，并且可以处理所有Hadoop支持的数据，包括HDFS、HBase等；这对于已经部署Hadoop集群的用户特别重要，因为不需要做任何数据迁移就可以使用Spark的强大处理能力

# 四、Spark中的重要角色

## 4.1 Driver（驱动器）

- Spark的驱动器是执行开发程序中的main方法的进程
- 它负责开发人员编写的用来创建SparkContext、创建RDD，以及进行RDD的转化操作和行动操作代码的执行
- 如果你是用spark shell，那么当你启动Spark shell的时候，系统后台自启了一个Spark驱动器程序，就是在Spark shell中预加载的一个叫作 sc的SparkContext对象
- 如果驱动器程序终止，那么Spark应用也就结束了
- 主要负责：
  - 把用户程序转为作业（JOB）
  - 跟踪Executor的运行状况
  - 为执行器节点调度任务
  - UI展示应用运行状况

## 4.2 Executor（执行器）

- Spark Executor是一个工作进程，负责在 Spark 作业中运行任务，任务间相互独立
- Spark 应用启动时，Executor节点被同时启动，并且始终伴随着整个 Spark 应用的生命周期而存在
- 如果有Executor节点发生了故障或崩溃，Spark 应用也可以继续执行，会将出错节点上的任务调度到其他Executor节点上继续运行
- 主要负责：
  - 负责运行组成 Spark 应用的任务，并将结果返回给驱动器进程
  - 通过自身的块管理器（Block Manager）为用户程序中要求缓存的RDD提供内存式存储。RDD是直接缓存在Executor进程内的，因此任务可以在运行时充分利用缓存数据加速运算

# 五、Spark的三种模式

## 5.1 Local模式

- Local模式就是运行在一台计算机上的模式，通常就是用于在本机上练手和测试
- 他可以通过一下集中方式设置Master：
  - local：所有计算都运行在一个线程中，没有任何并行计算，通常我们在本机执行一些测试代码或者练手，，就用这种模式
  - local[K]：指定使用几个线程来运行计算，比如local[4]就是运行4个Worker线程；通常我们的Cpu有几个Core，就i指定几个线程，最大化利用Cpu的计算能力
  - local[*]：这种模式直接帮你按照Cpu最多Core来设置线程数

## 5.2 Standalone模式

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171743478.png)

## 5.3 Yarn模式

- Spark客户端直接连接Yarn，不需要额外构建Spark集群
- 有两种模式：
  - yarn-client：Driver程序运行在客户端，适用于交互、调式，希望立即看到app的输出
  - yarn-cluster：Driver程序运行在由RM启动的AP（AppMaster）适用的生产环境

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171744768.png)

- **说明**

  ![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171744873.png)

  1. Spark客户端提交作业到Yarn的RM中
  2. 因为RM是不能做计算的，所以RM会在某一个节点当中启动一个专门用来做计算的管理器，叫应用管理器ApplicationMaster
  3. ApplicationMaster创建完毕后需要向RM申请资源用来计算
  4. RM返回当前可用的资源列表
  5. ApplicationMaster根据可用资源创建Spark执行器对象Executor(在Container里面创建)
  6. 当Executor创建完毕后会反向注册，告知ApplicationMaster创建完毕
  7. 最后，ApplicationMaster会分解任务并调度任务

## 5.4 Mesos模式

- Spark客户端直接连接Mesos
- 不需要额外构建Spark集群
- 国内应用比较少，更多的是运用yarn调度

## 5.5 几种模式对比

| 模式       | Spark安装机器数 | 需启动的进程   | 所属者 |
| ---------- | --------------- | -------------- | ------ |
| Local      | 1               | 无             | Spark  |
| Standalone | 3               | Master及Worker | Spark  |
| Yarn       | 1               | Yarn及HDFS     | Hadoop |

# 六、Hadoop与Spark的渊源

## 6.1 Hadoop历史

![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171745435.png)

![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171745228.png)

## 6.2 Spark历史

![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171745850.png)

# 七、Spark独立部署历史