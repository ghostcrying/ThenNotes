# Struct&Union字节对齐



#### 概念

1. 数据类型自身的对齐值：对于char型数据，其自身对齐值为1，对于short型为2，对于int,float,double类型，其自身对齐值为4，单位字节。

2. 结构体或者类的自身对齐值：其成员中自身对齐值最大的那个值。

3. 指定对齐值：#pragma pack (value)时的指定对齐值value。

4. 数据成员、结构体和类的有效对齐值：自身对齐值和指定对齐值中小的那个值。

   

#### 字节对齐原则

1. 数据成员对齐规则：结构(struct)(或联合(union))的数据成员，第一个数据成员放在offset为0的地方，以后每个数据成员的对齐按照#pragma pack指定的数值和这个数据成员自身长度中，比较小的那个进行。

2. 结构(或联合)的整体对齐规则：在数据成员完成各自对齐之后，结构(或联合)本身也要进行对齐，对齐将按照#pragma pack指定的数值和结构(或联合)最大数据成员长度中，比较小的那个进行。

3. 结构体作为成员：如果一个结构里有某些结构体成员，则结构体成员要从其内部最大元素大小的整数倍地址开始存储。



##### Example 01

```
struct stExample  
{  
    char    a;  
    int     b;  
    short   c;  
}; //  
sizeof( char ) == 1  
sizeof( short ) == 2  
sizeof( int ) == 4  
sizeof( struct stExample ) == 12  //?
```

> 假设stExample从地址空间0x0000开始排放。该例子中没有定义指定对齐值，在笔者环境下，该值默认为4。三个成员的存储位置如图

![c_byte_01](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/C/c_byte_01.png?raw=true)

> 1. 第一个成员变量a的自身对齐值是1，比指定或者默认指定 对齐值4小，所以其有效对齐值为1，所以其存放地址0x0000符合0x0000%1=0.
> 2. 第二个成员变量b，其自身对齐值为4，所以有效对齐值也为4， 所以只能存放在起始地址为0x0004到0x0007这四个连续的字节空间中，复核0x0004%4=0,且紧靠第一个变量。
> 3. 第三个变量c,自身对齐值为 2，所以有效对齐值也是2，可以存放在0x0008到0x0009这两个字节空间中，符合0x0008%2=0。
>
> ​        所以从0x0000到0x0009存放的 都是stExample内容。再看数据结构stExample的自身对齐值为其变量中最大对齐值(这里是b）所以就是4，所以结构体的有效对齐值也是4。根据结构体圆整的要求， 0x0009到0x0000=10字节，（10＋2）％4＝0。所以0x0000A到0x000B也为结构体stExample所占用。故stExample从0x0000到0x000B 共有12个字节,sizeof( struct stExample )=12.



##### Example 02

```
#pragma pack (2) /*指定按2字节对齐*/  
struct stExample  
{  
    char   a;  
    int    b;  
    short  c;  
};  
#pragma pack () /*取消指定对齐，恢复缺省对齐*/  
///  
sizeof( struct stExample ) == 8
```

![c_byte_02](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/C/c_byte_02.png?raw=true)

> 1. 第 一个变量a的自身对齐值为1，指定对齐值为2，所以，其有效对齐值为1，假设stExample 从0x0000开始，那么a存放在0x0000，符合0x0000%1= 0;
> 2. 第二个变量b，自身对齐值为4，指定对齐值为2，所以有效对齐值为2，所以顺序存放在0x0002、0x0003、0x0004、0x0005四个连续 字节中，符合0x0002%2=0。
> 3. 第三个变量c的自身对齐值为2，所以有效对齐值为2，顺序存放在0x0006、0x0007中，符合 0x0006%2=0。
>
> ​        所以从0x0000到0x00007共八字节存放的是stExample 的变量。又因为stExample 的自身对齐值为4，所以stExample 的有效对齐值为2。又8%2=0, stExample 只占用0x0000到0x0007的八个字节。所以sizeof( struct stExample ) == 8.



##### Example 03

```
struct stExample  {  
    char    a;  
    struct  b  {  
        char    aa;  
        short   bb;  
        int     cc;  
    }  
    short   c;  
};  
//  
sizeof( struct stExample ) == 16  
```

![c_byte_03](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/C/c_byte_03.png?raw=true)

> struct b 结构体的自身对齐值是4（由成员cc决定的），所以存储地址必须是4的整数倍。
>
> struct stExample 结构体的自身对齐值也是4（由成员struct b决定），所以最后两个字节用来补齐（即0x000E 和 0x0010）。



**Union 共用体的字节对齐情况类似，共用体的自身对齐值决定于成员的最大自身对齐值。**

**字节对齐，在一般情况下，在编写上层应用程序时一般是不用顾虑的。**

**但是有两种情况要特别小心，一是涉及到硬件memory操作，一是涉及到网络报文传输。**

**对网络报文定义结构体时，字节不对齐的话就会造成大错。有两种方法解决：**

- **可以使用pack(1)声明为1字节对齐。但是操作效率会下降，而且有些嵌入式系统的编译器支持不够好。**

- **可以将网络报文结构体内的成员变量，定义时最大使用short型，可以使用char型，但要保持偶数字节对齐。（一般标准的网络报文结构就是偶数字节对齐的）。遇到需要int型的变量,可以定义一个小共用体typedef union{ char cMem[]4;  short sMem[2] } UNION_INT ; 用它来代替int在报文结构体中使用，只是程序中注意点就行了。**