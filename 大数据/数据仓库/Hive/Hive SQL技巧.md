# 一、计算环比（增长率）

```sql
/*
    计算以天为粒度的环比
    计算环比的公式为(当天的值 - 前一天的值) / 前一天的值
    表：growth
     -----------------
    |dt          value|
    |20211001    100  |
    |20211102    200  |
    |20211003    300  |
    |20211004    400  |
    |20211005    500  |
    |20211006    600  |
     -----------------
*/
select
    g1.dt,
    (g1.value * 1.0 / g2.value - 1) as value_rate
from
    growth as g1
    left join growth as g2
        on g1.dt = date_format(date_add(from_unixtime(unix_timestamp(g2.dt, 'yyyyMMdd'), 'yyyy-MM-dd'), 1), 'yyyyMMdd')
;
```

# 二、获取从开始日期到结束日期间的连续日期

```sql
/*
    获取从开始日期到结束日期之间的连续日期
    开始日期：beginDateKey（yyyyMMdd）
    结束日期：endDateKey（yyyyMMdd）
*/
select
    date_format(date_add(from_unixtime(unix_timestamp(beginDateKey, 'yyyyMMdd'), 'yyyy-MM-dd'), idx), 'yyyyMMdd') as dt
from (
    select
        datediff(from_unixtime(unix_timestamp(endDateKey, 'yyyyMMdd'), 'yyyy-MM-dd'), from_unixtime(unix_timestamp(beginDateKey, 'yyyyMMdd'), 'yyyy-MM-dd')) as day
) as days
lateral view posexplode(split(repeat(',', day), ',')) rpt as idx, val
;
```

# 三、计算指定日期所在星期

```sql
/*
    计算指定日期所在的星期
    dateKey：日期（yyyyMMdd）
    结果值定义：
     ----------------------------
    |Sun Mon Tue Wed Thur Fri Sat|
    |0   1   2   3   4    5   6  |
     ----------------------------
*/
select
    pmod(datediff(from_unixtime(unix_timestamp(dateKey, 'yyyyMMdd'), 'yyyy-MM-dd'), '1920-01-01') - 3, 7) AS week_index
;
```

# 四、计算一组数值增长率的线性回归参数

```sql
/*
    计算一组数值增长率的线性回归参数
    一组数值：[1,2,3,4,5,6,7,8,9,10]
    增长率计算公式：当前值 - 前一个值 / 前一个值
    线性回归参数：对计算得到的所有增长率，计算拟合后的线性回归参数中的斜率

    1、对一组数值求增长率：
     -----------------------------------------
    |x   0   1   2   3   4   5   6   7   8  9 |
    |y   1   2   3   4   5   6   7   8   9  10|
     -----------------------------------------
    2、计算统计值
    (1) sum_x = sum(x)
    (2) sum_y = sum(y)
    (3) sum_xx = sum(x * x)
    (4) sum_xy = sum(x * y)
    (5) n = count(x)
    3、计算线性回归参数中的斜率
    k = (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x)
*/
select
    (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) as k
from (
    select
        count(x) as n
        ,sum(cast(x as double)) as sum_x
        ,sum(cast(y as double)) as sum_y
        ,sum(cast(x as double) * cast(x as double)) as sum_xx
        ,sum(cast(x as double) * cast(y as double)) as sum_xy
    from (
        select
            poi.x,
            poi.y
        from (
            select
                concat_ws(
                    ','
                    ,cast(1 as string)
                    ,cast(2 as string)
                    ,cast(3 as string)
                    ,cast(4 as string)
                    ,cast(5 as string)
                    ,cast(6 as string)
                    ,cast(7 as string)
                    ,cast(8 as string)
                    ,cast(9 as string)
                    ,cast(10 as string)
                ) as value_str
        ) as value
        lateral view posexplode(split(value.value_str, ',')) poi as x, y
    ) poi
) t
;
```

# 五、计算一段日期下最长连续日期的天数

```sql
/*
    计算一段日期下最长连续日期的天数
    每个最长连续日期下，保留连续日期的开始日期
    如果有多个最长连续日期，则保留所有
    日期表date：
     --------
    |dt      |
    |20211001|
    |20211002|
    |20211003|
    |20211005|
    |20211006|
    |20211007|
    |20211009|
    |20211010|
    |20211013|
    |20211014|
    |20211015|
     --------
*/
with date as (
    select
        dt
    from (
        select
            date_format(date_add(from_unixtime(unix_timestamp('20211001', 'yyyyMMdd'), 'yyyy-MM-dd'), idx), 'yyyyMMdd') as dt
        from (
            select
                datediff(from_unixtime(unix_timestamp('20211015', 'yyyyMMdd'), 'yyyy-MM-dd'), from_unixtime(unix_timestamp('20211001', 'yyyyMMdd'), 'yyyy-MM-dd')) as day
        ) as days
        lateral view posexplode(split(repeat(',', day), ',')) rpt as idx, val
    ) as t
    where
        t.dt not in ('20211004', '20211008', '20211011', '20211012')
)

select
    begin_dt
    ,continue_dt
from (
    select
        begin_dt
        ,continue_dt
        ,dense_rank() over(order by continue_dt desc) as continue_dt_rank
    from (
        select
            min(dt) as begin_dt
            ,count(1) as continue_dt
        from (
            select
                dt
                ,(diff_dt - dt_rank) as value
            from (
                select
                    dt
                    ,begin_dt
                    ,row_number() over(order by dt) as dt_rank
                    ,datediff(from_unixtime(unix_timestamp(dt, 'yyyyMMdd'), 'yyyy-MM-dd'), from_unixtime(unix_timestamp(begin_dt, 'yyyyMMdd'), 'yyyy-MM-dd')) as diff_dt
                from (
                    select
                        dt
                        ,'20211001' as begin_dt
                    from
                        date
                )
            )
        )
        group by
            value
    )
)
where
    continue_dt_rank = 1
```

# 六、计算窗口内的累加和

```sql
/*
    计算窗口内的累加和
    语法：sum(字段1) over(partition by 字段2 order by 字段3 rows between unbounded preceding and current row) as 新字段名
    说明：
    1、sum(字段1)：对over()窗口内字段1的求和
    2、over(partition by 字段2 order by 字段3)：按照字段2分组、组内按照字段3进行排序
    3、rows between unbounded preceding and current row：限定窗口中行的开始和结束范围为从当前行开始到之前的所有行

    表：tt
     -------------------------------
    |name    mon        total_amount|
    |A       2015-01	38          |
    |B	     2015-01	30          |
    |C	     2015-01	30          |
    |A	     2015-02	10          |
    |C	     2015-02	40          |
    |B	     2015-02	15          |
    |A	     2015-03	20          |
    |B	     2015-03	45          |
    |C	     2015-03	30          |
     -------------------------------
*/
select
    name
    ,mon
    ,total_amount
    ,sum(total_amount) over(partition by name order by mon rows between unbounded preceding and current row) as sum_total_amount
from (
    select
        name
        ,mon
        ,total_amount
    from
        tt
) as t
;
```

# 七、一组数第一个非0值开始的平均值

```sql
/*
    计算一组数的平均值，要求从第一个非0值开始计算
    流水表amount：
    id  amt1    amt2    amt3    amt4    amt5    amt6    amt7
     --------------------------------------------------------
    |0    0       0       100     200     300     0       400|
    |1    0       1       100     200     300     1       400|
    |2    1       0       100     200     300     0       400|
    |3    0       1       100     200     300     1       400|
    |4    1       0       100     200     300     0       400|
    |5    0       1       100     200     300     1       400|
     --------------------------------------------------------
*/

select
    id
    ,(sum(coalesce(val, 0)) / count(1)) as avg_val
from (
    select
        t.id
        ,cast(amt.val as double) as val
    from (
        select
            id
            ,coalesce(split(amt_str, '^(0,)*')[1], split(amt_str, '^(0,)*')[0]) as amt_str
        from (
            select
                id
                ,concat_ws(
                    ','
                    ,cast(coalesce(amt1, 0) as string)
                    ,cast(coalesce(amt2, 0) as string)
                    ,cast(coalesce(amt3, 0) as string)
                    ,cast(coalesce(amt4, 0) as string)
                    ,cast(coalesce(amt5, 0) as string)
                    ,cast(coalesce(amt6, 0) as string)
                    ,cast(coalesce(amt7, 0) as string)
                ) as amt_str
            from
                amount
        )
    ) as t
    lateral view explode(split(amt_str, ',')) amt as val
) as t
group by
    id
```