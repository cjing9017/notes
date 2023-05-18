# 一、概述

Yarn是一个资源调度平台，负责为运算程序提供服务器运算资源，相当于一个分布式的操作系统平台，而MapReduce等运算程序则相当于运行于操作系统之上的应用程序

# 二、Yarn基本架构

Yarn主要由四个组件构成：

- ResourceManager：所有资源
- NodeManager：节点资源
- ApplicationMaster：Job上的资源
- Container：节点上的资源

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171736810.png)

Yarn架构

- 说明
  - ResourceManger（RM）主要作用：
    - 处理客户端的请求，比如Job作业的提交
    - 监控所有节点上的NodeManager的状态
    - 启动或监控每个Job作业管理的ApplicationMaster
    - 资源的分配与调度
  - NodeManger（NM）主要作用：
    - 管理单个节点上的资源
    - 处理来自ResourceManager的命令
    - 处理来自ApplicationMaster的命令，主要是资源的申请
  - ApplicationMaster（AM）主要作用：
    - 负责数据的切分，根据切片信息决定开启多少个MapTask
    - 为应用程序申请资源并分配给内部的任务
    - 任务的监控与容错，比如某个进程挂掉了，会重新分配给另外一个进程
  - Containter主要作用：
    - Yarn中的资源抽象，它封装了某个节点上的多维度资源，如内存、CPU、磁盘网络等

# 三、Yarn工作机制

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171736324.png)

- 工作机制详解
  - MR程序提交到客户端所在的节点，即job.waitForCompletion()（提交的内容就是你的jar包）启动的是YarnRunner
  - 一切准备工作完成之后，YarnRunner向ResourceManager申请一个Application
  - RM将该应用程序的资源路径和job的id（application_id）返回给YarnRunner
  - 返回之后，该程序提交job运行所需资源到HDFS上，这个路径对应job的资源，这些资源包括：Job.split（切片）、Job.xml（配置文件）和wc.jar（Jar包）
  - 程序资源提交完毕后，申请运行mrAppMaster（整个Job资源状态的协调）
  - RM将用户的请求初始化成一个Task
  - 这个Task放置在任务的队列里等待调度
  - 其中一个NodeManager领取到Task任务，每个任务都需要相应的资源
  - NodeManager创建容器Container，并产生MRAppmaster
  - Container从HDFS上拷贝资源到本地
  - MRAppmaster向RM 申请运行MapTask（由读取到的切分信息决定开多少个）
  - RM将运行MapTask任务分配给另外几个NodeManager，另外几个NodeManager分别领取任务并创建容器
  - MR向两个接收到任务的NodeManager发送程序启动脚本，这两个NodeManager分别启动MapTask，MapTask对数据分区排序
  - MrAppMaster等待所有MapTask运行完毕后，向RM申请资源，运行ReduceTask
  - ReduceTask向MapTask获取相应分区的数据
  - 程序运行完毕后，MR会向RM申请注销自己

# 四、作业提交全过程

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171736051.png)

![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171736356.png)

- 作业提交全过程详解
  - 作业提交
    - 第1步：Client调用job.waitForCompletion方法，向整个集群提交MapReduce作业
    - 第2步：Client向RM申请一个作业id
    - 第3步：RM给Client返回该job资源的提交路径和作业id
    - 第4步：Client提交jar包、切片信息和配置文件到指定的资源提交路径
    - 第5步：Client提交完资源后，向RM申请运行MrAppMaster
  - 作业初始化
    - 第6步：当RM收到Client的请求后，将该job添加到容量调度器中
    - 第7步：某一个空闲的NM领取到该Job
    - 第8步：该NM创建Container，并产生MRAppmaster
    - 第9步：下载Client提交的资源到本地
  - 任务分配
    - 第10步：MrAppMaster向RM申请运行多个MapTask任务资源
    - 第11步：RM将运行MapTask任务分配给另外两个NodeManager，另两个NodeManager分别领取任务并创建容器
  - 任务运行
    - 第12步：MR向两个接收到任务的NodeManager发送程序启动脚本，这两个NodeManager分别启动MapTask，MapTask对数据分区排序
    - 第13步：MrAppMaster等待所有MapTask运行完毕后，向RM申请容器，运行ReduceTask
    - 第14步：ReduceTask向MapTask获取相应分区的数据
    - 第15步：程序运行完毕后，MR会向RM申请注销自己
  - 进度和状态更新
    - YARN中的任务将其进度和状态(包括counter)返回给应用管理器, 客户端每秒(通过mapreduce.client.progressmonitor.pollinterval设置)向应用管理器请求进度更新, 展示给用户
  - 作业完成
    - 除了向应用管理器请求作业进度外, 客户端每5秒都会通过调用waitForCompletion()来检查作业是否完成
    - 时间间隔可以通过mapreduce.client.completion.pollinterval来设置
    - 作业完成之后, 应用管理器和Container会清理工作状态
    - 作业的信息会被作业历史服务器存储以备之后用户核查

# 五、资源调度器

目前，Hadoop作业调度器主要有三种：

- 先进先出调度器（FIFO）

  ![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171737307.png)

  - 按照到达时间排序，先到先服务
  - 每个Job里面可能会包含多个MapTask和ReduceTask
  - 每当有新的服务器节点资源时，会分配一个Task给该节点

- 容量调度器（Capacity Scheduler）

  ![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171737442.png)

  - 支持多个队列，每个队列可配置一定的资源量，每个队列采用FIFO调度策略
  - 为了防止同一个用户的作业独占队列中的资源，该调度器会对同一用户提交的作业所占资源进行限定
  - 首先，计算每个队列中正在运行的任务数与其应该分得的计算资源之间的比值，选择一个该比值最小的队列——最空闲的
  - 其次，按照作业优先级和提交时间顺序，同时考虑用户资源量限制和内存限制对队列内任务排序来决定哪个任务先执行
  - 三个队列同时按照任务的先后顺序依次执行

- 公平调度器（Fair Scheduler）

  ![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171738516.png)

  - 按照缺额排序，缺额大的优先
  - 支持多队列，每个队列可配置一定的资源量，同一个队列中的作业公平共享队列中的**所有资源**
  - 比如有三个队列：queueA、queueB和queueC，每个队列中的job按照优先级分配资源，优先级越高分配的资源越多，但是每个job都会分配到资源以确保公平
  - 在资源有限的情况下，每个job理想情况下获得的计算资源与实际获得的计算资源存在一种差距，这个差距就叫做缺额
  - 在同一个队列中，job的资源缺额越大，越先获得资源有限执行；作业是按照缺额的高低来先后执行的，而且同一个队列中有多个作业同时运行

# 六、任务的推测执行

- 作业完成时间取决于最慢的任务完成时间

  - 一个作业由若干个Map任务和Reduce任务构成。因硬件老化、软件Bug等，某些任务可能运行非常慢。
  - 思考：系统中有99%的Map任务都完成了，只有少数几个Map老是进度很慢，完不成，怎么办？

- 推测执行机制

  - 发现拖后腿的任务，比如某个任务运行速度远慢于任务平均速度。为拖后腿任务启动一个备份任务，同时运行。谁先运行完，则采用谁的结果

- 执行推测任务的前提条件

  - 每个Task只能有一个备份任务
  - 当前Job已完成的Task必须不小于0.05（5%）
  - 开启推测执行参数设置。mapred-site.xml文件中默认是打开的

  ```java
  <property>
    	<name>mapreduce.map.speculative</name>
    	<value>true</value>
    	<description>If true, then multiple instances of some map tasks may be executed in parallel.</description>
  </property>
  
  <property>
    	<name>mapreduce.reduce.speculative</name>
  		<value>true</value>
    	<description>If true, then multiple instances of some reduce tasks may be executed in parallel.</description>
  </property>
  ```

- 不能启用推测执行机制情况

  - 任务间存在严重的负载倾斜
  - 特殊任务，比如任务向数据库中写数据

- 算法原理

- ![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171738977.png)