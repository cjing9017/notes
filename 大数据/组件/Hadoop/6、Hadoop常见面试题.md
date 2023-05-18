# 一、Hadoop的历史

# 二、Hadoop的架构

保活HDFS、MapReduce和Yarn的架构

# 三、HDFS的读流程

# 四、HDFS的写流程

# 五、MapReduce的Shuffle机制

# 六、MapReduce的MapTask机制

# 七、MapReduce的ReduceTask机制

# 八、Hadoop的任务提交流程

![1](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/202305171740861.png)

# 九、MR中的Join实现

# 十、MapTask是如何切分文件的

# 十一、MapReduce数据倾斜问题

- 简单来说数据倾斜就是数据的key 的分化严重不均，造成一部分数据很多，一部分数据很少的局面
- 从另外一个角度看数据倾斜
  - 从另外角度看数据倾斜，其本质还是在单台节点在执行那一部分数据reduce任务的时候，由于数据量大，跑不动，造成任务卡住。若是这台节点机`器内存够大，CPU、网络等资源充足`，跑 80G 左右的数据量和跑10M 数据量所耗时间不是很大差距，那么也就不存在问题，倾斜就倾斜吧，反正机器跑的动。所以机器配置和数据量存在一个合理的比例，一旦数据量远超机器的极限，那么不管每个key的数据如何分布，总会有一个key的数据量超出机器的能力，造成 reduce 缓慢甚至卡顿
- **容易造成数据倾斜的原因**