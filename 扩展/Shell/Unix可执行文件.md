# Unix系统中执行可执行文件

在Linux中，我们执行内置命令时，直接输入命令名称即可，如：

```shell
$ mv a b #将a重命名为b
```

而在执行自己写好的程序时，却要带上./，例如：

```shell
$ hello
hello: command not found
$ ./hello
hello world
```

这是为什么呢？它们有什么区别呢？

# shell是如何运行程序的

在说明清楚问题之前，我们必须了解shell是如何运行程序的。首先我们必须要清楚的是，执行一条Linux命令，本质是在运行一个程序，如执行ls命令，它执行的是ls程序。那么在shell中输入一条命令，到底发生了什么？它会经历哪几个查找过程？

# alias中查找

alias命令可用来设置命令别名，而单独输入alias可以查看到已设置的别名：

```vhdl
$ alias
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
```

如果这里没有找到你执行的命令，那么就会接下去查找。如果找到了，那么就会执行下去。

# 内置命令中查找

不同的shell包含一些不同的内置命令，通常不需要shell到磁盘中去搜索。通过help命令可以看到有哪些内置命令：

```shell
$ help
```

通过type 命令可以查看命令类型：

```bash
$ type echo
echo is a shell builtin
```

如果是内置命令，则会直接执行，否则继续查找。

# PATH中查找

以ls为例，在shell输入ls时，首先它会从PATH环境变量中查找，PATH内容是什么呢，我们看看：

```javascript
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
```

所以它会在这些路径下去寻找ls程序，按照路径找到的第一个ls程序就会被执行。使用whereis也能确定ls的位置：

```powershell
$ whereis ls
ls: /bin/ls /usr/share/man/man1/ls.1.g
```

既然它是在bin目录下，那么我把ls从bin目录下移走是不是就找不到了呢？是的。

```shell
$ mv /bin/ls /temp/ls_bak  #测试完后记得改回来奥
```

现在再来执行ls命令看看：

```mipsasm
$ ls 
The program 'ls' is currently not installed. You can install it by typing:
apt install coreutils
```

没错，它会提示你没有安装这个程序或者命令没有找到。

所以你现在明白为什么你第一次安装jdk或者python的时候要设置环境变量了吧？不设置的话行不行？

行。这个时候你就需要指定路径了。怎么指定路径？无非就是那么几种，相对路径，绝对路径等等。
比如：

```shell
$ cd /temp
$ ./ls_bak
```

或者：

```shell
$ /temp/ls_bak
```

是不是发现和运行自己的普通程序方式没什么差别呢？

到这里，如果还没有找到你要执行的命令，那么就会报错。

# 确定解释程序

在找到程序之后呢，需要确定解释程序。什么意思呢？
shell通常可以执行两种程序，一种是二进制程序，一种是脚本程序。

而一旦发现要执行的程序文件是文本文件，且文本未指定解释程序，那么就会默认当成shell脚本来执行。例如，假设有test.txt内容如下：

```bash
echo -e "hello world"
```

赋予执行权限并执行：

```shell
$ chmod +x test.txt
$ ./test.txt
hello world
```

当然了，我们通常会在shell脚本程序的来头带上下面这句：

```bash
#!/bin/bash
```

这是告诉shell，你要用bash程序来解释执行test.txt。作为一位调皮的开发者，如果开头改成下面这样呢？

```shell
#!/usr/bin/python
```

再次执行之后结果如下：

```bash
$ ./test.txt
  File "./test.txt", line 2
    echo -e "hello world"
                        ^
SyntaxError: invalid syntax
```

是的，它被当成python脚本来执行了，自然就会报错了。

那么如果是二进制程序呢？就会使用execl族函数去创建一个新的进程来运行新的程序了。

小结一下前面的内容，就是说，如果是文本程序，且开头没有指定解释程序，则按照shell脚本处理，如果指定了解释程序，则使用解释程序来解释运行；对于二进制程序，则直接创建新的进程即可。

# 运行

前面我们也已经看到了运行方式，设置环境变量或者使用相对路径，绝对路径即可。不过对于shell脚本，你还可以像下面这样执行：

```php
$ sh test.txt
$ . test.txt  
```

即便test.txt没有执行权限，也能够正常执行。

什么？你说为什么txt也能执行？注意，Linux下的文件后缀不过是为了方便识别文件类型罢了，以.txt结尾，并不代表一定是文本。当然在这里它确实是，而且还是ASCII text executable：

```cmake
$ file test.txt
test.txt: Bourne-Again shell script, ASCII text executable
$ file hello
hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, for GNU/Linux 2.6.32, BuildID[sha1]=8ae48f0f84912dec98511581c876aa042824efdb, not stripped
```

# 扩展一下

那么如果让我们自己的程序也能够像Linux内置命令一样输入即可被识别呢？

# 将程序放到PATH路径下

第一种方法就是将我们自己的程序放到PATH中的路径中去，这样在shell输入hello时，也能找到，例如我们将其放在/bin目录下：

```javascript
$ hello
hello world
$ whereis hello
hello: /bin/hello
```

也就是说，如果你的程序安装在了PATH指定的路径，就需要配置PATH环境变量，在命令行输入就可以直接找到了。

# 设置PATH环境变量

那么如果想在指定的目录能够直接运行呢？很简单，那就是添加环境变量，例如将当前路径加入到PATH中：

```php
$ PATH=$PATH:./   #这种方式只在当前shell有效，所有shell生效可修改/etc/profile文件
$ hello
hello world
```

# 设置别名

例如：

```ruby
$ alias hello="/temp/hello"
$ hello
hello world
```

以上三种方法都可以达到目的。

# 执行顺序

那么假设我写了一个自己的printf程序，当执行printf的时候，到底执行的是哪一个呢？
实际上它的查找顺序可以可以通过type -a来查看：

```fsharp
$ type -a printf
printf is aliased to `printf "hello\n"'
printf is a shell builtin
printf is /usr/bin/printf
printf is ./printf
```

这里就可以很清楚地看到查找顺序了。也就是说，如果你输入printf，它执行的是：

```shell
$ printf
hello
```

而如果删除别名：

```bash
unalias printf
```

它执行的将会是内置命令printf。
以此类推。



# 最后

说到这里，想必标题的问题以及下面的问题你都清楚了：

- 安装Python或者Jdk程序为什么要设置PATH环境变量？如果不设置，该如何运行？
- 除了./方式运行自己的程序还有什么方式？
- 如果让自己的程序能够像内置命令一样被识别？
- 如何查看文件类型？
- 执行一条命令，如何确定是哪里的命令被执行

本文涉及命令：

- - mv 移动/重命名
  - file 查看文件信息
  - whereis 查看命令或者手册位置
  - type 查看命令类别