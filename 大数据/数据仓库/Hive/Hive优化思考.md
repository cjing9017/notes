1、写在关联左侧的表每有1条重复的关联键时底层就会多1次运算处理（https://blog.csdn.net/qq_26442553/article/details/80865014）

- 把重复关联键少的表放在join前面做关联可以提高join的效率

2、在join的时候，先对右表根据where条件过滤，再对左表根据where条件过滤。因此，虽然join中我们通过dt限定了要关联的分区，但是在where中先进行过滤，可以减少join时的计算量

3、Map端的key/value对，是根据join中的on条件构建key值，同时根据select字段构建value，因此需要防止key值的数据倾斜问题，以及在select中减少不必要的字段