# 一、实现行排序序号

```sql
select
    (@row_number := @row_number + 1) as rn
    ,channel_id
    ,data_source
    ,sku_id
    ,grab_time
from
    market_sku as t1, (select @row_number := 0) as t2
order by
    channel_id, data_source, sku_id, grab_time desc
```

# 二、实现分组排序序号

```sql
select
    @row_number := if(@channel_id = channel_id and @data_source = data_source and @sku_id = sku_id, @row_number + 1, 1) as rn
    ,@channel_id := channel_id
    ,@data_source := data_source
    ,@sku_id := sku_id
    ,channel_id
    ,data_source
    ,sku_id
    ,grab_time
from
    market_sku
where
    dt = '20230303'
order by
    channel_id
    ,data_source
    ,sku_id
    ,grab_time desc
```