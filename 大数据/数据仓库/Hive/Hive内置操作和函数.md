# 一、内置操作

## 1.1 关系运算符

| 运算符                                                       | 操作数类型       | 含义                                                         |
| ------------------------------------------------------------ | ---------------- | ------------------------------------------------------------ |
| A = B                                                        | 所有原始数据类型 | 判断A和B是否相等                                             |
| A == B                                                       | 所有原始数据类型 |                                                              |
| A <=> B                                                      | 所有原始数据类型 | 1、如果A和B都等于NULL，返回TRUE2、如果A或B其中之一为NULL，返回FALSE3、如果A和B都不等于NULL，返回结果与运算符=相同 |
| A <> B                                                       | 所有原始数据类型 | 1、如果A或B等于NULL，返回NULL2、否则（1）如果A不等于B，返回TRUE；（2）否则返回FALSE |
| A != B                                                       | 所有原始数据类型 |                                                              |
| A < B                                                        | 所有原始数据类型 | 1、如果A或B等于NULL，返回NULL2、否则（1）如果A小于B，返回TRUE；（2）否则返回FALSE |
| A <= B                                                       | 所有原始数据类型 | 1、如果A或B等于NULL，返回NULL2、否则（1）如果A小于等于B，返回TRUE；（2）否则返回FALSE |
| A > B                                                        | 所有原始数据类型 | 1、如果A或B等于NULL，返回NULL2、否则（1）如果A大于B，返回TRUE；（2）否则返回FALSE |
| A >= B                                                       | 所有原始数据类型 | 1、如果A或B等于NULL，返回NULL2、否则（1）如果A大于等于B，返回TRUE；（2）否则返回FALSE |
| A [NOT] BETWEEN B AND C                                      | 所有原始数据类型 | 1、如果A或B或C等于NULL，返回NULL2、否则（1）如果A大于等于B并且小于等于C，返回TRUE；（2）否则返回FALSE3、使用NOT表示相反含义 |
| A IS [NOT] NULL                                              | 所有类型         | 1、如果A等于NULL，返回TRUE2、否则返回FALSE3、使用NOT表示相反含义 |
| A IS [NOT] (TRUE｜FALSE)                                     | BOOLEAN          | 1、如果A表达式满足（TRUE｜FALSE），返回TRUE2、否则返回FALSE3、如果A等于NULL，返回FALSE |
| A [NOT] LIKE B                                               | STRING           | 1、如果A或B等于NULL，返回NULL2、如果A匹配简单正则表达式B，返回TRUE3、否则返回FALSE |
| A RLIKE B                                                    | STRING           | 1、如果A或B等于NULL，返回NULL2、如果A中任意一个子串（可能为空）可以匹配简单正则表达式B，返回TRUE3、否则返回FALSE |
| A REGEXP B                                                   | STRING           |                                                              |
| 备注：1、简单正则表达式中包含两个字符（1）下划线“_”表示单个字符（2）百分号“%”表达多个字符 |                  |                                                              |

## 1.2 算数运算符

| 运算符                                                       | 操作数类型   | 含义                                        |
| ------------------------------------------------------------ | ------------ | ------------------------------------------- |
| A + B                                                        | 所有数值类型 | 结果类型为最小公共父类型                    |
| A - B                                                        | 所有数值类型 |                                             |
| A * B                                                        | 所有数值类型 |                                             |
| A / B                                                        | 所有数值类型 | 结果类型大部分情况下为DOUBLE                |
| A DIV B                                                      | Integer类型  | 返回A/B的整数部分                           |
| A % B                                                        | 所有数值类型 | 1、结果类型为最小公共父类型2、返回A/B的余数 |
| A & B                                                        | 所有数值类型 | 1、结果类型为最小公共父类型2、按位与运算    |
| A \| B                                                       | 所有数值类型 | 1、结果类型为最小公共父类型2、按位或运算    |
| A ^ B                                                        | 所有数值类型 | 1、结果类型为最小公共父类型2、按位异或运算  |
| ~A                                                           | 所有数值类型 | 1、结果类型与A相同2、按位取反运算           |
| 备注：1、以上所有操作的返回值都是数值类型2、如果任意操作数为NULL，则返回结果也是NULL |              |                                             |

## 1.3 逻辑运算符

| 运算符                                       | 操作数类型  | 含义                                                         |
| -------------------------------------------- | ----------- | ------------------------------------------------------------ |
| A AND B                                      | BOOLEAN类型 | 1、如果A或B等于NULL，返回NULL2、否则：（1）如果A和B等于TRUE，返回TRUE；（2）否则返回FALSE |
| A OR B                                       | BOOLEAN类型 | 1、如果A或B等于TRUE，返回TRUE2、如果A和B都等于FALSE，返回FALSE3、如果A或B等于NULL，返回NULL |
| NOT A                                        | BOOLEAN类型 | 1、如果A等于FALSE，返回TRUE2、如果A等于TRUE，返回FALSE3、如果A等于NULL，返回NULL |
| !A                                           | BOOLEAN类型 |                                                              |
| A IN (val1, val2, ...)                       | BOOLEAN类型 | 1、如果A等于(val1, val2, ...)中的任意一个值，返回TRUE        |
| A NOT IN (val1, val2, ...)                   | BOOLEAN类型 | 1、如果A不等于(val1, val2, ...)中的任意一个值，返回TRUE      |
| [NOT] EXISTS (子查询)                        |             | 1、如果子查询至少返回一行，返回TRUE                          |
| 备注：1、以上所有操作的返回值都是BOOLEAN类型 |             |                                                              |

## 1.4 字符串运算符

| 运算符   | 操作数类型 | 含义              |
| -------- | ---------- | ----------------- |
| A \|\| B | string     | 1、连接两个操作数 |

## 1.5 复杂数据类型构造函数

| 运算符                                          | 操作数                            | 含义                                        |
| ----------------------------------------------- | --------------------------------- | ------------------------------------------- |
| struct                                          | (val1, val2, val3, ...)           | 根据指定值，创建一个struct实例              |
| array                                           | (val1, val2, val3, ...)           | 根据指定值，创建一个array实例               |
| create_union                                    | (tag, val1, val2, ...)            | 使用 tag 参数指向的值创建联合类型           |
| named_struct                                    | (name1, val1, name2, val2, ...)   | 根据指定的names和values，创建一个struct实例 |
| map                                             | (key1, value1, key2, value2, ...) | 根据指定的key/value对，创建一个map实例      |
| 备注：1、以上所有操作用于构造复杂数据类型的实例 |                                   |                                             |

## 1.6 复杂数据类型运算符

| 运算符                                            | 操作数类型                     | 含义                                |
| ------------------------------------------------- | ------------------------------ | ----------------------------------- |
| A[n]                                              | A是array类型n是int类型         | 1、返回A中的第n个元素2、下标从0开始 |
| M[key]                                            | M是一个Map<K, V>key类型与K相同 | 1、返回key所对应的那个value         |
| S.x                                               | S是一个struct                  | 1、返回S中的属性x的值               |
| 备注：1、以上所有操作提供访问复杂类型中元素的机制 |                                |                                     |

# 二、内置函数

## 2.1 算数运算函数

| 返回类型                                                | 函数签名                                                     | 含义                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| BIGINT                                                  | round(DOUBLE a)                                              | 返回a的四舍五入值                                            |
| DOUBLE                                                  | round(DOUBLE a, INT d)                                       | 返回a的四舍五入值，结果保留d位小数                           |
| BIGINT                                                  | bround(DOUBLE a)                                             | 个位若是奇数则四舍五入，若是偶数则五舍六入                   |
| DOUBLE                                                  | bround(DOUBLE a, INT d)                                      | 小数位的d位若是奇数则四舍五入，若是偶数则五舍六入，结果保留d位小数 |
| BIGINT                                                  | floor(DOUBLE a)                                              | 返回小于等于a的最大整数值                                    |
| BIGINT                                                  | ceil(DOUBLE a)ceiling(DOUBLE a)                              | 返回大于等于a的最小整数值                                    |
| DOUBLE                                                  | rand()rand(INT seed)                                         | 1、返回一个分布为[0, 1]之间的均匀分布的随机值2、如果指定了seed，则每次返回的随机值是确定的 |
| DOUBLE                                                  | exp(DOUBLE a)exp(DECIMAL a)                                  | 返回ea                                                       |
| DOUBLE                                                  | ln(DOUBLE a)ln(DECIMAL a)                                    | 返回lna，以e为底数的对数                                     |
| DOUBLE                                                  | log10(DOUBLE a)log10(DECIMAL a)                              | 返回log10a                                                   |
| DOUBLE                                                  | log2(DOUBLE a)log2(DECIMAL a)                                | 返回log2a                                                    |
| DOUBLE                                                  | log(DOUBLE base, DOUBLE a)log(DECIMAL base, DECIMAL a)       | 返回logbasea，以base为底数的对数                             |
| DOUBLE                                                  | pow(DOUBLE a, DOUBLE p)power(DOUBLE a, DOUBLE p)             | 返回ap                                                       |
| DOUBLE                                                  | sqrt(DOUBLE a)sqrt(DECIMAL a)                                | 返回a的平方根                                                |
| STRING                                                  | bin(BIGINT a)                                                | 返回a的二进制字符串表示                                      |
| STRING                                                  | hex(BIGINT a)hex(STRING a)hex(BINARY a)                      | 1、如果参数a类型是BIGINT或者BINARY，则返回它的十六进制字符串表示2、如果参数a类型是STRING，则返回这个字符串的十六进制表示，结果依然是个字符串 |
| BINARY                                                  | unhex(STRING a)                                              | 返回十六进制字符串格式的参数a的二进制表示                    |
| STRING                                                  | conv(BIGINT num, INT from_base, INT to_base)conv(STRING num, INT from_base, INT to_base) | 将from_base进制表示的参数num转换为以to_base进制表示          |
| DOUBLE                                                  | abs(DOUBLE a)                                                | 返回a的绝对值表示                                            |
| INTDOUBLE                                               | pmod(INT a, INT b)pmod(DOUBLE a, DOUBLE b)                   | 返回a对b取模结果的绝对值                                     |
| DOUBLE                                                  | sin(DOUBLE a)sin(DECIMAL a)                                  | 返回sin(a)，a为弧度                                          |
| DOUBLE                                                  | asin(DOUBLE a)asin(DECIMAL a)                                | 1、如果-1<=a<=1，返回arcsin(a)2、否则，返回NULL              |
| DOUBLE                                                  | cos(DOUBLE a)cos(DECIMAL a)                                  | 返回cos(a)，a为弧度                                          |
| DOUBLE                                                  | acos(DOUBLE a)acos(DECIMAL a)                                | 1、如果-1<=a<=1，返回arccos(a)2、否则，返回NULL              |
| DOUBLE                                                  | tan(DOUBLE a)tan(DECIMAL a)                                  | 返回tan(a)，a为弧度                                          |
| DOUBLE                                                  | atan(DOUBLE a)atan(DECIMAL a)                                | 1、如果-1<=a<=1，返回arctan(a)2、否则，返回NULL              |
| DOUBLE                                                  | degrees(DOUBLE a)degrees(DECIMAL a)                          | 返回参数弧度a的度数表示                                      |
| DOUBLE                                                  | radians(DOUBLE a)radians(DECIMAL a)                          | 返回度数a的弧度表示                                          |
| INTDOUBLE                                               | positive(INT a)positive(DOUBLE a)                            | 返回a                                                        |
| INTDOUBLE                                               | negative(INT a)negative(DOUBLE a)                            | 返回-a                                                       |
| DOUBLEINT                                               | sign(DOUBLE a)sign(DECIMAL a)                                | 1、如果a是正数，返回1.02、如果a是负数，返回-1.03、否则，返回0.0 |
| DOUBLE                                                  | e()                                                          | 返回自然对数e                                                |
| DOUBLE                                                  | pi()                                                         | 返回pi                                                       |
| BIGINT                                                  | factorial(INT a)                                             | 返回a的阶乘a!，a的合法值范围为[0, 20]                        |
| DOUBLE                                                  | cbrt(DOUBLE a)                                               | 返回a的立方根                                                |
| INTBIGINT                                               | shiftleft(TINYINT\|SMALLINT\|INT a, INT b)shiftleft(BIGINT a, INT b) | 参数a按位左移b位                                             |
| INTBIGINT                                               | shiftright(TINYINT\|SMALLINT\|INT a, INT b)shiftright(BIGINT a, INT b) | 参数a按位右移b位                                             |
| INTBIGINT                                               | shiftrightunsigned(TINYINT\|SMALLINT\|INT a, INT b),shiftrightunsigned(BIGINT a, INT b) | 参数a按位无符号右移b位                                       |
| T                                                       | greatest(T v1, T v2, ...)                                    | 1、返回列表中的最大值2、当列表中有一个或多个NULL时，返回NULL |
| T                                                       | least(T v1, T v2, ...)                                       | 1、返回列表中的最小值2、当列表中有一个或多个NULL时，返回NULL |
| INT                                                     | width_bucket(NUMERIC expr, NUMERIC min_value, NUMERIC max_value, INT num_buckets) | 1、将[min_value, max_value]划分为大小相同的num_buckets个桶，返回expr所在桶2、桶的范围为[0, num_buckets + 1]3、如果expr < min_value，返回04、如果expr >= max_value，返回num_buckets + 1 |
| 备注：1、当参数为NULL的时候，大多数情况下返回结果为NULL |                                                              |                                                              |

## 2.2 集合函数

| 返回类型 | 函数签名                        | 含义                                                    |
| -------- | ------------------------------- | ------------------------------------------------------- |
| INT      | size(Map<K.V>)                  | 返回Map中元素的数量                                     |
| INT      | size(Array<T>)                  | 返回Array中元素的数量                                   |
| ARRAY<K> | map_keys(Map<K.V>)              | 返回Map中K的Array集合                                   |
| ARRAY<V> | map_values(Map<K.V>)            | 返回Map中V的Array集合                                   |
| BOOLEAN  | array_contains(Array<T>, value) | 1、如果Array中包含值value，则返回TRUE2、否则，返回FALSE |
| ARRAY<T> | sort_array(Array<T>)            | 以自然排序方式对Array列表进行升序排序                   |

## 2.3 类型转换函数

| 返回类型           | 函数签名                 | 含义                                             |
| ------------------ | ------------------------ | ------------------------------------------------ |
| BINARY             | binary(string \| binary) | 参数类型转换为BINARY                             |
| 跟随转换的目标类型 | cast(expr as <type>)     | 1、expr转换为<type>类型2、如果转换失败，返回NULL |

## 2.4 日期函数

| 返回类型                             | 函数签名                                                     | 含义                                                         |
| ------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| STRING                               | from_unixtime(BIGINT unixtime[, STRING format])              | 1、指定秒数unixtime，返回距离(1970-01-01 00:00:00 UTC)unixtime秒的日期2、如果制定了日期格式formt，按照日期格式输出，默认格式为“yyyy-MM-dd HH:mm:ss” |
| BIGINT                               | unix_timestamp()                                             | 返回距离(1970-01-01 00:00:00 UTC)的秒数                      |
| BIGINT                               | unix_timestamp(STRING date)                                  | 1、返回日期date距离(1970-01-01 00:00:00 UTC)的秒数2、date日期的格式为“yyyy-MM-dd HH:mm:ss” |
| BIGINT                               | unix_timestamp(STRING date, STRING pattern)                  | 1、返回日期date距离(1970-01-01 00:00:00 UTC)的秒数2、pattern为date日期的格式 |
| 2.1.0版本前：STRING2.1.0版本后：DATE | to_date(STRING timestamp)                                    | 1、返回timestamp中日期的部分2、日期部分的格式为“yyyy-MM-dd”  |
| INT                                  | year(STRIGN date)                                            | 1、返回日期date中年的部分2、日期部分的格式为“yyyy-MM-dd”     |
| INT                                  | quarter(DATE/TIMESTAMP/STRING)                               | 1、返回日期所在的季度，以数值[1, 2, 3, 4]表示四个季度2、日期部分的格式为“yyyy-MM-dd” |
| INT                                  | month(STRING date)                                           | 1、返回日期date中月的部分2、日期部分的格式为“yyyy-MM-dd”     |
| INT                                  | day(STRING date)dayofmonth(STRING date)                      | 1、返回日期date中日的部分2、日期部分的格式为“yyyy-MM-dd”     |
| INT                                  | hour(STRING date)                                            | 1、返回时间中小时的部分2、时间部分的格式为“HH:mm:ss”         |
| INT                                  | minute(STRING date)                                          | 1、返回时间中分钟的部分2、时间部分的格式为“HH:mm:ss”         |
| INT                                  | second(STRING date)                                          | 1、返回时间中秒的部分2、时间部分的格式为“HH:mm:ss”           |
| INT                                  | weekofyear(STRING date)                                      | 1、返回日期date为今年的第几周2、日期部分的格式为“yyyy-MM-dd” |
| INT                                  | extract(field FROM source)                                   | 1、从source中提取：day、dayofweek、hour、minute、month、quarter、second、week和year2、source支持的类型为DATE、TIMESTAMP、INTERVAL或者STRING，并且可以转换为DATE或者TIMESTAMP3、例如select extract(month from "2016-10-20") results in 10.select extract(hour from "2016-10-20 05:06:07") results in 5.select extract(dayofweek from "2016-10-20 05:06:07") results in 5.select extract(month from interval '1-3' year to month) results in 3.select extract(minute from interval '3 12:20:30' day to second) results in 20. |
| INT                                  | datediff(STRING enddate, STRING startdate)                   | 1、返回日期enddate和startdate之间相差的天数2、日期的格式为“yyyy-MM-dd” |
| 2.1.0版本前：STRING2.1.0版本后：DATE | date_add(DATE/TIMESTAMP/STRNG startdate, TINYINT/SMALLINT/INT days) | 1、在日期startdate的基础上，增加days天，返回增加天数后的日期2、日期的格式为“yyyy-MM-dd”3、返回的日期的格式为“yyyy-MM-dd” |
| 2.1.0版本前：STRING2.1.0版本后：DATE | date_sub(DATE/TIMESTAMP/STRNG startdate, TINYINT/SMALLINT/INT days) | 1、在日期startdate的基础上，减少days天，返回减少天数后的日期2、日期的格式为“yyyy-MM-dd”3、返回的日期的格式为“yyyy-MM-dd” |
| TIMESTAMP                            | from_utc_timestamp({any primitive type} ts, STRING timezone) | 转换UTC时间ts到指定的时区timezone                            |
| TIMESTAMP                            | to_utc_timestamp({any primitive type} ts, STRING timezone)   | 转换时间戳ts到UTC时间                                        |
| DATE                                 | current_date                                                 | 1、返回当前日期2、日期格式为“yyyy-MM-dd”                     |
| TIMESTAMP                            | current_timestamp                                            | 返回当前时间戳                                               |
| STRING                               | add_months(STRING start_date, INT num_months, output_date_format) | 1、在start_date的基础上对月份增加num_months2、output_date_format指定返回结果的输出格式 |
| STRING                               | last_day(STRING date)                                        | 1、返回日期所在月份的最后一天2、date的格式为“yyyy-MM-dd HH:mm:ss”或 “yyyy-MM-dd”3、返回日期的格式为“yyyy-MM-dd” |
| STRING                               | next_day(STRING start_date, STRING day_of_week)              | 1、返回日期start_date的下一天2、day_of_week可以使用2个字母、3个字符或者完整的名字（例如：Mo，TUE、FRIDAY） |
| STRING                               | trunc(STRING date, STRING format)                            | 1、返回截断为指定格式的日期2、如果选择格式YY，则截断后的MM-dd为当年的第一个月第一天3、如果选择格式MM，则截断后的dd为当月的第一天4、支持的格式为MONTH/MON/MM, YEAR/YYYY/YY |
| DOUBLE                               | months_between(date1, date2)                                 | 1、返回日期date1和date2相差的月份数2、如果date1晚于date2，返回结果为正数3、如果date1早于date2，返回结果为负数4、如果date1和date2是同一个月的同一天或者最后一天，则结果始终是整数5、否则，结果为保留8位的DOUBLE类型 |
| STRING                               | date_format(DATE/TIMESTAMP/STRING ts, STRING fmt)            | 将ts按照fmt格式返回                                          |

## 2.5 条件函数

| 返回类型 | 函数签名                                                   | 含义                                                         |
| -------- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| T        | if(BOOLEAN testCondition, T valueTrue, T valueFalseOrNull) | 1、如果testContidion为TRUE，返回valueTrue2、否则，返回valueFalseOrNull |
| BOOLEAN  | isnull(a)                                                  | 1、如果a为NULL，返回TRUE2、否则，返回FALSE                   |
| BOOLEAN  | isnotnull(a)                                               | 1、如果a不为NULL，返回TRUE2、否则，返回FALSE                 |
| T        | nvl(T value, T default_vlaue)                              | 1、如果value为NULL，返回default_value2、否则，返回value      |
| T        | coalesce(T v1, T v2,...)                                   | 1、如果第一个参数v1不为NULL，返回v12、否则，如果其他所有参数v都为NULL，返回NULL |
| T        | case a when b then c[when d then e]* [else f] end          | 1、当a等于b，返回c2、当a等于d，返回e3、否则，返回f           |
| T        | case when a then b [when c then d]* [else e] end           | 1、如果a为TRUE，返回b2、如果c为TRUE，但会d3、否则，返回e     |
| T        | nullif(a, b)                                               | 1、如果a等于b，返回NULL2、否则返回a                          |
| void     | assert_true(BOOLEAN condition)                             | 1、如果condition为FALSE，抛出异常2、否则返回NULL             |

## 2.6 字符串函数

| 返回类型                      | 函数签名                                                     | 含义                                                         |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| INT                           | ascii(STRING str)                                            | 返回字符串中第一个字符的ASCLL码值                            |
| STRING                        | base64(BINARY bin)                                           | 将二进制参数bing转换为base64字符串                           |
| INT                           | character_length(STRING str)                                 | 返回字符串str中包含的UTF-8字符数                             |
| STRING                        | chr(BIGINT \| DOUBLE a)                                      | 1、将数字a转换为对应的ASCII字符2、如果a的值大于256，则返回chr(a % 256) |
| STRING                        | concat(STRING \| BINARY a, STRING \| BINARY b...)            | 按照顺序拼接字符串或者二进制参数                             |
| ARRAY<STRUCT<STRING, DOUBLE>> | context_ngrams(ARRAY<ARRAY<STRING>>, ARRAY<STRING> int k, int pf) | 1、与sentence函数结合使用2、分词后，统计分词结果中与数组中指定的单词一起出现（包括顺序）频次最高的Top-K结果`hive> SELECT context_ngrams(sentences('hello word!hello hive,hi hive,hello  hive'),array('hello',null),3) FROM iteblog; [{"ngram":["hive"],"estfrequency":2.0},{"ngram":["word"],"estfrequency":1.0}] -- 该查询中，统计的是与’hello’一起出现，并且在 hello 后面的频次最高的 TOP-3 结果中，hello 与 hive 同时出现 2 次，hello 与 word 同时出现 1 次。 hive> SELECT context_ngrams(sentences('hello word!hello hive,hi hive,hello  hive'),array(null,'hive'),3) FROM iteblog; [{"ngram":["hello"],"estfrequency":2.0},{"ngram":["hi"],"estfrequency":1.0}] -- 该查询中，统计的是与’hive’一起出现，并且在 hive 之前的频次最高的 TOP-3` |
| STRING                        | concat_ws(STRING sep, STRING a, STRING b,...)concat_ws(STRING sep, ARRAY<STRING>) | 1、功能与concat类似，在拼接的过程中增加分隔符sep2、如果参数为NULL，则不添加 |
| STRING                        | decode(BINARY bin, STRING charset)                           | 1、如果bin或charset为NULL，返回NULL2、否则，将第一个参数bin解码为字符串3、可选的charset为（'US-ASCII', 'ISO-8859-1', 'UTF-8', 'UTF-16BE', 'UTF-16LE', 'UTF-16'） |
| STRING                        | elt(int n, STRING str1, STRING str2, STRING str3,...)        | 1、返回字符串列表(str1, str2, str3,...)中的第n个字符串（位置下标从1开始）2、如果n小于1或者大于字符串列表的长度，则返回NULL |
| BINARY                        | encode(STRING src, STRING charset)                           | 1、如果bin或charset为NULL，返回NULL2、否则，将第一个参数str编码为二进制3、可选的charset为（'US-ASCII', 'ISO-8859-1', 'UTF-8', 'UTF-16BE', 'UTF-16LE', 'UTF-16'） |
| INT                           | field(T val, T val1, T val2,...)                             | 1、如果val为NULL，返回02、否则，返回val在列表（val1, val2, ...）中的位置（位置下标从1开始） |
| INT                           | find_in_set(STRING str, STRING strList)                      | 1、如果str或strList为NULL，返回NULL2、如果str包含逗号分隔符，返回03、否则，返回str在strList中第一次出现的位置（位置下标从1开始） |
| STRING                        | format_number(NUMBER x, INT d)                               | 1、格式化数值x为“#,###,###.##”形式，并且结果保留d位小数，以字符串格式返回2、如果d等于0，则返回数值没有小数点和小数部分 |
| STRING                        | get_json_object(STRING json_string, STRING path)             | 1、json_string填写json对象变量，path使用$表示json变量标识，然后用 . 或 [] 读取对象或数组2、如果输入的json字符串无效，那么返回NULL，每次只能返回一个数据项。`data = { "store":        {         "fruit":[{"weight":8,"type":"apple"}, {"weight":9,"type":"pear"}],           "bicycle":{"price":19.95,"color":"red"}         },  "email":"amy@only_for_json_udf_test.net",  "owner":"amy"  } -- get单层值 hive> select  get_json_object(data, '$.owner') from test; 结果：amy -- get多层值 hive> select  get_json_object(data, '$.store.bicycle.price') from test; 结果：19.95 -- get数组值[] hive> select  get_json_object(data, '$.store.fruit[0]') from test; 结果：{"weight":8,"type":"apple"}` |
| BOOLEAN                       | in_file(STRING str, STRING filename)                         | 如果字符串str在文件filename中显示为整行，则返回TRUE          |
| INT                           | instr(STRING str, STRING substr)                             | 1、如果str或substr为NULL，返回NULL2、如果str中没有匹配到substr子串，返回03、否则，返回substr子串在str中第一次出现的下标位置（下标位置从1开始） |
| INT                           | length(STRING a)                                             | 返回字符串a的长度                                            |
| INT                           | locate(STRING substr, STRING str[, INT pos])                 | 1、返回子串substr在字符串str中第一次出现的位置2、如果有pos位置参数，在返回从pos位置开始第一次出现的位置 |
| STRING                        | lower(STRING a)lcase(STRING a)                               | 将字符串a中的大写字符转换为小写字符                          |
| STRING                        | lpad(STRING str, INT len, STRING pad)                        | 1、如果str的长度大于等于len，返回str的前len长度的部分2、否则，在str的首部填充字符串pad，直到长度达到len |
| STRING                        | ltrim(STRING a)                                              | 返回去除字符串a首部空格的字符串                              |
| ARRAY<STRUCT<STRING, DOUBLE>> | ngrams(ARRAY<ARRAY<STRING>>, INT n, int k, int pf)           | 1、与sentences()函数一起使用2、分词后，统计分词结果中n个单词一起出现频次最高的TOP-k |
| INT                           | octet_length(STRING str)                                     | 返回字符串基于UTF-8编码所需要的字节数                        |
| STRING                        | parse_url(STRING urlString, STRING partToExtract [, STRING keyToExtract] | 1、从URL中返回指定的部分2、合法的partToExtract值包括：HOST, PATH, QUERY, REF, PROTOCOL, AUTHORITY, FILE和USERINFO3、如果partToExtract值为'QUERY'，则keyToExtract的值为参数的键值 |
| STRING                        | printf(STRING format, Obj...args)                            | 按照printf-style格式对字符串进行格式化输出                   |
| STRING                        | quote(STRING text)                                           | 1、返回带引号的字符串2、如果text为NULL，则返回NULL           |
| STRING                        | regexp_extract(STRING subject, STRING pattern, INT index)    | 1、返回使用正则表达式pattern从字符串subject中抽取匹配字符串  |
| STRING                        | regexp_replace(STRING initial_string, STRING pattern, STRING replacement) | 1、将字符串initial_string中符合正则表达式pattern的部分，替换为replacement字符串 |
| STRING                        | repeat(STRING str, int n)                                    | 返回str重复n次的字符串                                       |
| STRING                        | replace(STRING a, STRING old, STRING new)                    | 对字符串a中出现的old字符串，全部替换为new字符串              |
| STRING                        | reverse(STRING a)                                            | 返回字符串a的逆序                                            |
| STRING                        | rpad(STRING str, INT len, STRING pad)                        | 1、如果str的长度大于等于len，返回str的前len长度的部分2、否则，在str的尾部填充字符串pad，直到长度达到len |
| STRING                        | rtrim(STRING a)                                              | 返回去除字符串a尾部空格的字符串                              |
| ARRAY<ARRAY<STRING>>          | sentences(STRING str, STRING lang, STRING locale)            | 1、将str拆分成sentences数组，其中每个sentences都是一个单词数组2、'lang'和'country'参数是可选的，如果省略，则使用默认语言环境3、如果指定了lang 应该是两个字母的ISO-639语言代码(例如'en')4、如果指定了country应该是两个字母的ISO-3166代码(例如'us')5、并非所有国家/地区和语言代码都受到完全支持，如果指定了不受支持的代码，则使用默认语言环境来处理该字符串 |
| STRING                        | space(INT n)                                                 | 返回包含n个空格的字符串                                      |
| ARRAY                         | split(STRING str, STRING pat)                                | 根据正则表达式pat切分字符串str                               |
| MAP<STRING, STRING>           | str_to_map(text [, delimiter1, delimiter2])                  | 1、将text切分为map，其中delimiter1用于切分key-value对，delimiter2用于切分key-value2、delimiter1默认为“,”，delimiter2默认为“:” |
| STRING                        | substr(STRING \| BINARY a, INT start)substring(STRING \| BINARY a, INT start) | 返回字符串或二进制a从位置start开始到结尾的内容，结果返回字符串 |
| STRING                        | substr(STRING \| BINARY a, INT start, INT len)substring(STRING \| BINARY a, INT start, INT len) | 返回字符串或二进制a从位置start开始，长度最长为len的内容，结果返回字符串 |
| STRING                        | substring_index(STRING a, STRING delim, INT count)           | 1、如果count为正数，返回从字符串a左侧开始第count个delim左侧的字符串2、如果count为负数，返回从字符串a右侧开始第count个delim右侧的字符串 |
| STRING                        | translate(STRING \| CHAR \| VARCHAR input, STRING \| CHAR \| VARCHAR from, STRING \| CHAR \| VARCHAR to) | 1、如果input或from或to为NULL，则返回NULL2、将input字符串中出现的from字符串替换为to字符串 |
| STRING                        | trim(STRING a)                                               | 返回去除字符串a首尾两侧空格的字符串                          |
| BINARY                        | unbase64(STRING str)                                         | 对base64字符串str解码为二进制                                |
| STRING                        | upper(STRING a)ucase(STRING a)                               | 将字符串a中的小写字符转换为大写字符                          |
| STRING                        | initcap(STRING a)                                            | 1、对字符串a中的所有单词的首字符大写，其余字符小写2、单词的分隔符为空格 |
| INT                           | levenshtein(STRING a, STRING b)                              | 返回两个字符串的莱文斯坦距离（指两个字串之间，由一个转成另一个所需的最少编辑操作次数。 允许的编辑操作包括将一个字符替换成另一个字符，插入一个字符，删除一个字符。） |
| STRING                        | soundex(STRING a)                                            | 返回字符串a的soundex编码Soundex编码涉及将每个单词转换成一连串的数字，其中每一个数字代表一个字母： 1表示B、F、P或V 2表示C、G、J、K、Q、S、X或Z 3表示D或T 4表示L 5表示M或N 6表示R 字母A、E、I、O、U、H、W和Y在Soundex编码中不被表示，并且如果存在连续的字母，这些字母是用相同的数字表示的，那么这些字母就仅用一个数字来表示。具有相同Soundex编码的单词被认为是相等的。 |

## 2.7 数据屏蔽函数

| 返回类型 | 函数签名                                                     | 含义                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| STRING   | mask(STRING str[, STRING upper[, STRING lower[, STRING number]]]) | 1、将字符串转换为掩码的形式，默认情况下（1）大写字母转换为“X”（2）小写字母转换为“x”（3）数字转换为“n”2、第二个参数upper可以指定大写字母转换字符3、第三个参数lower可以指定小写字母转换字符4、第四个参数number可以指定数字转换字符 |
| STRING   | mask_first_n(STRING str [, INT n])                           | 1、将字符串的前n个字符转换为掩码的形式，默认情况下（1）大写字母转换为“X”（2）小写字母转换为“x”（3）数字转换为“n”2、第二个参数upper可以指定大写字母转换字符3、第三个参数lower可以指定小写字母转换字符4、第四个参数number可以指定数字转换字符 |
| STRING   | mask_last_n(STRING str [, INT n])                            | 1、将字符串的后n个字符转换为掩码的形式，默认情况下（1）大写字母转换为“X”（2）小写字母转换为“x”（3）数字转换为“n”2、第二个参数upper可以指定大写字母转换字符3、第三个参数lower可以指定小写字母转换字符4、第四个参数number可以指定数字转换字符 |
| STRING   | mask_show_first_n(STRING str [, INT n])                      | 1、将字符串的前n个字符不转换为掩码，而剩余字符转换为掩码形式，默认情况下（1）大写字母转换为“X”（2）小写字母转换为“x”（3）数字转换为“n” |
| STRING   | mask_show_last_n(STRING str [, INT n])                       | 1、将字符串的后n个字符不转换为掩码，而剩余字符转换为掩码形式，默认情况下（1）大写字母转换为“X”（2）小写字母转换为“x”（3）数字转换为“n” |
| STRING   | mask_hash(STRING \| CHAR \|\| VARCHAR str)                   | 1、返回字符串str的哈希值，其哈希值具有一致性2、对于非字符串类型，返回值为null |

## 2.8 其他

| 返回类型       | 函数签名                                             | 含义                                                         |
| -------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| 取决于参数类型 | java_method(class, method[, arg1[, arg2..]])         | 反射                                                         |
| 取决于参数类型 | reflect(class, method[, arg1[, arg2..]])             | 利用反射，调用匹配其签名的Java方法                           |
| INT            | hash(a1 [, a2...])                                   | 返回参数的哈希值                                             |
| STRING         | current_user()                                       | 从配置的管理器中返回当前用户名                               |
| STRING         | logged_in_user()                                     | 从会话状态返回当前用户名                                     |
| STRING         | current_datebase()                                   | 返回当前数据库名字                                           |
| STRING         | md5(STRING \| BINARY)                                | 1、计算字符串或二进制的 MD5 128位校验和2、返回的结果是长度为32的16进制字符串 |
| STRING         | sha1(STRING \| BINARY)sha(STRING \| BINARY)          | 计算字符串或二进制的 SHA-1 并将值作为十六进制字符串返回      |
| BIGINT         | crc32(STRING \| BINARY)                              | 计算字符串或二进制参数的循环冗余校验值并返回 bigint 值       |
| STRING         | sha2(STRING \| BINARY, int)                          | 1、计算 SHA-2 系列哈希函数（SHA-224、SHA-256、SHA-384 和 SHA-512）2、第一个参数指定字符串3、第二个参数表示结果的所需位长，其值必须为 224、256、384、512 或 0（等价于256） |
| BINARY         | aes_encrypt(STRING/BINARY input,  STRING/BINARY key) | 1、使用 AES 加密输入2、如果任一参数为null或密钥长度不是允许的值之一，则返回值为null3、第一个参数指定输入4、第二个参数指定加密的长度，允许的长度为128、192或者256 |
| BINARY         | aes_decrypt(BINARY inputy, key STRING/BINARY key)    | 1、使用 AES 解密输入2、如果任一参数为null或密钥长度不是允许的值之一，则返回值为null3、第一个参数指定输入4、第二个参数指定加密的长度，允许的长度为128、192或者256 |
| STRING         | version()                                            | 1、返回Hive的版本2、第一个返回值是内部版本号3、第二个返回值是哈希值 |
| BIGINT         | surrogate_key([write_id_bits, task_id_bits])         | 1、当将数据输入表格时，自动为行生成数字ID2、只能用作ACID或插入表时的默认值 |



# 二、内置聚合函数（UDAF）

| 返回类型                | 函数签名                                                 | 含义                                                         |
| ----------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| BIGINT                  | count(*)count(expr)count(DISTINCT expr[, expr...])       | 1、count(*)：返回检索到的所有行数，包括NULL值2、count(expr)：返回所提供的表达式expr为非NULL的行数，如果为空集，返回03、count(DISTINCT expr[, expr...])：返回提供的表达式expr唯一并且非NULL的行数 |
| DOUBLE                  | sum(col)sum(DISTINCT col)                                | 1、sum(col)：返回组中元素的总和2、sum(DISTINCT col)：返回组中列的不同值的总和 |
| DOUBLE                  | avg(col)avg(DISTINCT col)                                | 1、avg(col)：返回组中元素的平均值2、avg(DISTINCT col)：返回组中列的不同值的平均值 |
| DOUBLE                  | min(col)                                                 | 1、返回组中列col的最小值                                     |
| DOUBLE                  | max(col)                                                 | 1、返回组中列col的最大值                                     |
| DOUBLE                  | variance(col)var_pop(col)                                | 1、返回组中数字列col的方差                                   |
| DOUBLE                  | var_samp(col)                                            | 1、返回组中数字列的无偏样本方差                              |
| DOUBLE                  | stddev_pop(col)                                          | 1、返回组中数字列col的标准差                                 |
| DOUBLE                  | stddev_samp(col)                                         | 1、返回组中数字列的无偏样本标准差                            |
| DOUBLE                  | covar_pop(col1, col2)                                    | 1、返回组中一对数值列(col1, col2)的总体协方差                |
| DOUBLE                  | covar_samp(col1, col2)                                   | 1、返回组中一对数字列(col1, col2)的样本协方差                |
| DOUBLE                  | corr(col1, col2)                                         | 1、返回组中一对数字列的 Pearson 相关系数（计算两个列的相关性） |
| DOUBLE                  | percentile(BIGINT col, p)                                | 1、返回组中列精确的第p个百分位数2、p必须介于0到1之间         |
| ARRAY<DOUBLE>           | percentile(BIGINT col, array(p1 [, p2]...))              | 1、返回组中列精确的第p1，p2……个百分位数2、pi必须介于0到1之间 |
| DOUBLE                  | percentile_approx(DOUBLE col, p [, B])                   | 1、返回组中列近似的第p个百分位数2、p必须介于0到1之间3、B参数以内存为代价控制近似精度，较高的值会产生更好的近似值，默认值为 10,000；当 col 中不同值的数量小于 B 时，这会给出精确的百分位值 |
| ARRAY<DOUBLE>           | percentile_approx(DOUBLE col, array(p1 [, p2]...) [, B]) | 1、返回组中列近似的第p1，p2……个百分位数2、pi必须介于0到1之间3、B参数以内存为代价控制近似精度，较高的值会产生更好的近似值，默认值为 10,000；当 col 中不同值的数量小于 B 时，这会给出精确的百分位值 |
| DOUBLE                  | regr_avgx(independent, dependent)                        | 1、线性回归函数，从所有非 NULL (Y, X) 值对返回 x 值的平均值,相当于 avg(dependent)（从Hive2.2.0开始） |
| DOUBLE                  | regr_avgy(independent, dependent)                        | 1、线性回归函数，从所有非 NULL (Y, X) 值对返回 y 值的平均值,相当于 avg(dependent)（从Hive2.2.0开始） |
| DOUBLE                  | regr_count(independent, dependent)                       | 1、线性回归函数，返回输入中非 NULL (Y, X) 值对的数量。仅当给定对中的 X 和 Y 都为非 NULL 时，才应在所有线性回归计算中使用此观测（从Hive2.2.0开始） |
| DOUBLE                  | regr_intercept(independent, dependent)                   | 1、线性回归函数，计算可最佳拟合非独立和独立变量的线性回归线的 y 截距（从Hive2.2.0开始） |
| DOUBLE                  | regr_r2(independent, dependent)                          | 1、线性回归函数，计算回归线的确定系数（也称为 R 平方或适配度统计）（从Hive2.2.0开始） |
| DOUBLE                  | regr_slope(independent, dependent)                       | 1、线性回归函数，计算拟合到非 NULL 数对的线性回归线的斜率（从Hive2.2.0开始） |
| DOUBLE                  | regr_sxx(independent, dependent)                         | 1、线性回归函数，返回 (Y, X) 对中 x 值的平方和（从Hive2.2.0开始） |
| DOUBLE                  | regr_sxy(independent, dependent)                         | 1、线性回归函数，返回 (Y, X) 对集中两项积和的差值（从Hive2.2.0开始） |
| DOUBLE                  | regr_syy(independent, dependent)                         | 1、线性回归函数，返回 (Y, X) 对中 y 值的平方和（从Hive2.2.0开始） |
| ARRAY<STRCUT{'x', 'y'}> | histogram_numeric(col, b)                                | 1、使用b个非均匀间隔的存储箱计算组中数值列的直方图2、输出是一个大小为b的双值（x，y）坐标数组，分别表示箱的中心和高度 |
| ARRAY                   | collect_set(col)                                         | 1、返回删除了重复元素的对象集                                |
| ARRAY                   | collect_list(col)                                        | 1、返回包含重复元素的对象列表                                |
| INTEGER                 | ntile(INTEGER x)                                         | 1、把有序的数据集合平均分配到指定的数量x个桶中, 将桶号分配给每一行2、如果不能平均分配，则优先分配较小编号的桶，并且各个桶中能放的行数最多相差13、可以方便地计算三位数、四位数、十位数、百分位数和其他常见的汇总统计数据。4、使用语法是：ntile (num) over ([partition_clause] order_by_clause) as your_bucket_num |



# 三、内置表生成函数（UDTF）

| 列的数据类型                        | 函数签名                                                | 含义                                                         |
| ----------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| T                                   | explode(ARRAY<T> a)                                     | 1、将数组分解为多行2、返回具有单列 (col) 的行集，数组中的每个元素对应一行 |
| Tkey, Tvalue                        | explode(MAP<Tkey, Tvalue> m)                            | 1、将Map分解为多行2、返回一个包含两列 (key, value) 的行集，输入映射中的每个键值对对应一行（0.8.0 开始） |
| int, T                              | posexplode(ARRAY<T> a)                                  | 1、使用 int 类型的附加位置列（原始数组中项目的位置，从0开始）将数组分解为多行2、返回一个包含两列 (pos, val) 的行集，数组中的每个元素占一行 |
| T1,...,Tn                           | inline(ARRAY<STRUCT<f1:T1,...,fn:Tn>> a)                | 1、将范型为STRUCT的数组分解为多行2、返回一个包含 N 列的行集（N = STRUCT中顶级元素的数量），数组中每个结构一行。 （Hive 0.10） |
| T1,...,Tn/r                         | stack(int r, T1V1,...,Tn/rVn)                           | 1、将 n 个值V1,...,Vn 分解为r行。每行将有n/r列2、r必须是常数 |
| string1,...,stringn                 | json_tuple(string jsonStr, string k1,...,string kn)     | 1、接受JSON字符串和一组n个键，并返回n个值的元组              |
| string1,...,stringn                 | parse_url_tuple(string urlStr, string p1,...,string pn) | 1、根据URL字符串和n个URL部分，并返回一个包含 n 个值的元组2、这类似于 parse_url() UDF，但可以一次从 URL 中提取多个部分3、有效的部分名称为：HOST、PATH、QUERY、REF、PROTOCOL、AUTHORITY、FILE、USERINFO、QUERY:<KEY> |
| 备注：1、输入一行数据，输出多行数据 |                                                         |                                                              |



# 四、开窗函数



# 附：

表附-1：Hive原始数据类型

| 数据类型               | **类型名称**             | **大小**             | **示例**                         |
| ---------------------- | ------------------------ | -------------------- | -------------------------------- |
| Integer                | TINYINT                  | 1字节整数            | 45Y                              |
| SMALLINT               | 2字节整数                | 12S                  |                                  |
| INT                    | 4字节整数                | 10                   |                                  |
| BIGINT                 | 8字节整数                | 244L                 |                                  |
| Floating Point numbers | FLOAT                    | 4字节单精度浮点数    | 1.0                              |
| DOUBLE                 | 8字节双精度浮点数        | 1.0                  |                                  |
| Fixed point numbers    | DECIMAL                  | 任意精度带符号小数   | DECIMAL(4, 2)范围：-99.99到99.99 |
| Boolean                | BOOLEAN                  | true/false           | TRUE                             |
| String                 | STRING                   | 字符串，长度不定     | “a”, ‘b’                         |
| VARCHAR                | 字符串，长度不定，有上限 | “a”, ‘b’             |                                  |
| CHAR                   | 字符串，固定长度         | “a”, ‘b’             |                                  |
| Binary                 | BINARY                   | 存储变长的二进制数据 |                                  |
| Date and time          | TIMESTAMP                | 时间戳，纳秒精度     | 122327493795                     |
| DATE                   | 日期                     | ‘2016-07-03’         |                                  |

表附-2：Hive复杂数据类型

| **类型名称** | **大小**                                          | **示例**                                               |
| ------------ | ------------------------------------------------- | ------------------------------------------------------ |
| ARRAY        | 存储同类型数据                                    | ARRAY< data_type>                                      |
| MAP          | key-value, key必须为原始类型，value可以是任意类型 | MAP< primitive_type, data_type>                        |
| STRUCT       | 类型可以不同                                      | STRUCT< col_name : data_type [COMMENT col_comment], …> |
| UNION        | 在有限取值范围内的一个值                          | UNIONTYPE< data_type, data_type, …>                    |

图附-1：Hive数据类型继承图

![Hive数据类型继承图](/Users/chenjing/Downloads/hive.png)

# 参考：

- https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF

- https://blog.csdn.net/huangyinzhao/article/details/80739256

- https://help.aliyun.com/document_detail/63448.html#section-dmb-272-8gm