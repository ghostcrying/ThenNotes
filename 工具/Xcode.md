# Xcode



#### 调试

[参考](https://www.cnblogs.com/holyday/p/7987314.html)

```
# help打印所有lldb指令

(lldb) help
Debugger commands:
  apropos           -- List debugger commands related to a word or subject.
  breakpoint        -- Commands for operating on breakpoints (see 'help b' for
                       shorthand.)
  command           -- Commands for managing custom LLDB commands.
  disassemble       -- Disassemble specified instructions in the current
                       target.  Defaults to the current function for the
                       current thread and stack frame.
  expression        -- Evaluate an expression on the current thread.  Displays
                       any returned value with LLDB's default formatting.
  frame             -- Commands for selecting and examing the current thread's
                       stack frames.
  gdb-remote        -- Connect to a process via remote GDB server.  If no host
                       is specifed, localhost is assumed.
  gui               -- Switch into the curses based GUI mode.
  help              -- Show a list of all debugger commands, or give details
                       about a specific command.
  kdp-remote        -- Connect to a process via remote KDP server.  If no UDP
                       port is specified, port 41139 is assumed.
  language          -- Commands specific to a source language.
  log               -- Commands controlling LLDB internal logging.
  memory            -- Commands for operating on memory in the current target
                       process.
  platform          -- Commands to manage and create platforms.
  plugin            -- Commands for managing LLDB plugins.
  process           -- Commands for interacting with processes on the current
                       platform.
  quit              -- Quit the LLDB debugger.
  register          -- Commands to access registers for the current thread and
                       stack frame.
  reproducer        -- Commands for manipulating reproducers. Reproducers make
                       it possible to capture full debug sessions with all its
                       dependencies. The resulting reproducer is used to replay
                       the debug session while debugging the debugger.
                       Because reproducers need the whole the debug session
                       from beginning to end, you need to launch the debugger
                       in capture or replay mode, commonly though the command
                       line driver.
                       Reproducers are unrelated record-replay debugging, as
                       you cannot interact with the debugger during replay.
  script            -- Invoke the script interpreter with provided code and
                       display any results.  Start the interactive interpreter
                       if no code is supplied.
  session           -- Commands controlling LLDB session.
  settings          -- Commands for managing LLDB settings.
  source            -- Commands for examining source code described by debug
                       information for the current target process.
  statistics        -- Print statistics about a debugging session
  target            -- Commands for operating on debugger targets.
  thread            -- Commands for operating on one or more threads in the
                       current process.
  trace             -- Commands for loading and using processor trace
                       information.
  type              -- Commands for operating on the type system.
  version           -- Show the LLDB debugger version.
  watchpoint        -- Commands for operating on watchpoints.
Current command abbreviations (type 'help command alias' for more info):
  add-dsym  -- Add a debug symbol file to one of the target's current modules
               by specifying a path to a debug symbols file or by using the
               options to specify a module.
  attach    -- Attach to process by ID or name.
  b         -- Set a breakpoint using one of several shorthand formats.
  bt        -- Show the current thread's call stack.  Any numeric argument
               displays at most that many frames.  The argument 'all' displays
               all threads.  Use 'settings set frame-format' to customize the
               printing of individual frames and 'settings set thread-format'
               to customize the thread header.
  c         -- Continue execution of all threads in the current process.
  call      -- Evaluate an expression on the current thread.  Displays any
               returned value with LLDB's default formatting.
  continue  -- Continue execution of all threads in the current process.
  detach    -- Detach from the current target process.
  di        -- Disassemble specified instructions in the current target. 
               Defaults to the current function for the current thread and
               stack frame.
  dis       -- Disassemble specified instructions in the current target. 
               Defaults to the current function for the current thread and
               stack frame.
  display   -- Evaluate an expression at every stop (see 'help target
               stop-hook'.)
  down      -- Select a newer stack frame.  Defaults to moving one frame, a
               numeric argument can specify an arbitrary number.
  env       -- Shorthand for viewing and setting environment variables.
  exit      -- Quit the LLDB debugger.
  f         -- Select the current stack frame by index from within the current
               thread (see 'thread backtrace'.)
  file      -- Create a target using the argument as the main executable.
  finish    -- Finish executing the current stack frame and stop after
               returning.  Defaults to current thread unless specified.
  history   -- Dump the history of commands in this session.
               Commands in the history list can be run again using "!<INDEX>". 
               "!-<OFFSET>" will re-run the command that is <OFFSET> commands
               from the end of the list (counting the current command).
  image     -- Commands for accessing information for one or more target
               modules.
  j         -- Set the program counter to a new address.
  jump      -- Set the program counter to a new address.
  kill      -- Terminate the current target process.
  l         -- List relevant source code using one of several shorthand formats.
  list      -- List relevant source code using one of several shorthand formats.
  n         -- Source level single step, stepping over calls.  Defaults to
               current thread unless specified.
  next      -- Source level single step, stepping over calls.  Defaults to
               current thread unless specified.
  nexti     -- Instruction level single step, stepping over calls.  Defaults to
               current thread unless specified.
  ni        -- Instruction level single step, stepping over calls.  Defaults to
               current thread unless specified.
  p         -- Evaluate an expression on the current thread.  Displays any
               returned value with LLDB's default formatting.
  parray    -- parray <COUNT> <EXPRESSION> -- lldb will evaluate EXPRESSION to
               get a typed-pointer-to-an-array in memory, and will display
               COUNT elements of that type from the array.
  po        -- Evaluate an expression on the current thread.  Displays any
               returned value with formatting controlled by the type's author.
  poarray   -- poarray <COUNT> <EXPRESSION> -- lldb will evaluate EXPRESSION to
               get the address of an array of COUNT objects in memory, and will
               call po on them.
  print     -- Evaluate an expression on the current thread.  Displays any
               returned value with LLDB's default formatting.
  q         -- Quit the LLDB debugger.
  r         -- Launch the executable in the debugger.
  rbreak    -- Sets a breakpoint or set of breakpoints in the executable.
  re        -- Commands to access registers for the current thread and stack
               frame.
  repl      -- Evaluate an expression on the current thread.  Displays any
               returned value with LLDB's default formatting.
  run       -- Launch the executable in the debugger.
  s         -- Source level single step, stepping into calls.  Defaults to
               current thread unless specified.
  shell     -- Run a shell command on the host.
  si        -- Instruction level single step, stepping into calls.  Defaults to
               current thread unless specified.
  sif       -- Step through the current block, stopping if you step directly
               into a function whose name matches the TargetFunctionName.
  step      -- Source level single step, stepping into calls.  Defaults to
               current thread unless specified.
  stepi     -- Instruction level single step, stepping into calls.  Defaults to
               current thread unless specified.
  t         -- Change the currently selected thread.
  tbreak    -- Set a one-shot breakpoint using one of several shorthand formats.
  undisplay -- Stop displaying expression at every stop (specified by stop-hook
               index.)
  up        -- Select an older stack frame.  Defaults to moving one frame, a
               numeric argument can specify an arbitrary number.
  v         -- Show variables for the current stack frame. Defaults to all
               arguments and local variables in scope. Names of argument,
               local, file static and file global variables can be specified.
               Children of aggregate variables can be specified such as
               'var->child.x'.  The -> and [] operators in 'frame variable' do
               not invoke operator overloads if they exist, but directly access
               the specified element.  If you want to trigger operator
               overloads use the expression command to print the variable
               instead.
               It is worth noting that except for overloaded operators, when
               printing local variables 'expr local_var' and 'frame var
               local_var' produce the same results.  However, 'frame variable'
               is more efficient, since it uses debug information and memory
               reads directly, rather than parsing and evaluating an
               expression, which may even involve JITing and running code in
               the target program.
  var       -- Show variables for the current stack frame. Defaults to all
               arguments and local variables in scope. Names of argument,
               local, file static and file global variables can be specified.
               Children of aggregate variables can be specified such as
               'var->child.x'.  The -> and [] operators in 'frame variable' do
               not invoke operator overloads if they exist, but directly access
               the specified element.  If you want to trigger operator
               overloads use the expression command to print the variable
               instead.
               It is worth noting that except for overloaded operators, when
               printing local variables 'expr local_var' and 'frame var
               local_var' produce the same results.  However, 'frame variable'
               is more efficient, since it uses debug information and memory
               reads directly, rather than parsing and evaluating an
               expression, which may even involve JITing and running code in
               the target program.
  vo        -- Show variables for the current stack frame. Defaults to all
               arguments and local variables in scope. Names of argument,
               local, file static and file global variables can be specified.
               Children of aggregate variables can be specified such as
               'var->child.x'.  The -> and [] operators in 'frame variable' do
               not invoke operator overloads if they exist, but directly access
               the specified element.  If you want to trigger operator
               overloads use the expression command to print the variable
               instead.
               It is worth noting that except for overloaded operators, when
               printing local variables 'expr local_var' and 'frame var
               local_var' produce the same results.  However, 'frame variable'
               is more efficient, since it uses debug information and memory
               reads directly, rather than parsing and evaluating an
               expression, which may even involve JITing and running code in
               the target program.
  x         -- Read from the memory of the current target process.
For more information on any command, type 'help <command-name>'.
(lldb) 

```



```
# 打印信息
(lldb) po
# 打印堆栈
(lldb) bt  或者  bt all

# 多线程异常后查看历史对象的malloc分配历史
(lldb) command script import lldb.macosx.heap
(lldb) malloc_info -S 0x7ff7206c3a70 

# 更改程序实际参数值
(lldb) expr

# 查看工程中使用的库
image list 
# 程序崩溃的时候定位，查看具体报错位置
image lookup --address  0x000000010e0979ac  

# call: 类似于po, 可以在无返回值时调用
# 
```



#### ARM选择

```
arm64  必选项，支持iphone5s及以上；最低支持版本：iOS5.1.1
armv7s 支持iPhone5及以上
armv7  支持iPhone4及以上
```



#### 常用路径

```
描述文件路径
~/Library/MobileDevice/Provisioning Profiles

缓存路径
~/Library/Developer/Xcode/DerivedData

插件路径
~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name

旧设备支持
~/Library/Application Support/Developer/Shared/Xcode/Plug-ins

模拟器缓存
~/Library/Developer/CoreSimulator/Devices/

Xcode中无效插件
~/Library/Application Support/Developer/Shared/Xcode/Plug-ins

旧版本模拟器
~/Library/Developer/CoreSimulator/Profiles/Runtimes/

Playground项目缓存
~/Library/Developer/XCPGDevices/

Xcode PCH 根文件路径
$(PROJECT_DIR)/$(PROJECT_NAME)/

flutter路径
/usr/local/Caskroom/flutter/2.8.1/flutter/.pub-cache/git/cache
```



#### 版本

```
/Library/Developer/CoreSimulator/Profiles/Runtimes

https://devimages-
cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_4-11.4.1.1527703358.dmg  11.4

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK10_0-10.0.1.1474488730.dmg  10.0

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK10_1-10.1.1.1476902849.dmg 10.1

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK10_2-10.2.1.1484185528.dmg  10.2

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK10_3-10.3.1.1495751597.dmg  10.3.1

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_0-11.0.1.1508875951.dmg  11.0

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_1-11.1.1.1510784422.dmg  11.1

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_2-11.2.1.1516308624.dmg  11.2

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_3-11.3.1.1524350608.dmg  11.3

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK11_4-11.4.1.1527703358.dmg  11.4

https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK12_0-12.0.1.1537588161.dmg   12.0
```

