# 一、Kafka概述

## 1.1 定义

Kafka是一个分布式的基于发布/订阅模式的消息队列，主要应用于大数据实时处理领域

## 1.2 消息队列

1、MQ传统应用场景之异步处理

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181044879.png)

2、MQ传统应用场景之流量消峰

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181044124.png)

- 消息队列的两种模式

  - `点对点模式`：一对一，消费者主动拉取数据，消息收到后消息清除

    ![111](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181045409.png)

    - 消息生产者生产消息发送到Queue中，然后消息消费者从Queue中取出并且消费消息
    - 消息被消费以后，queue中不再有存储，所以消息消费者不可能消费到已经被消费的消息
    - Queue支持存在多个消费者，但是对一个消息而言，只会有一个消费者可以消费

  - `发布/订阅模式`：一对多，消费者消费数据之后不会清除消息

    ![222](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181046263.png)

    - 消息生产者（发布）将消息发布到topic中，同时有多个消息消费者（订阅）消费该消息
    - 和点对点方式不同，发布到topic的消息会被所有订阅者消费

## 1.3 Kafka基础架构

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181046907.png)

Kafka基础架构

- **`Producer` ：**消息生产者，就是向kafka broker发消息的客户端
- **`Consumer` ：**消息消费者，向kafka broker取消息的客户端
- **`Consumer Group （CG）`：**消费者组，由多个consumer组成。**消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个消费者消费；消费者组之间互不影响。\**所有的消费者都属于某个消费者组，即\**消费者组是逻辑上的一个订阅者**
- **`Broker` ：**一台kafka服务器就是一个broker。一个集群由多个broker组成。一个broker可以容纳多个topic
- **`Topic` ：**可以理解为一个队列，**生产者和消费者面向的都是一个topic**
- **`Partition`：**为了实现扩展性，一个非常大的topic可以分布到多个broker（即服务器）上，**一个topic可以分为多个partition**，每个partition是一个有序的队列
- **`Replica`：\**副本，为保证集群中的某个节点发生故障时，该节点上的partition数据不丢失，且kafka仍然能够继续工作，kafka提供了副本机制，一个topic的每个分区都有若干个副本，一个\**leader**和若干个**follower**
- **`leader`：**每个分区多个副本的“主”，生产者发送数据的对象，以及消费者消费数据的对象都是leader
- **`follower`：**每个分区多个副本中的“从”，实时从leader中同步数据，保持和leader数据的同步。leader发生故障时，某个follower会成为新的leader

# 二、Kafka架构

## 2.1 Kafka工作流程

![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181046975.png)

Kafka工作流程

- Kafka中消息是以**topic**进行分类的，生产者生产消息，消费者消费消息，都是面向topic的
- `topic是逻辑上的概念，而partition是物理上的概念`（文件是以topic+分区号命名的），每个partition对应于一个log文件，该log文件中存储的就是producer生产的数据
- Producer生产的数据会被不断追加到该log文件末端，且每条数据都有自己的offset
- 消费者组中的每个消费者，都会实时记录自己消费到了哪个offset，以便出错恢复时，从上次的位置继续消费

## 2.2 Kafka文件存储机制

![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181046238.png)

Kafka文件存储机制

- 由于生产者生产的消息会不断追加到log文件末尾，为防止log文件过大导致数据定位效率低下，Kafka采取了分片和索引机制，将每个partition分为多个segment，默认的分片大小为1G，并且在168小时（7天）后会删除旧的数据
- 每个segment对应两个文件——“.index”文件和“.log”文件
- 这些文件位于一个文件夹下，该文件夹的命名规则为：topic名称+分区序号
  - 例如，first这个topic有三个分区，则其对应的文件夹为first-0，first-1，first-2
- index和log文件以当前segment的第一条消息的offset命名

![6](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181046754.png)

index和log文件详解

- “.index”文件存储大量的索引信息
- “.log”文件存储大量的数据
- 索引文件中的元数据指向对应数据文件中message的物理偏移地址
- 根据offset的查找流程
  1. 首先根据offset，利用二分查找法，找到.index文件
  2. 因为.index文件中每一条数据的大小是相同的，这个时候就可以根据offset直接找到所在的那一条数据
  3. 这条数据中，记录了数据所在的.log文件的偏移量及数据的大小
  4. 根据.index文件查找到的偏移量找到.log文件数据的开始部分，同时根据数据的大小，找到数据的结束部分

## 2.3 Kafka生产者

### 2.3.1 分区策略

- 分区的原因

  - **`方便在集群中扩展`：**每个Partition可以通过调整以适应它所在的机器，而一个topic又可以有多个Partition组成，因此整个集群就可以适应任意大小的数据了
  - **`可以提高并发`：**因为可以以Partition为单位读写了

- 分区的原则

  - 我们需要将producer发送的数据封装成一个ProducerRecord对象

    ![7](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181047759.png)

  - 指明 partition 的情况下，直接将指明的值直接作为 partiton 值

  - 没有指明 partition 值但有 key 的情况下，将 key 的 hash 值与 topic 的 partition 数进行取余得到 partition 值

  - 既没有 partition 值又没有 key 值的情况下，第一次调用时随机生成一个整数（后面每次调用在这个整数上自增），将这个值与 topic 可用的 partition 总数取余得到 partition 值，也就是常说的 round-robin 算法

### 2.3.2 数据可靠性保证

为保证producer发送的数据，能可靠的发送到指定的topic，topic的每个partition收到producer发送的数据后，都需要向producer发送ack（acknowledgement确认收到），如果producer收到ack，就会进行下一轮的发送，否则重新发送数据

![8](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181047343.png)

- 需要解决的两个问题
  - 何时发送ack
  - 多少个follower同步完成之后发送ack

| 方案                        | 优点                                               | 缺点                                                |
| --------------------------- | -------------------------------------------------- | --------------------------------------------------- |
| 半数以上完成同步，就发送ack | 延迟低                                             | 选举新的leader时，容忍n台节点的故障，需要2n+1个副本 |
| 全部完成同步，才发送ack     | 选举新的leader时，容忍n台节点的故障，需要n+1个副本 | 延迟高                                              |

- **容忍节点数计算**

  - 第一种方案：要容忍n台节点故障，需要有2n+1个副本，因为半数以上完成了同步，那么剩余的n+1台节点中至少有一个已经完成了同步
  - 第二种方案：要容忍n台节点故障，需要有n+1个副本，因为全部完成同步，那么剩下的这一台节点也是完成了同步

- **Kafka选择第二种副本数据同步策略**

  - 同样为了容忍n台节点的故障，第一种方案需要2n+1个副本，而第二种方案只需要n+1个副本，而Kafka的每个分区都有大量的数据，第一种方案会造成大量数据的冗余
  - 虽然第二种方案的网络延迟会比较高，但网络延迟对Kafka的影响较小

- **ISR**

  - 采用第二种方案之后，设想以下情景：leader收到数据，所有follower都开始同步数据，但有一个follower，因为某种故障，迟迟不能与leader进行同步，那leader就要一直等下去，直到它完成同步，才能发送ack。这个问题怎么解决呢？
  - Leader维护了一个动态的in-sync replica set (ISR)，意为和leader保持同步的follower集合
  - 当ISR中的follower完成数据的同步之后，leader就会给follower发送ack
  - 如果follower长时间未向leader同步数据，则该follower将被踢出ISR，该时间阈值由**[replica.lag.time.max.ms](http://replica.lag.time.max.ms)**参数设定
  - Leader发生故障之后，就会从ISR中选举新的leader
  - 加入到ISR中的follower需要符合的条件之一
    1. 在规定的阈值时间内响应leader
    2. 与leader的数据相差不超过阈值
  - 在高版本中去除了第2个条件
    - ISR是存储在内存中的
    - 生产者是批量发送数据的
    - 如果此时生产者发送的数据量大于这个阈值，那么所有的follower都会被从ISR中去除
    - 之后，又会因为低响应时间或同步后数据相差不超过阈值而又被重新加入到ISR中
    - 那么，对于生产者多次的发送超过阈值的批量数据，follower就会重复的移除和加入ISR中；并且，这个数据是存储在zookeeper中，又会对zookeeper执行重复的操作，导致效率非常的低

- **ack应答机制**

  - 对于某些不太重要的数据，对数据的可靠性要求不是很高，能够容忍数据的少量丢失，所以没必要等ISR中的follower全部接收成功

  - 所以Kafka为用户提供了三种可靠性级别，用户根据对可靠性和延迟的要求进行权衡，选择以下的配置

  - **acks参数配置**

    - 0：producer不等待broker的ack，这一操作提供了一个最低的延迟，broker一接收到但还没有写入磁盘就已经返回，当broker故障时有可能**丢失数据（可以保证不重复数据）**
    - 1：producer等待broker的ack，partition的leader落盘成功后返回ack，如果在follower同步成功之前leader故障，那么将会**丢失数据**

    ![333](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181048035.png)

    - -1（all）：producer等待broker的ack，partition的leader和follower全部落盘成功后才返回ack。但是如果在follower同步完成后，broker发送ack之前，leader发生故障，那么会造成

      数据重复（可以在一定程度上保证不丢失数据）

      - `注意`：如果此时ISR中只有一个leader，那么其实就退化为acks = 1的情况，因此，也有可能造成数据的丢失

    ![9](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181049314.png)

- **故障处理细节**

  ![10](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181050242.png)

  - `follower故障`：follower发生故障后会被临时踢出ISR，待该follower恢复后，follower会读取本地磁盘记录的上次的HW，并将log文件高于HW的部分截取掉，从HW开始向leader进行同步。等该follower的LEO大于等于该Partition的HW，即follower追上leader之后，就可以重新加入ISR了
  - `leader故障`：leader发生故障之后，会从ISR中选出一个新的leader，之后，为保证多个副本之间的数据一致性，其余的follower会先将各自的log文件高于HW的部分截掉，然后从新的leader同步数据
  - 注意：这只能保证副本之间的数据一致性，并不能保证数据`不丢失`或者`不重复`
  - 利用HW能够保证消费者消费数据的一致性
  - 利用HW和LEO能够保证存储的一致性

  ### 2.3.3 Exactly Once语义

  - `At Least Once`语义：将服务器的 ACK 级别设置为-1，可以保证 Producer 到 Server 之间不会丢失数据
  - `At Most Once`语义：将服务器 ACK 级别设置为 0，可以保证生产者每条消息只会被发送一次
  - 对于某些比较重要的消息，我们需要保证exactly once语义，即保证每条消息被发送且仅被发送一次
  - 0.11 版本的 Kafka，引入了一项重大特性：`幂等性`。所谓的幂等性就是指 Producer 不论向 Server 发送多少次重复数据，Server 端都只会持久化一条，配合acks = -1时的at least once语义，实现了producer到broker的exactly once语义
  - **idempotent + at least once = exactly once**
  - 使用时，只需将enable.idempotence属性设置为true，kafka自动将acks属性设为-1
  - Kafka的幂等性实现其实就是将原来下游需要做的去重放在了数据上游。开启幂等性的 Producer 在初始化的时候会被分配一个 PID，发往同一 Partition 的消息会附带 Sequence Number。而Broker 端会对<PID, Partition, SeqNumber>做缓存，当具有相同主键的消息提交时，Broker 只会持久化一条
  - 但是 PID 重启就会变化，同时不同的 Partition 也具有不同主键，所以幂等性`无法保证跨分区跨会话`的 Exactly Once

## 2.4 Kafka消费者

### 2.4.1 消费方式

- consumer采用pull（拉）模式从broker中读取数据
- push（推）模式很难适应消费速率不同的消费者，因为消息发送速率是由broker决定的。它的目标是尽可能以最快速度传递消息，但是这样很容易造成consumer来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。而pull模式则可以根据consumer的消费能力以适当的速率消费消息
- pull模式不足之处是，如果kafka没有数据，消费者可能会陷入循环中，一直返回空数据。针对这一点，Kafka的消费者在消费数据时会传入一个时长参数timeout，如果当前没有数据可供消费，consumer会等待一段时间之后再返回，这段时长即为timeout

### 2.4.2 分区分配策略

- 一个consumer group中有多个consumer，一个 topic有多个partition，所以必然会涉及到partition的分配问题，即确定哪个partition由哪个consumer来消费

- 触发的时机：当消费者组里的消费者个数发生变化的时候

- Kafka有两种分配策略，一是roundrobin，一是range

- **RoundRobin**

  ![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181051837.png)

  ![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181051059.png)

  - 按照组来划分
  - 会将所有的topic下的partition进行一个排序后再进行轮询
  - 可能导致的问题：重新排序轮询后，消费了不是我想消费的那个分区的数据
  - 使用的前提：所有消费者组订阅的是同一主题

- **Range**

  ![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181051889.png)

  ![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181052228.png)

  - 按照主题来消费
  - 首先，需要找到有哪些消费者订阅了这个主题，然后再考虑组（即，如果同一个组有多个消费者订阅了同一个主题，按照平均的分配原则来分配分区；如果一个组只有一个消费者订阅了这个主题，那么就只由这个消费者来消费）
  - 可能导致的问题：随着主题数量的不对等，消费者消费的数据出现不对等的情况

### 2.4.3 offset的维护

- 由于consumer在消费过程中可能会出现断电宕机等故障，consumer恢复后，需要从故障前的位置继续消费，所以consumer需要实时记录自己消费到了哪个offset，以便故障恢复后继续消费
- Kafka 0.9版本之前，consumer默认将offset保存在Zookeeper中
- 从0.9版本开始，consumer默认将offset保存在Kafka一个内置的topic中，该topic为**__consumer_offsets**
- 按照<消费者组，主题，分区>来唯一的确定一个offset

## 2.5 Kafka高效读写数据

- **顺序写磁盘**

  - Kafka的producer生产数据，要写入到log文件中，写的过程是一直追加到文件末端，为顺序写
  - 官网有数据表明，同样的磁盘，顺序写能达到600M/s，而随机写只有100k/s
  - 这与磁盘的机械机构有关，顺序写之所以快，是因为其省去了大量磁头寻址的时间

- **零拷贝技术**

  ![444](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181053778.png)

  - 直接由操作系统完成文件的读取和写入

## 2.6 Zookeeper在Kafka中的作用

- Kafka集群中有一个broker会被选举为Controller，负责管理集群broker的上下线，所有topic的分区副本分配和leader选举等工作
- Controller的管理工作都是依赖于Zookeeper的
- 以下为partition的leader选举过程：

![11](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305181052476.png)

## 2.7 Kafka事务

> Kafka 从 0.11 版本开始引入了事务支持。事务可以保证 Kafka 在 Exactly Once 语义的基础上，生产和消费可以跨分区和会话，要么全部成功，要么全部失败

- Producer 事务
  - 为了实现`跨分区跨会话`的事务，需要引入一个全局唯一的 Transaction ID，并将 Producer获得的PID 和Transaction ID 绑定。这样当Producer 重启后就可以通过正在进行的 TransactionID 获得原来的 PID
  - 为了管理 Transaction，Kafka 引入了一个新的组件 Transaction Coordinator
  - Producer 就是通过和 Transaction Coordinator 交互获得 Transaction ID 对应的任务状态
  - Transaction Coordinator 还负责将事务所有写入 Kafka 的一个内部 Topic，这样即使整个服务重启，由于事务状态得到保存，进行中的事务状态可以得到恢复，从而继续进行
  - 解决的是精准执行一次性写入到Kafka集群中
- Consumer 事务
  - 上述事务机制主要是从 Producer 方面考虑，对于 Consumer 而言，事务的保证就会相对较弱，尤其是无法保证 Commit 的信息被精确消费
  - 这是由于 Consumer 可以通过 offset 访问任意信息，而且不同的 Segment File 生命周期不同，同一事务的消息可能会出现重启后被删除的情况