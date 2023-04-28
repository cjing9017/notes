# 一、简介

由阿里的电商业务规则、表达式（布尔组合）、特殊数学公式计算（高精度）、语法分析、脚本二次定制等强需求而设计的一门动态脚本引擎解析工具。

在阿里集团有很强的影响力，同时为了自身不断优化、发扬开源贡献精神，于2012年开源。

![QLExpress脚本引擎详细功能分解](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/image-20230427133446284.png)

# 二、依赖和使用

```xml
<dependency>
  <groupId>com.alibaba</groupId>
  <artifactId>QLExpress</artifactId>
  <version>3.3.1</version>
</dependency>
```

## 2.1 表达式脚本

### 2.1.1 普通的Java语法

- 支持 +,-,*,/,<,>,<=,>=,==,!=,<>【等同于!=】,%,mod【取模等同于%】,++,--
- 支持in【类似sql】,like【sql语法】,&&,||,!,等操作符
- 支持for，break、continue、if then else 等标准的程序控制逻辑
- 不支持try{}catch{}
- 弱类型语言，请不要定义类型声明,更不要用Template（Map<String, List>之类的）
- min,max,round,print,println,like,in 都是系统默认函数的关键字，请不要作为变量名

```java
//java语法：使用泛型来提醒开发者检查类型
keys = new ArrayList<String>();
deviceName2Value = new HashMap<String, String>(7);
String[] deviceNames = {"ng", "si", "umid", "ut", "mac", "imsi", "imei"};
int[] mins = {5, 30};

//ql写法：
keys = new ArrayList();
deviceName2Value = new HashMap();
deviceNames = ["ng", "si", "umid", "ut", "mac", "imsi", "imei"];
mins = [5, 30];

//java语法：对象类型声明
FocFulfillDecisionReqDTO reqDTO = param.getReqDTO();
//ql写法：
reqDTO = param.getReqDTO();

//java语法：数组遍历
for(Item item : list) {
}
//ql写法：
for(i = 0; i < list.size(); i++){
    item = list.get(i);
}

//java语法：map遍历
for(String key : map.keySet()) {
    System.out.println(map.get(key));
}
//ql写法：
keySet = map.keySet();
objArr = keySet.toArray();
for (i = 0; i < objArr.length; i++) {
    key = objArr[i];
    System.out.println(map.get(key));
}
public static void main(String[] args) throws Exception {
    ExpressRunner runner = new ExpressRunner();
    String express = "n = 10;sum = 0;for(i = 0; i < n; i++) {sum = sum + i;}return sum;";
    DefaultContext<String, Object> context = new DefaultContext<>();
    Object result = runner.execute(express, context, null, false, false);
    System.out.println(result);
}
```

### 2.1.2 脚本中定义函数

```java
// 自定义函数add、sub
// function add(int a, int b){
//     return a + b;
// };
//
// function sub(int a, int b){
//     return a - b;
// };
//
// a = 10;
// return add(a, 4) + sub(a, 9);

public static void main(String[] args) throws Exception {
    ExpressRunner runner = new ExpressRunner();
    String express = "function add(int a, int b){return a + b;};function sub(int a, int b){return a - b;};a = 10;return add(a, 4) + sub(a, 9);";
    DefaultContext<String, Object> context = new DefaultContext<>();
    Object result = runner.execute(express, context, null, false, false);
    System.out.println(result); // 15
}
```

```java
public static void main(String[] args) throws Exception {
    ExpressRunner expressRunner = new ExpressRunner();
    String add = "function add(int a, int b){return a + b;};";
    String sub = "function sub(int a, int b){return a - b;};";
    String exp = "sub(100,add(xx,yy));";
    String express = add + sub + exp;
    DefaultContext<String, Object> context = new DefaultContext<>();
    context.put("xx", 1);
    context.put("yy", 2);
    Object result = expressRunner.execute(express, context, null, false, false);
    System.out.println(result); // 97
}
```

## 2.2 自定义Operator

### 2.2.1 自定义函数

```java
public class Add extends Operator {
    @Override
    public Object executeInner(Object[] list) throws Exception {
        Object a = list[0];
        Object b = list[1];
        if (a instanceof Integer && b instanceof Integer) {
            return (Integer) a + (Integer) b;
        }

        return null;
    }
}
public static void main(String[] args) throws Exception {
    ExpressRunner runner = new ExpressRunner();
  	// 添加自定义函数对应，并设置对应的别名
    runner.addFunction("add", new Add());
  	// 表达式
    String express = "add(a,add(2,c))";
    DefaultContext<String, Object> context = new DefaultContext<>();
  	// 传入变量对应的值
    context.put("a", 1);
    context.put("c", 3);
    Object result = runner.execute(express, context, null, false, false);
    System.out.println(result); // 6
}
```

### 2.2.2 扩展Operator

```java
public static void main(String[] args) throws Exception {
    ExpressRunner runner = new ExpressRunner();
    runner.addOperatorWithAlias("如果", "if", null);
    runner.addOperatorWithAlias("则", "then", null);
    runner.addOperatorWithAlias("否则", "else", null);
    String express = "如果 (10 + 20 + 30 > 270) 则 {return 1;} 否则 {return 0;}";
    DefaultContext<String, Object> context = new DefaultContext<String, Object>();
    Object result = runner.execute(express, context, null, false, false);
    System.out.println(result); // 0
}
```

## 2.3 使用Java类或者对象的方法

```java
public class BeanExample {
    public static String upper(String abc) {
        return abc.toUpperCase();
    }
    public boolean anyContains(String str, String searchStr) {
        char[] s = str.toCharArray();
        for (char c : s) {
            if (searchStr.contains(c+"")) {
                return true;
            }
        }
        return false;
    }
}
public static void main(String[] args) throws Exception {
    ExpressRunner runner = new ExpressRunner();
    runner.addFunctionOfClassMethod("取绝对值", Math.class.getName(), "abs", new String[] {"double"}, null);
    runner.addFunctionOfClassMethod("转换为大写", BeanExample.class.getName(), "upper", new String[] {"String"}, null);
    runner.addFunctionOfServiceMethod("打印", System.out, "println", new String[] { "String" }, null);
    runner.addFunctionOfServiceMethod("contains", new BeanExample(), "anyContains", new Class[] {String.class, String.class}, null);
    String express = "取绝对值(-100); 转换为大写(\"hello world\"); 打印(\"你好吗？\"); contains(\"helloworld\",\"aeiou\")";
    DefaultContext<String, Object> context = new DefaultContext<String, Object>();
    Object result = runner.execute(express, context, null, false, false);
    System.out.println(result); // 你好吗? true
}
```

## 2.4 宏定义

## 2.5 语法解析校验

## 2.6 增强上下文参数Context相关的api

# 参考：

- https://github.com/alibaba/QLExpress
- https://www.cnblogs.com/duanxz/p/9307985.html