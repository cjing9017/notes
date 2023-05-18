# 一、JsonPath简介

1、JsonPath表达式通常是用来路径检索或设置Json的。其表达式可以接受 “dot–notation” 和 “bracket–notation” 格式，例如 \$.store.book[0].title、\$\[‘store’\]\[‘book’\]\[0\]\[‘title’\]

2、语法如下：

| Operator                | Description                                          |
| ----------------------- | ---------------------------------------------------- |
| $                       | 根节点对象                                           |
| @                       | 过滤器断言处理的当前节点对象，类似于Java中的this字段 |
| *                       | 通配符，可以表示一个名字或者数字                     |
| ..                      | 递归搜索                                             |
| .<name>                 | 表示一个子节点                                       |
| ['<name>' (, '<name>')] | 表示一个或者多个子节点                               |
| [<number> (, <number>)] | 表示一个或多个数组下标                               |
| [start:end]             | 数组片段，区间为[start,end)                          |
| [?(<expression>)]       | 过滤器表达式，表达式结果必须为boolean                |

3、Java对JsonPath的支持

- 参考：https://github.com/json-path/JsonPath

- 依赖

  ```xml
  <dependency>
      <groupId>com.jayway.jsonpath</groupId>
      <artifactId>json-path</artifactId>
      <version>2.8.0</version>
  </dependency>
  ```

- 使用demo

  ```java
  String json = "...";
  Object document = Configuration.defaultConfiguration().jsonProvider().parse(json);
  
  String author0 = JsonPath.read(document, "$.store.book[0].author");
  String author1 = JsonPath.read(document, "$.store.book[1].author");
  ```
