# 编译日志

#### 主环境编译

```
# 主编译环境: 
https://github.com/wsvn53/scrcpy-ios
https://github.com/wsvn53/scrcpy-mobile.git
# 需修改makefile, 直接编译本地(不走git init)
make libs
```

#### 编译流程

```
1. 初始编译android-tools 34.0.4版本成功, 但是在当前adb-mobile环境中运行失败, 因为他依赖的31.0.3版本
   - 在纯净的34.0.4版本中, 编译成功需要按照以下版本编译流程才能成功
   
2. 编译31.0.3版本中, 编译出现失败
   - path: adb-mobile/android-tools/vendor/boringssl/crypto/x509/t_x509.c: 500, 代码中l定义有问题
# 修复: 移除l的定义与使用
int X509_NAME_print(BIO *bp, const X509_NAME *name, int obase)
{
    char *s, *c, *b;
    int ret = 0, i;
    // int l = 80 - 2 - obase;

    b = X509_NAME_oneline(name, NULL, 0);
    if (!b)
        return 0;
    if (!*b) {
        OPENSSL_free(b);
        return 1;
    }
    s = b + 1;                  /* skip the first slash */

    c = s;
    for (;;) {
        if (((*s == '/') &&
             ((s[1] >= 'A') && (s[1] <= 'Z') && ((s[2] == '=') ||
                                                 ((s[2] >= 'A')
                                                  && (s[2] <= 'Z')
                                                  && (s[3] == '='))
              ))) || (*s == '\0')) {
            i = s - c;
            if (BIO_write(bp, c, i) != i)
                goto err;
            c = s + 1;          /* skip following slash */
            if (*s != '\0') {
                if (BIO_write(bp, ", ", 2) != 2)
                    goto err;
            }
            // l--;
        }
        if (*s == '\0')
            break;
        s++;
        // l--;
    }

    ret = 1;
    if (0) {
 err:
        OPENSSL_PUT_ERROR(X509, ERR_R_BUF_LIB);
    }
    OPENSSL_free(b);
    return (ret);
}

3. 2中修改之后继续编译, 此时libadb.a已经编译成功;
```



#### android-tools

###### 三方库

```
# libusb googletest 
brew install libusb
# protobuf lz4 zstd brotli
```

###### 编译

```
$ mkdir build && cd build
$ cmake ..
$ make
$ make install
```

###### 编译失败

```
make[2]: *** [vendor/CMakeFiles/libadb.dir/adb/client/adb_wifi.cpp.o] Error 1
make[1]: *** [vendor/CMakeFiles/libadb.dir/all] Error 2
# https://github.com/nmeum/android-tools/issues/124
# 移除openssl库
brew uninstall openssl
```



#### adb编译错误

```
make[5]: *** [vendor/CMakeFiles/libadb.dir/adb/client/auth.cpp.o] Error 1
4 errors generated.
make[5]: *** [vendor/CMakeFiles/libadb.dir/adb/client/adb_wifi.cpp.o] Error 1
make[4]: *** [vendor/CMakeFiles/libadb.dir/all] Error 2
make[3]: *** [vendor/CMakeFiles/libadb.dir/rule] Error 2
make[2]: *** [libadb] Error 2

# 先保证android-tools本身的编译成功
```



#### scrcry-server编译

```
# 编译失败: BUG! exception in phase 'semantic analysis' in source unit 'BuildScript' Unsupported class file major version 65
- 网上帖子解释是因为版本太高了: 修改版本为jdk11
- https://zhuanlan.zhihu.com/p/613356703
```

