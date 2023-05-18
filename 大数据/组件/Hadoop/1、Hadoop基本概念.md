# 一、概述

## 1.1 Hadoop是什么

- Hadoop是一个由Apache基金会所开发的分布式系统基础架构
- 主要解决，海量数据的存储和海量数据的分析计算问题
- 广义上来说，Hadoop通常是指一个更广泛的概念——Hadoop生态圈

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171720704.png)

## 1.2 Hadoop三大发行版本

- Apache版本最原始（最基础）的版本，对于入门学习最好
  - 官网地址：http://hadoop.apache.org/releases.html
  - 下载地址：https://archive.apache.org/dist/hadoop/common/
- Cloudera在大型互联网企业中用的较多
  - 官网地址：https://www.cloudera.com/downloads/cdh/5-10-0.html
  - 下载地址：http://archive-primary.cloudera.com/cdh5/cdh/5/
- Hortonworks文档较好
  - 官网地址：https://hortonworks.com/products/data-center/hdp/
  - 下载地址：https://hortonworks.com/downloads/#data-platform

## 1.3 Hadoop的优势

- `高可靠性`：Hadoop底层维护多个数据副本，所以即使Hadoop某个计算元素或存储出现故障，也不会导致数据的丢失
- `高扩展性`：在集群间分配任务数据，可方便的扩展数以千计的节点
- `高效性`：在MapReduce的思想下，Hadoop是并行工作的，以加快任务处理速度
- `高容错性`：能够自动将失败的任务重新分配

## 1.4 Hadoop的组成

![2](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171721808.png)

在Hadoop1.x时代，Hadoop中的MapReduce同时处理业务逻辑运算和资源的调度，耦合性较大，在Hadoop2.x时代，增加了Yarn。Yarn只负责资源的调度，MapReduce只负责运算

### 1.4.1 HDFS架构概述

- `NameNode(nn)`：存储文件的元数据，如文件名，文件目录结构，文件属性（生成时间、副本数、文件权限），以及每个文件的块列表和块所在的DataNode等
- `DataNode(dn)`：在本地文件系统存储文件块数据，以及块数据的校验和
- `Secondary NameNode(2nn)`：用来监控HDFS状态的辅助后台程序，每隔一段时间获取HDFS元数据的快照

### 1.4.2 YARN架构概述

![3](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171721047.png)

### 1.4.3 MapReduce架构概述

![4](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171722944.png)

Map阶段并行处理输入数据；Reduce阶段对Map结果进行汇总

## 1.5 大数据技术生态体系

![5](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171723218.png)

- 说明
  - `Sqoop`：Sqoop是一款开源的工具，主要用于在Hadoop、Hive与传统的数据库(MySql)间进行数据的传递，可以将一个关系型数据库（例如 ：MySQL，Oracle 等）中的数据导进到Hadoop的HDFS中，也可以将HDFS的数据导进到关系型数据库中
  - `Flume`：Flume是Cloudera提供的一个高可用的，高可靠的，分布式的海量日志采集、聚合和传输的系统，Flume支持在日志系统中定制各类数据发送方，用于收集数据；同时，Flume提供对数据进行简单处理，并写到各种数据接受方（可定制）的能力
  - `Kafka`：Kafka是一种高吞吐量的分布式发布订阅消息系统
  - `Storm`：Storm用于“连续计算”，对数据流做连续查询，在计算时就将结果以流的形式输出给用户
  - `Spark`：Spark是当前最流行的开源大数据内存计算框架。可以基于Hadoop上存储的大数据进行计算
  - `Oozie`：Oozie是一个管理Hdoop作业（job）的工作流程调度管理系统
  - `Hbase`：HBase是一个分布式的、面向列的开源数据库。HBase不同于一般的关系数据库，它是一个适合于非结构化数据存储的数据库
  - `Hive`：Hive是基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库表，并提供简单的SQL查询功能，可以将SQL语句转换为MapReduce任务进行运行。 其优点是学习成本低，可以通过类SQL语句快速实现简单的MapReduce统计，不必开发专门的MapReduce应用，十分适合数据仓库的统计分析
  - `R语言`：R是用于统计分析、绘图的语言和操作环境。R是属于GNU系统的一个自由、免费、源代码开放的软件，它是一个用于统计计算和统计制图的优秀工具
  - `Mahout`：Apache Mahout是个可扩展的机器学习和数据挖掘库
  - `ZooKeeper`：Zookeeper是Google的Chubby一个开源的实现。它是一个针对大型分布式系统的可靠协调系统，提供的功能包括：配置维护、名字服务、 分布式同步、组服务等。ZooKeeper的目标就是封装好复杂易出错的关键服务，将简单易用的接口和性能高效、功能稳定的系统提供给用户

## 1.6 Hadoop目录结构

```powershell
[atguigu@hadoop101 hadoop-2.7.2]$ ll
总用量 52
drwxr-xr-x. 2 atguigu atguigu  4096 5月  22 2017 bin
drwxr-xr-x. 3 atguigu atguigu  4096 5月  22 2017 etc
drwxr-xr-x. 2 atguigu atguigu  4096 5月  22 2017 include
drwxr-xr-x. 3 atguigu atguigu  4096 5月  22 2017 lib
drwxr-xr-x. 2 atguigu atguigu  4096 5月  22 2017 libexec
-rw-r--r--. 1 atguigu atguigu 15429 5月  22 2017 LICENSE.txt
-rw-r--r--. 1 atguigu atguigu   101 5月  22 2017 NOTICE.txt
-rw-r--r--. 1 atguigu atguigu  1366 5月  22 2017 README.txt
drwxr-xr-x. 2 atguigu atguigu  4096 5月  22 2017 sbin
drwxr-xr-x. 4 atguigu atguigu  4096 5月  22 2017 share
```

- 说明
  - `bin`：存放对Hadoop相关服务（HDFS,YARN）进行操作的脚本
  - `etc`：Hadoop的配置文件目录，存放Hadoop的配置文件
  - `lib`：存放Hadoop的本地库（对数据进行压缩解压缩功能）
  - `sbin`：存放启动或停止Hadoop相关服务的脚本
  - `share`：存放Hadoop的依赖jar包、文档、和官方案例

## 1.7 Hadoop运行模式

- 本地模式
- 伪分布式模式
- 完全分布式模式