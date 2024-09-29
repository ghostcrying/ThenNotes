# Unity - Swift



> 

在 Swift 中，`@_cdecl` 是一个属性，可以用于标记使用 C 语言调用约定（calling convention）的函数或变量。在 Swift 中，函数调用约定默认使用 Swift 调用约定，而不是 C 语言调用约定。如果您需要与 C 语言编写的代码交互，或者需要在 Swift 中调用使用 C 语言调用约定的函数，就可以使用 `@_cdecl` 属性来标记函数。

下面是一个使用 `@_cdecl` 标记的 Swift 函数的示例：

```swift
@_cdecl("myCFunction")
func mySwiftFunction(_ arg1: Int32, _ arg2: Int32) -> Int32 {
    return arg1 + arg2
}
```

在上面的示例中，我们定义了一个名为 `mySwiftFunction` 的 Swift 函数，并使用 `@_cdecl` 属性将其标记为使用 C 语言调用约定。我们还指定了一个字符串参数 `"myCFunction"`，用于指定使用 C 语言调用约定时的函数名称。

在使用该函数时，我们可以按照 C 语言调用约定的方式将参数传递给该函数，并通过返回值获取函数的计算结果。例如，在 C 语言中，可以按照以下方式调用该函数：

```c
#include <stdio.h>

int main() {
    int result = myCFunction(1, 2);
    printf("Result: %d\n", result);
    return 0;
}
```

在上面的示例中，我们使用 C 语言的方式调用了 `myCFunction` 函数，并将返回值打印到控制台中。由于我们使用了 `@_cdecl` 属性标记该函数，因此可以在 Swift 和 C 语言之间无缝交互。