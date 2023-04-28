# 一、Lambda表达式简介

## 1.1 对Lambda的理解

![Lambda表达式的组成](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/1-1.png)

图1-1：Lambda表达式的组成

可以把Lambda表达式理解为简洁的表示**可传递的匿名函数**的一种方式：它没有名称，但它有参数列表、函数主体、返回类型，可能还有一个可抛出的异常列表：

- 匿名：我们说匿名，是因为它不像普通的方法那样有一个明确的名称
- 函数：我们说它是函数，是因为Lambda函数不像方法那样属于某个特定的类。但和方法一样，Lambda有参数列表、函数主体、返回类型，还可能有可以抛出的异常列表
- 传递：Lambda表达式可以作为参数传递给方法或存储在变量中
- 简洁：无需像匿名类那样写很多模板代码

## 1.2 Lambda的语法

```java
Lambda有两种基本语法
(parameters) -> expression
或
(parameters) -> { statements; }
```

注意：如果lambda主体是一个语句，要使此lambda有效，需要使用花括号。

# 二、Lambda使用的位置

可以在**函数式接口**上使用lambda表达式。

## 2.1 函数式接口

函数式接口就是只定义了一个抽象方法的接口，例如下面展示的：

```java
public interface Predicate<T>{
		boolean test (T t);
}
```

注意：接口现在还可以拥有默认方法（即在类没有对方法进行实现时，其主体为方法提供默认实现的方法），哪怕有很多默认方法，只要接口只定义了一个抽象方法，它就仍然是一个函数式接口。

函数式接口的作用是：Lambda表达式允许你直接以内联的形式为函数式接口的抽象方法提供实现，并把整个表达式作为函数式接口的实例（具体来说，是函数式接口一个具体实现的实例）。

## 2.2 函数描述符

函数式接口的抽象方法的签名基本上就是Lambda表达式的签名，我们将这种抽象方法叫做函数描述符。例如，Runnable接口可以看作一个什么也不接受什么也不返回(void)的函数的签名，因为它只有一个叫作run的抽象方法，这个方法什么也不接受，什么也不返回(void)。

# 三、Java API提供的函数式接口

Java8的库设计师在java.util.function包中引入了几个新的函数式接口。

## 3.1 Predicate

java.util.function.Predicate<T>接口定义了一个叫test的抽象方法，它接受泛型T对象，并返回一个boolean。

```java
@FunctionalInterface
public interface Predicate<T>{
	boolean test(T t);
}
public static <T> List<T> filter(List<T> list, Predicate<T> p) {
  List<T> results = new ArrayList<>();
  for(T s: list){
    if(p.test(s)){
      results.add(s);
    } 
  }
  return results;
}

Predicate<String> nonEmptyStringPredicate = (String s) -> !s.isEmpty(); 
List<String> nonEmpty = filter(listOfStrings, nonEmptyStringPredicate);
```

## 3.2 Comsumer

java.util.function.Comsumer<T>定义了一个accept的抽象方法，它接受泛型T的对象，没有返回（void）。如果你需要访问类型T的对象，并对其执行某些操作，就可以使用这个接口。

```java
 @FunctionalInterface
public interface Consumer<T>{
  void accept(T t);
}
public static <T> void forEach(List<T> list, Consumer<T> c){
  for(T i: list){
    c.accept(i);
	} 
}

forEach(
	Arrays.asList(1,2,3,4,5),
	(Integer i) -> System.out.println(i)
);
```

## 3.3 Function

java.util.function.Function<T, R>接口定义了一个apply方法，它接受一个泛型T的对象，并返回一个泛型R的对象。如果你需要定义一个Lambda，将输入对象的信息映射到输出，就可以使用这个接口。

```java
@FunctionalInterface
public interface Function<T, R>{
  R apply(T t);
}
public static <T, R> List<R> map(List<T> list,
                                 Function<T, R> f) {
  List<R> result = new ArrayList<>();
  for(T s: list){
    result.add(f.apply(s));
  }
  return result;
}

// [7, 2, 6]
List<Integer> l = map(
  Arrays.asList("lambdas","in","action"),
  (String s) -> s.length()
);
```

## 3.4 原始类型特化

Java类型要么是引用类型（比如Byte、Integer、Object、List），要么是原始类型（比如int、double、byte、char）。但是泛型（比如Consumer<T>中的T）只能绑定到引用类型。这是由泛型内部的实现方式造成的。

因此，在Java里有一个将原始类型转换为对应的引用类型的机制。这个机制叫作装箱（boxing）。相反的操作，也就是将引用类型转换为对应的原始类型，叫作拆箱(unboxing)。Java还有一个自动装箱机制来帮助程序员执行这一任务：装箱和拆箱操作式自动完成的。

但这在性能方面是要付出代价的。装箱后的值本质上就是把原始类型包裹起来，并保存在堆里。因此，装箱后的值需要更多的内存，并需要额外的内存搜索来获取被包裹的原始值。

Java 8为我们前面所说的函数式接口带来了一个专门的版本，以便在输入和输出都是原始类型时避免自动装箱的操作。

一般来说，针对对专门的输入参数类型的函数式接口的名称都要加上对应的原始类型前缀，比如DoublePredicate、IntConsumer、LongBinaryOperator、IntFunction等。Function接口还有针对输出参数类型的变种:ToIntFunction<T>、IntToDoubleFunction等。

## 3.5 Java中的常用函数式接口

| 函数式接口          | 抽象方法                                                     | 函数描述符        | 原始类型特化                                                 |
| ------------------- | ------------------------------------------------------------ | ----------------- | ------------------------------------------------------------ |
| Predicate<T>        | boolean test(T t)                                            | T -> boolean      | IntPredicateLongPredicateDoublePredicate                     |
| Consumer<T>         | void accept(T t)                                             | T -> void         | IntConsumerLongConsumerDoubleConsumer                        |
| Function<T, R>      | R apply(T t)                                                 | T -> R            | IntFunction<R>IntToDoubleFunctionIntToLongFunctionLongFunction<R>LongToDoubleFunctionLongToIntFunctionDoubleFunction<R>ToIntFunction<T>ToDoubleFunction<T>ToLongFunction<T> |
| Supplier<T>         | T get()                                                      | () -> T           | BooleanSupplierIntSupplierLongSupplierDoubleSupplier         |
| UnaryOperator<T>    | static <T> UnaryOperator<T> identity() {     return t -> t; } | T -> T            | IntUnaryOperatorLongUnaryOperatorDoubleUnaryOperator         |
| BinaryOperator<T>   | public static <T> BinaryOperator<T> minBy(Comparator<? super T> comparator) {     Objects.requireNonNull(comparator);     return (a, b) -> comparator.compare(a, b) <= 0 ? a : b; }public static <T> BinaryOperator<T> maxBy(Comparator<? super T> comparator) {     Objects.requireNonNull(comparator);     return (a, b) -> comparator.compare(a, b) >= 0 ? a : b; } | (T, T) -> T       | IntBinaryOperatorLongBinaryOperatorDoubleBinaryOperator      |
| BiPredicate<L, U>   | boolean test(T t, U u)                                       | (L, R) -> boolean |                                                              |
| BiConsumer<T, U>    | void accept(T t, U u)                                        | (T, U) -> void    | ObjIntConsumer<T>ObjLongConsumer<T>ObjDoubleConsumer<T>      |
| BiFunction<T, U, R> | R apply(T t, U u)                                            | (T, U) -> R       | ToIntBiFunction<T, U>ToLongBiFunction<T, U>ToDoubleBiFunction<T, U> |

注意：任何函数式接口都不允许抛出受检异常，如果你需要Lambda表达式来抛出异常，有两种办法：（1）定义一个自己都函数式接口，并声明受检异常；（2）把Lambda包在一个try/catch块中。

# 四、类型检查、类型推荐以及限制

## 4.1 类型检查

![Lambda表达式的类型检查过程](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/4-1.png)

图4-1：Lambda表达式的类型检查过程

Lambda的类型是从使用Lambda的上下文推断出来的。这里的上下文指的是接受它传递的方法的参数，或接受它值的局部变量。上下文中Lambda表达式需要的类型称为**目标类型**。

Lambda可以从赋值的上下文、方法调用的上下文（参数和返回值）以及类型转换的上下文中获得目标类型。

**特殊的void兼容规则**

> 如果一个Lambda的主体是一个语句表达式，它就和一个void的函数描述符兼容（当然需要参数列表也兼容）。

## 4.2 类型推断

Java编译器会从上下文（目标类型）推断出用什么函数式接口来配合Lambda表达式，这意味着它也可以推断出适合Lambda的签名，因为函数描述符可以通过目标类型来得到。

![类型推断对比](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/4-2.png)

图4-2：类型推断对比

## 4.3 使用局部变量

Lambda表达式允许使用自有变量（不是参数，而是在外层作用域中定义的变量），就像匿名类一样，他们被称作捕获Lambda。例如：

```java
int portNumber = 1337;
Runnable r = () -> System.out.println(portNumber);
```

Lambda可以无限制地捕获实例变量和静态变量。但局部变量必须显式声明为final或者事实上的final。例如下面的代码无法编译：

![Lambda对局部变量的使用](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/4-3.png)

图4-3：Lambda对局部变量的使用

为什么对局部变量会有这些限制

> 实例变量和局部变量背后的实现有一个关键不同，实例变量都存储在堆中，而局部变量则保存在栈上。因此，Java在访问自由局部变量时，实际上是在访问它的副本，而不是访问原始变量。



## 4.4 方法引用

方法引用让你可以重复使用现有的方法定义，并像Lambda一样传递他们。

![方法引用方式比较](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/4-4.png)

图4-4：方法引用方式比较

如果一个Lambda代表的只是“直接调用这个方法”，那最好还是用名称来调用它，而不是去描述如何调用它。当你需要使用方法引用时，目标引用放在分隔符“::”前，方法的名称放在后面。

### 4.4.1 构建方法引用

| 类别                             | 例子                                                         | 备注                                                         |
| -------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 指向静态方法的方法引用           | Integer的parseInt方法，写做Integer::parseInt                 |                                                              |
| 指向任意类型实例方法的方法引用   | String的length方法，写做String::length                       | 这种方法引用的思想在于你在引用一个对象的方法，而这个对象本身是Lambda的一个参数 |
| 指向现有对象的实例方法的方法引用 | 假设你有一个局部变量expensiveTransaction用于存放Transaction类型的对象，支持实例方法getValue，写做expensiveTransaction::getValue | 这种方法引用指的是，你在Lambda中调用一个已经存在的外部对象中的方法 |

### 4.4.2 构造函数引用

对于一个现有构造函数，可以利用它的名称和关键字new来创建它的一个引用：ClassName::new。

如果你的构造函数的签名是Apple(Integer, weight)，那么它就适合Function接口的签名，于是你可以这样写：

![构造函数引用](https://cdn.jsdelivr.net/gh/cjing9017/Files@main/img/4-5.png)

图4-5：构造函数引用

对于语言本身并没有提供函数式接口的情况下，可以自己创建一个，例如我们需要具有三个参数的构造函数，Color(int, int, int)：

```java
public interface TriFunction<T, U, V, R> {
		R apply(T t, U u, V v);
}

TriFunction<Integer, Integer, Integer, Color> colorFactory = Color::new;
```

## 4.5 复合lambda表达式

### 4.5.1 比较器复合

```java
inventory.sort(comparing(Apple::getWeight).reversed());
inventory.sort(comparing(Apple::getWeight)
         .reversed()
         .thenComparing(Apple::getCountry));
```

### 4.5.2 谓词复合

谓词接口包括三个方法：negate、and和or。

and和or方法是按照在表达式链中的位置，从左向右确定优先级的。

### 4.5.3 函数复合

Function接口配置了andThen和compose两个默认方法。

```java
Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
// 数学上写做g(f(x))
Function<Integer, Integer> h = f.andThen(g);
int result = h.apply(1);

Function<Integer, Integer> f = x -> x + 1;
Function<Integer, Integer> g = x -> x * 2;
// 数学上写做f(g(x))
Function<Integer, Integer> h = f.compose(g);
int result = h.apply(1);
```