# Shell

# 一、Shell概述

- Shell是一个命令行解释器，他接收应用程序/用户命令，然后调用操作系统内核
- Shell还是一个功能相当强大的编程语言、易编写、易调试、灵活性强

# 二、Shell解析器

- Linux提供的Shell解析器有：

```bash
[hadoop@hadoop103 shell_test]$ cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
[hadoop@hadoop103 shell_test]$
```

- bash和sh的关系：

```bash
[hadoop@hadoop103 bin]$ ll | grep bash
-rwxr-xr-x. 1 root root 941880 5月  11 2016 bash
lrwxrwxrwx. 1 root root      4 12月 23 2019 sh -> bash
[hadoop@hadoop103 bin]$
```

- Centos默认的解析器是bash：

```bash
[hadoop@hadoop103 shell_test]$ echo $SHELL
/bin/bash
[hadoop@hadoop103 shell_test]$
```

# 三、Shell脚本入门

> 脚本格式：以#!/bin/bash开头（用于指定解析器）

- **示例1：创建一个Shell脚本，输出helloworld**

  ```bash
  [hadoop@hadoop103 shell_test]$ vim helloworld.sh
  [hadoop@hadoop103 shell_test]$ ll
  总用量 4
  -rw-rw-r--. 1 hadoop hadoop 31 7月  15 12:51 helloworld.sh
  [hadoop@hadoop103 shell_test]$ sh helloworld.sh 
  helloworld
  [hadoop@hadoop103 shell_test]$
  ```

- **示例2：在~目录下创建一个banzhang.txt文件，在文件中增加“I love cls”**

  ```bash
  [hadoop@hadoop103 shell_test]$ ll
  总用量 4
  -rwxrwxr-x. 1 hadoop hadoop 31 7月  15 12:51 helloworld.sh
  [hadoop@hadoop103 shell_test]$ vim batch.sh
  [hadoop@hadoop103 shell_test]$ sh batch.sh 
  [hadoop@hadoop103 shell_test]$ ll
  总用量 8
  -rw-rw-r--. 1 hadoop hadoop 71 7月  15 12:57 batch.sh
  -rwxrwxr-x. 1 hadoop hadoop 31 7月  15 12:51 helloworld.sh
  [hadoop@hadoop103 shell_test]$ cat ~/banzhang.txt 
  i love cls
  [hadoop@hadoop103 shell_test]$
  ```

- **脚本执行方式**

  - 采用bash或sh+脚本的相对路径或绝对路径（不用赋予脚本+x权限）

    ```bash
    [hadoop@hadoop103 shell_test]$ sh helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$ sh /home/hadoop/shell_test/helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$ bash helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$ bash /home/hadoop/shell_test/helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$
    ```

  - 采用输入脚本的绝对路径或相对路径执行脚本（必须具有可执行权限+x）

    ```bash
    [hadoop@hadoop103 shell_test]$ chmod +x helloworld.sh 
    [hadoop@hadoop103 shell_test]$ ./helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$ /home/hadoop/shell_test/helloworld.sh 
    helloworld
    [hadoop@hadoop103 shell_test]$
    ```

  - 第一种执行方法，本质是bash解析器帮你执行脚本，所以脚本本身不需要执行权限；第二种执行方法，本质是脚本需要自己执行，所以需要执行权限

# 四、Shell中的变量

## 4.1 系统变量

- **常用系统变量**

  - $HOME
  - $PWD
  - $SHELL
  - $USER

- **示例1：查看系统变量的值**

  ```bash
  [hadoop@hadoop103 shell_test]$ echo $HOME
  /home/hadoop
  [hadoop@hadoop103 shell_test]$ echo $PWD
  /home/hadoop/shell_test
  [hadoop@hadoop103 shell_test]$ echo $SHELL
  /bin/bash
  [hadoop@hadoop103 shell_test]$ echo $USER
  hadoop
  [hadoop@hadoop103 shell_test]$
  ```

- **示例2：显示当前Shell中所有变量**

  ```bash
  [hadoop@hadoop103 shell_test]$ set
  BASH=/bin/bash
  BASHOPTS=checkwinsize:cmdhist:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:login_shell:progcomp:promptvars:sourcepath
  BASH_ALIASES=()
  BASH_ARGC=()
  BASH_ARGV=()
  BASH_CMDS=()
  BASH_LINENO=()
  BASH_SOURCE=()
  BASH_VERSINFO=([0]="4" [1]="1" [2]="2" [3]="1" [4]="release" [5]="x86_64-redhat-linux-gnu")
  BASH_VERSION='4.1.2(1)-release'
  COLORS=/etc/DIR_COLORS
  COLUMNS=95
  CVS_RSH=ssh
  DIRSTACK=()
  …………
  ```

## 4.2 自定义变量

- **基本语法**

  - **定义变量**：变量=值
  - **撤销变量**：unset 变量
  - **声明静态变量**：readonly 变量，注意，不能unset

- **变量定义规则**

  - 变量名称可以由字母、数字和下划线组成，但是不能以数字开头，环境变量名建议大写
  - 等号两侧不能有空格
  - 在bash中，变量默认类型都是字符串类型，无法直接进行数值运算
  - 变量的值如果有空格，需要使用双引号或单引号括起来

- **示例1：定义变量A**

  ```bash
  [hadoop@hadoop103 shell_test]$ A=5
  [hadoop@hadoop103 shell_test]$ echo $A
  5
  [hadoop@hadoop103 shell_test]$
  ```

- **示例2：给变量A重新赋值**

  ```bash
  [hadoop@hadoop103 shell_test]$ echo $A
  5
  [hadoop@hadoop103 shell_test]$ A=8
  [hadoop@hadoop103 shell_test]$ echo $A
  8
  [hadoop@hadoop103 shell_test]$
  ```

- **示例3：撤销变量A**

  ```bash
  [hadoop@hadoop103 shell_test]$ echo $A
  8
  [hadoop@hadoop103 shell_test]$ unset A
  [hadoop@hadoop103 shell_test]$ echo $A
  
  [hadoop@hadoop103 shell_test]$
  ```

- **示例4：声明静态的变量B=2，不能unset**

  ```bash
  [hadoop@hadoop103 shell_test]$ readonly B=2
  [hadoop@hadoop103 shell_test]$ echo $B
  2
  [hadoop@hadoop103 shell_test]$ B=9
  -bash: B: readonly variable
  [hadoop@hadoop103 shell_test]$
  ```

- **示例5：在bash中，变量默认类型都是字符串类型，无法直接进行数值计算**

  ```bash
  [hadoop@hadoop103 shell_test]$ C=1+2
  [hadoop@hadoop103 shell_test]$ echo $C
  1+2
  [hadoop@hadoop103 shell_test]$
  ```

- **示例6：变量的值如果有空格，需要使用双引号或单引号括起来**

  ```bash
  [hadoop@hadoop103 shell_test]$ D=I love banzhang
  -bash: love: command not found
  [hadoop@hadoop103 shell_test]$ D="I love banzhang"
  [hadoop@hadoop103 shell_test]$ echo $D
  I love banzhang
  [hadoop@hadoop103 shell_test]$
  ```

- **实例7：可把变量提升为全局环境变量，可供其他Shell程序使用**

  ```bash
  [hadoop@hadoop103 shell_test]$ echo $B
  2
  [hadoop@hadoop103 shell_test]$ vim helloworld.sh 
  [hadoop@hadoop103 shell_test]$ ./helloworld.sh 
  helloworld
  
  [hadoop@hadoop103 shell_test]$ export B
  [hadoop@hadoop103 shell_test]$ ./helloworld.sh 
  helloworld
  2
  [hadoop@hadoop103 shell_test]$
  ```

## 4.3 特殊变量

- **$n**

  - 基本语法：n为数字，$0代表该脚本名称，$1-$9代表第一到第九个参数，十以上的参数需要用大括号包含，如${10}
  - 示例：输入该脚本文件名称、输入参数1和输入参数2的值

  ```bash
  [hadoop@hadoop103 shell_test]$ touch parameter.sh
  [hadoop@hadoop103 shell_test]$ vim parameter.sh 
  [hadoop@hadoop103 shell_test]$ sh parameter.sh 
  parameter.sh  
  [hadoop@hadoop103 shell_test]$ sh cls xz
  sh: cls: 没有那个文件或目录
  [hadoop@hadoop103 shell_test]$ sh parameter.sh cls xz
  parameter.sh cls xz
  [hadoop@hadoop103 shell_test]$ chmod +x parameter.sh 
  [hadoop@hadoop103 shell_test]$ ./parameter.sh cls xz
  ./parameter.sh cls xz
  [hadoop@hadoop103 shell_test]$ /home/hadoop/shell_test/parameter.sh cls xz
  /home/hadoop/shell_test/parameter.sh cls xz
  [hadoop@hadoop103 shell_test]$
  ```

- **$#**

  - 基本语法：获取所有输入参数个数，常用于循环
  - 示例：获取输入参数的个数

  ```bash
  [hadoop@hadoop103 shell_test]$ vim parameter.sh 
  [hadoop@hadoop103 shell_test]$ ./parameter.sh cls xz
  ./parameter.sh cls xz
  2
  [hadoop@hadoop103 shell_test]$
  ```

- **$\*、$@**

  - 基本语法
    - $*：这个变量代表命令行中所有的参数，$*把所有的参数看成一个整体
    - $@：这个变量也代表命令行中所有的参数，不过$@把每个参数区分对待
  - 示例：

  ```bash
  [hadoop@hadoop103 shell_test]$ ./parameter.sh 1 2 3
  ./parameter.sh 1 2
  3
  1 2 3
  1 2 3
  [hadoop@hadoop103 shell_test]$
  ```

  - 比较$*和$@的区别

    - $*和$@都表示传递给函数或脚本的所有参数，不被双引号“”包含时，都以$1 $2 …$n的形式输出所有参数

      ```bash
      [hadoop@hadoop103 shell_test]$ vim for.sh
      [hadoop@hadoop103 shell_test]$ bash for.sh cls xz bd
      ban zhang love cls
      ban zhang love xz
      ban zhang love bd
      ban zhang love cls
      ban zhang love xz
      ban zhang love bd
      [hadoop@hadoop103 shell_test]$ cat for.sh 
      #!bin/bash
      
      for i in $*
      do
      	echo "ban zhang love $i"
      done
      
      for j in $@
      do
      	echo "ban zhang love $j"
      done
      
      [hadoop@hadoop103 shell_test]$
      ```

    - 当它们被双引号“”包含时，“$*”会将所有的参数作为一个整体，以“$1 $2 …$n”的形式输出所有参数；“$@”会将各个参数分开，以“$1” “$2”…”$n”的形式输出所有参数

      ```bash
      [hadoop@hadoop103 shell_test]$ vim for.sh 
      [hadoop@hadoop103 shell_test]$ bash for.sh cls xz bd
      ban zhang love cls xz bd
      ban zhang love cls
      ban zhang love xz
      ban zhang love bd
      [hadoop@hadoop103 shell_test]$ cat for.sh 
      #!bin/bash
      
      for i in "$*"
      do
      	echo "ban zhang love $i"
      done
      
      for j in "$@"
      do
      	echo "ban zhang love $j"
      done
      
      [hadoop@hadoop103 shell_test]$
      ```

- **$?**

  - 基本语法：最后一次执行的命令的返回状态。如果这个变量的值为0，证明上一个命令正确执行；如果这个变量的值为非0（具体是哪个数，由命令自己来决定），则证明上一个命令执行不正确了
  - 示例：

  ```bash
  [hadoop@hadoop103 shell_test]$ ./helloworld.sh 
  helloworld
  2
  [hadoop@hadoop103 shell_test]$ echo $?
  0
  [hadoop@hadoop103 shell_test]$
  ```

# 五、运算符

- **基本语法**

  - “$((运算式))”或“$[运算式]”
  - expr  + , - , \*, /, %  加，减，乘，除，取余（注意：expr运算符间要有空格）

- **示例1：计算3+2的值**

  ```bash
  [hadoop@hadoop103 shell_test]$ expr 2 + 3
  5
  [hadoop@hadoop103 shell_test]$
  ```

- **示例2：计算3-2的值**

  ```bash
  [hadoop@hadoop103 shell_test]$ expr 3 - 2
  1
  [hadoop@hadoop103 shell_test]$
  ```

- **示例3：计算(2+3)x4的值：expr一步完成计算**

  ```bash
  [hadoop@hadoop103 shell_test]$ expr `expr 2 + 3` \\* 4
  20
  [hadoop@hadoop103 shell_test]$
  ```

- **示例4：计算(2+3)x4的值：采用$[运算符]方式**

  ```bash
  [hadoop@hadoop103 shell_test]$ S=$[(2+3)*4]
  [hadoop@hadoop103 shell_test]$ echo $S
  20
  [hadoop@hadoop103 shell_test]$
  ```

# 六、条件判断

- **基本语法**

  - [ condition ]（注意condition前后要有空格）
  - 注意：条件非空即为true，[ atguigu ]返回true，[] 返回false

- **常用判断条件**

  - 两个整数之间比较 = 字符串的比较
    - -lt（less than）：小于
    - -le（less equal）：小于等于
    - -eq（equal）：等于
    - -gt（greater than）：大于
    - -ge（greater equal）：大于等于
    - -ne（not equal）：不等于
  - 按照文件权限进行判断
    - -r：读的权限
    - -w：写的权限
    - -x：执行的权限
  - 按照文件类型进行判断
    - -f：文件存在并且是一个常规文件（file）
    - -e：文件存在
    - -d：文件存在并且是一个目录

- **示例1：23是否大于等于22**

  ```bash
  [hadoop@hadoop103 shell_test]$ [ 23 -ge 22 ]
  [hadoop@hadoop103 shell_test]$ echo $?
  0
  [hadoop@hadoop103 shell_test]$
  ```

- **示例2：helloworld.sh是否具有写权限**

  ```bash
  [hadoop@hadoop103 shell_test]$ [ -w helloworld.sh ]
  [hadoop@hadoop103 shell_test]$ echo $?
  0
  [hadoop@hadoop103 shell_test]$
  ```

- **示例3：/home/hadoop/cls.txt目录中的文件是否存在（0存在，1不存在）**

  ```bash
  [hadoop@hadoop103 shell_test]$ [ -e /home/hadoop/cls.txt ]
  [hadoop@hadoop103 shell_test]$ echo $?
  1
  [hadoop@hadoop103 shell_test]$
  ```

- **示例4：多条件判断（&& 表示前一条命令执行成功时，才执行后一条命令，|| 表示上一条命令执行失败后，才执行下一条命令）**

  ```bash
  [hadoop@hadoop103 shell_test]$ [ condition ] && echo OK || echo notok
  OK
  [hadoop@hadoop103 shell_test]$ [ condition ] && [ ] || echo notok
  notok
  [hadoop@hadoop103 shell_test]$
  ```

# 七、流程控制（重点）

## 7.1 if判断

- **基本语法**

  ```bash
  if [ 条件判断式 ];then 
    程序 
  fi 
  或者 
  if [ 条件判断式 ] 
    then 
      程序 
  elif [ 条件判断式 ]
  	then
  		程序
  else
  	程序
  fi
  
  注意事项：
  （1）[ 条件判断式 ]，中括号和条件判断式之间必须有空格
  （2）if后要有空格
  ```

- **示例1：输入一个数字，如果是1，则输出banzhang zhen shuai；如果是2，则输出cls zhen mei；如果是其他，什么也不输出**

  ```bash
  [hadoop@hadoop103 shell_test]$ vim if.sh
  [hadoop@hadoop103 shell_test]$ chmod 777 if.sh 
  [hadoop@hadoop103 shell_test]$ ./if.sh 1
  banzhang zhen shuai
  [hadoop@hadoop103 shell_test]$ ./if.sh 2
  cls zhen mei
  [hadoop@hadoop103 shell_test]$ ./if.sh 3
  [hadoop@hadoop103 shell_test]$ cat if.sh 
  #!/bin/bash
  
  if [ $1 -eq "1" ]
  then
  	echo "banzhang zhen shuai"
  elif [ $1 -eq "2" ]
  then
  	echo "cls zhen mei"
  fi
  [hadoop@hadoop103 shell_test]$
  ```

## 7.2 case语句

- **基本语法**

  ```bash
  case $变量名 in 
    "值1"） 
      如果变量的值等于值1，则执行程序1 
      ;; 
    "值2"） 
      如果变量的值等于值2，则执行程序2 
      ;; 
    …省略其他分支… 
    *） 
      如果变量的值都不是以上的值，则执行此程序 
      ;; 
  esac
  注意事项：
  1)	case行尾必须为单词“in”，每一个模式匹配必须以右括号“）”结束
  2)	双分号“;;”表示命令序列结束，相当于java中的break
  3)	最后的“*）”表示默认模式，相当于java中的default
  ```

- **示例1：输入一个数字，如果是1，则输出banzhang；如果是2，则输出cls；如果是其他，则输出renyao**

  ```bash
  [hadoop@hadoop103 shell_test]$ ./case.sh 1
  banzhang
  [hadoop@hadoop103 shell_test]$ ./case.sh 2
  cls
  [hadoop@hadoop103 shell_test]$ ./case.sh 3
  renyao
  [hadoop@hadoop103 shell_test]$ ./case.sh 4
  [hadoop@hadoop103 shell_test]$ cat case.sh 
  #!/bin/bash
  
  case $1 in
  "1")
  	echo "banzhang"
  ;;
  
  "2")
  	echo "cls"
  ;;
  
  "3")
  	echo "renyao"
  ;;
  esac
  
  [hadoop@hadoop103 shell_test]$
  ```

## 7.3 for循环

- **基本语法1**

  ```bash
  for (( 初始值;循环控制条件;变量变化 )) 
    do 
      程序 
    done
  ```

- **示例1：从1加到100**

  ```bash
  [hadoop@hadoop103 shell_test]$ vim for1.sh
  [hadoop@hadoop103 shell_test]$ chmod +x for1.sh 
  [hadoop@hadoop103 shell_test]$ ./for1.sh 
  5050
  [hadoop@hadoop103 shell_test]$ cat for1.sh 
  #!/bin/bash
  
  s=0
  for((i=0;i<=100;i++))
  do
  	s=$[$s+$i]
  done
  echo $s
  
  [hadoop@hadoop103 shell_test]$
  ```

- **基本语法2**

  ```bash
  for 变量 in 值1 值2 值3… 
    do 
      程序 
    done
  ```

- **示例2：打印所有输入参数**

  ```bash
  [hadoop@hadoop103 shell_test]$ vim for2.sh
  [hadoop@hadoop103 shell_test]$ chmod +x for2.sh 
  [hadoop@hadoop103 shell_test]$ ./for2.sh cls xz bd
  ban zhang love cls
  ban zhang love xz
  ban zhang love bd
  [hadoop@hadoop103 shell_test]$ cat for2.sh 
  #!/bin/bash
  
  for i in $*
  do
  	echo "ban zhang love $i"
  done
  [hadoop@hadoop103 shell_test]$
  ```

## 7.4 while循环

- **基本语法**

  ```bash
  while [ 条件判断式 ] 
    do 
      程序
    done
  ```

- **示例1：从1加到100**

  ```bash
  [hadoop@hadoop103 shell_test]$ vim while.sh
  [hadoop@hadoop103 shell_test]$ chmod +x while.sh 
  [hadoop@hadoop103 shell_test]$ ./while.sh 
  5050
  [hadoop@hadoop103 shell_test]$ cat while.sh 
  #!/bin/bash
  
  s=0
  i=1
  while [ $i -le 100 ]
  do
  	s=$[$s+$i]
  	i=$[$i+1]
  done
  echo $s
  [hadoop@hadoop103 shell_test]$
  ```

# 八、read读取控制台输入

- **基本语法**

  ```bash
  read(选项)(参数)
  	选项：
  -p：指定读取值时的提示符；
  -t：指定读取值时等待的时间（秒）
  参数
  	变量：指定读取值的变量名
  ```

- **示例1：提示7秒内，读取控制台输入的名称**

  ```bash
  [hadoop@hadoop102 command_test]$ vim read.sh
  [hadoop@hadoop102 command_test]$ chmod +x read.sh 
  [hadoop@hadoop102 command_test]$ ./read.sh 
  Enter your name in 7 seconds chenjing
  chenjing
  [hadoop@hadoop102 command_test]$ cat read.sh 
  #!/bin/bash
  
  read -t 7 -p "Enter your name in 7 seconds " NAME
  echo $NAME
  [hadoop@hadoop102 command_test]$
  ```

# 九、函数

## 9.1 系统函数

- **basename基本语法**

  - basename [string / pathname] [suffix] （功能描述：basename命令会删掉所有的前缀包括最后一个（‘/’）字符，然后将字符串显示出来
  - 选项：
    - suffix为后缀，如果suffix被指定了，basename会将pathname或string中的suffix去掉

- **示例1：截取该/home/hadoop/banzhang.txt路径的文件名称**

  ```bash
  [hadoop@hadoop102 command_test]$ basename /home/hadoop/banzhang.txt
  banzhang.txt
  [hadoop@hadoop102 command_test]$ basename /home/hadoop/banzhang.txt .txt
  banzhang
  [hadoop@hadoop102 command_test]$
  ```

- **dirname基本语法**

  - dirname 文件绝对路径（功能描述：从给定的包含绝对路径的文件名中去除文件名（非目录的部分），然后返回剩下的路径（目录的部分））

- **示例2：获取banzhang.txt文件的路径**

  ```bash
  [hadoop@hadoop102 command_test]$ dirname /home/hadoop/banzhang.txt
  /home/hadoop
  [hadoop@hadoop102 command_test]$
  ```

## 9.2 自定义函数

- **基本语法**

  ```bash
  [ function ] funname[()]
  {
  	Action;
  	[return int;]
  }
  funname
  ```

- **经验技巧**

  - 必须在调用函数地方之前，先声明函数，shell脚本是逐行运行。不会像其它语言一样先编译。
  - 函数返回值，只能通过$?系统变量获得，可以显示加：return返回，如果不加，将以最后一条命令运行结果，作为返回值。return后跟数值n(0-255)

- **示例1：计算两个输入参数的和**

  ```bash
  [hadoop@hadoop102 command_test]$ vim fun.sh
  [hadoop@hadoop102 command_test]$ chmod +x fun.sh 
  [hadoop@hadoop102 command_test]$ ./fun.sh 
  Please input the number1: 1
  Please input the number2: 2
  3
  [hadoop@hadoop102 command_test]$ cat fun.sh 
  #!/bin/bash
  
  function sum()
  {
  	s=0
  	s=$[ $1 + $2 ]
  	echo $s
  }
  
  read -p "Please input the number1: " n1
  read -p "Please input the number2: " n2
  sum $n1 $n2
  [hadoop@hadoop102 command_test]$
  ```

# 十、Shell工具（重点）

## 10.1 cut

- **作用**

  - cut的工作就是“剪”，具体的说就是在文件中负责剪切数据用的
  - cut命令从文件的每一行剪切字节、字符和字段并将这些字节、字符和字段输出

- **基本用法**

  - cut [选项参数] filename
  - 说明：默认分隔符是制表符

- **选项参数说明**

  [选项参数说明](https://www.notion.so/f7168fe35ff84f38b323f5bf2971a861)

- **示例1：切割cut.txt第一列**

  ```shell
  [hadoop@hadoop102 command_test]$ cat cut.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  le  le
  
  [hadoop@hadoop102 command_test]$ cut -d " " -f 1 cut.txt 
  dong
  guan
  wo
  lai
  le
  
  [hadoop@hadoop102 command_test]$
  ```

- **示例2：切割cut.txt第二、三列**

  ```shell
  [hadoop@hadoop102 command_test]$ cat cut.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  le  le
  
  [hadoop@hadoop102 command_test]$ cut -d " " -f 2,3 cut.txt 
  shen
  zhen
   wo
   lai
   le
  
  [hadoop@hadoop102 command_test]$
  ```

- **示例3：在cut.txt文件中切割出guan**

  ```shell
  [hadoop@hadoop102 command_test]$ cat cut.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  le  le
  
  [hadoop@hadoop102 command_test]$ cat cut.txt | grep "guan" | cut -d " " -f 1
  guan
  [hadoop@hadoop102 command_test]$
  ```

- **示例4：选取系统PATH变量值，第2个“：”开始后的所有路径**

  ```shell
  [hadoop@hadoop102 command_test]$ echo $PATH
  /usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/module/jdk1.8.0_144/bin:/opt/module/hadoop-2.7.2/bin:/opt/module/hadoop-2.7.2/sbin:/opt/module/kafka/bin:/opt/module/hbase-1.3.1/bin:/opt/module/hive/bin:/opt/module/neo4j/bin:/home/hadoop/bin
  [hadoop@hadoop102 command_test]$ echo $PATH | cut -d: -f 2-
  /usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/module/jdk1.8.0_144/bin:/opt/module/hadoop-2.7.2/bin:/opt/module/hadoop-2.7.2/sbin:/opt/module/kafka/bin:/opt/module/hbase-1.3.1/bin:/opt/module/hive/bin:/opt/module/neo4j/bin:/home/hadoop/bin
  [hadoop@hadoop102 command_test]$
  ```

- **示例5：切割ifconfig后打印的IP地址**

  ```shell
  [hadoop@hadoop102 command_test]$ ifconfig eth0
  eth0      Link encap:Ethernet  HWaddr 00:0C:29:BE:3F:2A  
            inet addr:192.168.150.102  Bcast:192.168.150.255  Mask:255.255.255.0
            inet6 addr: fe80::20c:29ff:febe:3f2a/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:4483 errors:0 dropped:0 overruns:0 frame:0
            TX packets:1822 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:339439 (331.4 KiB)  TX bytes:195587 (191.0 KiB)
  
  [hadoop@hadoop102 command_test]$ ifconfig eth0 | grep "inet addr" | cut -d ":" -f 2
  192.168.150.102  Bcast
  [hadoop@hadoop102 command_test]$ ifconfig eth0 | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1
  192.168.150.102
  [hadoop@hadoop102 command_test]$
  ```

## 10.2 sed

- **作用**

  - sed是一种流编辑器，它一次处理一行内容
  - 处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”，接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕
  - 接着处理下一行，这样不断重复，直到文件末尾
  - 文件内容并没有改变，除非你使用重定向存储输出

- **基本用法**

  - sed [选项参数] ‘command’ filename

- **选项参数说明**

  [选项参数说明](https://www.notion.so/4e8d788721134c8e9112a4f269719cf9)

- **命令功能描述**

  [command](https://www.notion.so/beddf3b92b304d42845062a26c154cec)

- **示例1：将“mei nv”这个单词插入到sed.txt第二行下，打印**

  ```shell
  [hadoop@hadoop102 command_test]$ cat sed.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$ sed '2a mei nv' sed.txt 
  dong shen
  guan zhen
  mei nv
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$
  ```

- **示例2：删除sed.txt文件所有包含wo的行**

  ```shell
  [hadoop@hadoop102 command_test]$ cat sed.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$ sed '/wo/d' sed.txt 
  dong shen
  guan zhen
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$
  ```

- **示例3：将sed.txt文件中wo替换为ni**

  ```shell
  [hadoop@hadoop102 command_test]$ cat sed.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$ sed 's/wo/ni/g' sed.txt 
  dong shen
  guan zhen
  ni  ni
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$
  ```

  - 注意：‘g’表示global，全部替换

- **示例4：将sed.txt文件中的第二行删除并将wo替换为ni**

  ```shell
  [hadoop@hadoop102 command_test]$ cat sed.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$ sed -e '2d' -e 's/wo/ni/g' sed.txt 
  dong shen
  ni  ni
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$
  ```

## 10.3 awk

- **作用**

  - 一个强大的文本分析工具，把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行分析处理

- **基本用法**

  - awk [选项参数] ‘pattern1{action1} pattern2{action2}...’ filename
  - pattern：表示AWK在数据中查找的内容，就是匹配模式
  - action：在找到匹配内容时所执行的一系列命令

- **选项参数说明**

  [选项参数](https://www.notion.so/6d28a863c68b45c89302f6c4b51f9ba7)

- **示例1：搜索passwd文件以root关键字开头的所有行，并输出该行的第7列**

  ```shell
  [hadoop@hadoop102 command_test]$ awk -F: '/^root/{print $7}' passwd 
  /bin/bash
  [hadoop@hadoop102 command_test]$
  ```

- **示例2：搜索passwd文件以root关键字开头的所有行，并输出该行的第1列和第7列，中间以“，”号分割**

  ```shell
  [hadoop@hadoop102 command_test]$ awk -F: '/^root/{print $1","$7}' passwd 
  root,/bin/bash
  [hadoop@hadoop102 command_test]$
  ```

- **示例3：只显示/etc/passwd的第一列和第七列，以逗号分割，且在所有行前面添加列名user，shell在最后一行添加"dahaige，/bin/zuishuai"**

  ```shell
  [hadoop@hadoop102 command_test]$ awk -F: 'BEGIN{print "user, shell"}{print $1","$7} END{print "dahaige, /bin/zuishuai"}' passwd 
  user, shell
  root,/bin/bash
  bin,/sbin/nologin
  daemon,/sbin/nologin
  adm,/sbin/nologin
  lp,/sbin/nologin
  …………
  tcpdump,/sbin/nologin
  hadoop,/bin/bash
  mysql,/bin/bash
  ganglia,/sbin/nologin
  dahaige, /bin/zuishuai
  [hadoop@hadoop102 command_test]$
  ```

  - 注意：BEGIN 在所有数据读取行之前执行；END 在所有数据执行之后执行

- **示例4：将passwd文件中的用户id增加数值1并输出**

  ```shell
  [hadoop@hadoop102 command_test]$ awk -v i=1 -F: '{print $3+i}' passwd 
  1
  2
  3
  4
  ………
  497
  496
  [hadoop@hadoop102 command_test]$
  ```

- **awk的内置变量**

  [awk的内置变量](https://www.notion.so/865368b9c17c43a29212fa2c7b987ac1)

- **示例1：统计passwd文件名，每行的行号，每行的列数**

  ```shell
  [hadoop@hadoop102 command_test]$ awk -F: '{print "filename:"  FILENAME ", linenumber:" NR  ",columns:" NF}' passwd 
  filename:passwd, linenumber:1,columns:7
  filename:passwd, linenumber:2,columns:7
  filename:passwd, linenumber:3,columns:7
  filename:passwd, linenumber:4,columns:7
  filename:passwd, linenumber:5,columns:7
  filename:passwd, linenumber:6,columns:7
  …………
  filename:passwd, linenumber:26,columns:7
  filename:passwd, linenumber:27,columns:7
  filename:passwd, linenumber:28,columns:7
  filename:passwd, linenumber:29,columns:7
  filename:passwd, linenumber:30,columns:7
  filename:passwd, linenumber:31,columns:7
  filename:passwd, linenumber:32,columns:7
  filename:passwd, linenumber:33,columns:7
  [hadoop@hadoop102 command_test]$
  ```

- **示例2：切割IP**

  ```shell
  [hadoop@hadoop102 command_test]$ ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}'
  192.168.150.102  Bcast
  [hadoop@hadoop102 command_test]$ ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk -F " " '{print $1}'
  192.168.150.102
  [hadoop@hadoop102 command_test]$
  ```

- **示例3：查询sed.txt中空行所在的行号**

  ```shell
  [hadoop@hadoop102 command_test]$ awk '/^$/{print NR}' sed.txt 
  5
  7
  [hadoop@hadoop102 command_test]$ cat sed.txt 
  dong shen
  guan zhen
  wo  wo
  lai  lai
  
  le  le
  
  [hadoop@hadoop102 command_test]$
  ```

## 10.4 sort

- **作用**

  - sort命令是在Linux里非常有用，它将文件进行排序，并将排序结果标准输出

- **基本用法**

  - sort(选项)(参数)

- **选项参数说明**

  [选项参数](https://www.notion.so/72d1300538a94f23b51e1f86c868cec5)

- **示例1：按照“：”分割后的第三列倒序排序**

  ```shell
  [hadoop@hadoop102 command_test]$ vim sort.sh
  [hadoop@hadoop102 command_test]$ cat sort.sh 
  bb:40:5.4
  bd:20:4.2
  xz:50:2.3
  cls:10:3.5
  ss:30:1.6
  
  [hadoop@hadoop102 command_test]$ sort -t: -nrk 3 sort.sh 
  bb:40:5.4
  bd:20:4.2
  cls:10:3.5
  xz:50:2.3
  ss:30:1.6
  
  [hadoop@hadoop102 command_test]$
  ```