# AVAudioSession

音频输入输出对与iOS系统来说是一个很重要的硬件资源，我们可以通过AVAudioSession针对不同的场景进行控制。

[官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Favfaudio%2Favaudiosession)

#### 通过AVAudioSession能做到哪些控制？

1. 为app选择输入的路由：
   - 通过手机麦克风或者耳机麦克风采集
   - 系统自动切换，插入耳机默认耳机
2. 选择APP输出的方式：
   - 通过扬声器或者听筒播放
   - 手动设置通过手机上扬声器/听筒或者耳机播放
   - 系统自动切换，插入耳机默认耳机
3. 协调音频播放的app之间的关联，以及系统的声音处理
4. 处理被其他app打断后的情况
5. 录音或者播放音乐

#### 常见的音频场景：

1. 录音和播放
2. 系统静音键按下时的表现
3. 从扬声器还是从听筒中播放声音
4. 插拔耳机的表现
5. 被电话或者闹钟打断后的表现
6. 当其他音频APP播放音频后会有怎么样的表现

#### AVAudioSession的类别 （AVAudioSession.Category）

AVAudioSession.Category定义了一组音频行为。 选择最准确地描述您需要的音频行为的类别。

[官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Favfaudio%2Favaudiosession%2Fcategory)

```
extension AVAudioSession.Category {
    @available(iOS 3.0, *)
    public static let ambient: AVAudioSession.Category

    @available(iOS 3.0, *)
    public static let soloAmbient: AVAudioSession.Category

    @available(iOS 3.0, *)
    public static let playback: AVAudioSession.Category

    @available(iOS 3.0, *)
    public static let record: AVAudioSession.Category

    @available(iOS 3.0, *)
    public static let playAndRecord: AVAudioSession.Category

    @available(iOS, introduced: 3.0, deprecated: 10.0, message: "No longer supported")
    public static let audioProcessing: AVAudioSession.Category

    @available(iOS 6.0, *)
    public static let multiRoute: AVAudioSession.Category
}
```

| 类型                              | 作用                                                         | 是否允许混音 | 音频输入 | 音频输出 |
| --------------------------------- | ------------------------------------------------------------ | ------------ | -------- | -------- |
| ambient                           | 将此类别用于背景声音，例如雨、汽车发动机噪音等。  与其他音乐混合。适用于“伴奏”应用程序，例如用户在播放音乐应用程序时弹奏的虚拟钢琴。 当您使用此类别时，来自其他应用程序的音频会与您的音频混合。 屏幕锁定和静音开关，会使音频静音。 比如：玩游戏的时候还想听QQ音乐的歌，那么把游戏播放背景音就设置成这种类别。 | 是           | 否       | 是       |
| soloAmbient                       | 默认的类别，只用于播放,但是和"ambient"不同的是，用了它就别想听QQ音乐了，比如不希望QQ音乐干扰的App，类似节奏大师。 | 否           | 否       | 是       |
| playback                          | 锁屏了还想听声音用这个类别，比如App本身就是播放器，同时当App播放时，其他类似QQ音乐就不能播放了。所以这种类别一般用于播放器类App。 | 可选         | 否       | 是       |
| record                            | 只要会话处于活动状态，此类别就会使系统上的几乎所有输出静音。 除非您需要防止播放任何意外的声音，否则请改用 playAndRecord。要在应用转换到后台时（例如，屏幕锁定时）继续录制音频，请将音频值添加到信息属性列表文件中的 UIBackgroundModes 键。用户必须授予录音权限。使用场景如 微信语音。 | 否           | 是       | 否       |
| playAndRecord                     | 用于录制（输入）和播放（输出）音频的类别，VoIP，打电话这种场景，PlayAndRecord就是专门为这样的场景设计的 。音频会在静音开关设置为静音并锁定屏幕的情况下继续播放。要在应用转换到后台时（例如，屏幕锁定时）继续播放音频，请将音频值添加到信息属性列表文件中的 UIBackgroundModes 键。此类别适用于同时录制和播放，也适用于录制和播放但不能同时进行的应用程序。默认情况下，使用此类别意味着应用程序的音频是不可混合的——激活您的会话将中断任何其他同样不可混合的音频会话。 要允许此类别的混合，请使用 mixWithOthers 选项。用户必须授予录音权限。此类别支持 Airplay 的镜像版本。 但是，如果 AVAudioSessionModeVoiceChat 模式与此类别一起使用，AirPlay 镜像将被禁用。 | 可选         | 是       | 是       |
| audioProcessing (iOS 10 中已弃用) | 此类别禁用播放（音频输出）并禁用录制（音频输入）。 例如，在执行离线音频格式转换时使用此类别。主要用于音频格式处理，一般可以配合AudioUnit进行使用 | 否           | 否       | 否       |
| multiRoute                        | 用于将不同的音频数据流同时路由到不同的输出设备的类别。此类别可用于输入、输出或两者。 例如，使用此类别将音频路由到 USB 设备和一组耳机。 使用此类别需要更详细地了解可用音频路由的功能并与之交互。路由更改可能会使您的部分或全部多路由配置无效。 使用 multiRoute 类别时，您必须注册以观察 routeChangeNotification 通知并根据需要更新您的配置。 |              | 是       | 是       |

| 类型            | 使用场景                                                     | 锁屏或按静音时 |
| --------------- | ------------------------------------------------------------ | -------------- |
| ambient         | 当前App的播放声音可以和其他app播放的声音共存                 | 停止           |
| soloAmbient     | 只能播放当前App的声音，其他app的声音会停止                   | 停止           |
| playback        | 只能播放当前App的声音，其他app的声音会停止                   | 不会停止       |
| record          | 只能用于录音，其他app的声音会停止                            | 不会停止       |
| playAndRecord   | 在录音的同时播放其他声音，可用于听筒播放，比如微信语音消息听筒播放 | 不会停止       |
| audioProcessing | 使用硬件解码器处理音频，该音频会话使用期间，不能播放或录音   | 不会停止       |
| multiRoute      | 多种音频输入输出，例如可以耳机、USB设备同时播放等            | 不会停止       |

> 注意：除了 AVAudioSessionCategoryMultiRoute 外，其他的 Category 都遵循 last in wins 原则，即最后接入的音频设备作为输入或输出的主设备。

#### 类别选项AVAudioSession.CategoryOptions

每个选项仅对特定的音频会话类别有效，和category进行组合使用，从而更加精确的控制音频行为。

[官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Favfaudio%2Favaudiosession%2Fcategoryoptions)

```swift
public struct CategoryOptions : OptionSet, @unchecked Sendable {

      public init(rawValue: UInt)

      public static var mixWithOthers: AVAudioSession.CategoryOptions { get }

      public static var duckOthers: AVAudioSession.CategoryOptions { get }

      public static var allowBluetooth: AVAudioSession.CategoryOptions { get }

      public static var defaultToSpeaker: AVAudioSession.CategoryOptions { get }

      @available(iOS 9.0, *)
      public static var interruptSpokenAudioAndMixWithOthers: AVAudioSession.CategoryOptions { get }

      @available(iOS 10.0, *)
      public static var allowBluetoothA2DP: AVAudioSession.CategoryOptions { get }

      @available(iOS 10.0, *)
      public static var allowAirPlay: AVAudioSession.CategoryOptions { get }

      @available(iOS 14.5, *)
      public static var overrideMutedMicrophoneInterruption: AVAudioSession.CategoryOptions { get }
  }
```

| 选项                                 | 作用                                                         | 适用类别                                                     |
| ------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| mixWithOthers                        | 指示来自此会话的音频是否与来自其他音频应用程序中的活动会话的音频混合 仅当音频会话类别为 **playAndRecord**、**playback**或 **multiRoute** 时，才能显式设置此选项。如果您将音频会话类别设置为 **ambient**，会话会自动设置此选项。同样，设置**duckOthers** 或**interruptSpokenAudioAndMixWithOthers**选项也会启用此选项。 清除此选项然后激活您的会话会中断其他音频会话。如果您设置此选项，您的应用程序会将其音频与后台应用程序（例如音乐应用程序）中播放的音频混合。 | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute 用于可以和其他app进行混音 |
| duckOthers                           | 在播放此会话的音频时降低其他音频会话音量的选项。 仅当音频会话类别为 **playAndRecord**、**playback**或 **multiRoute** 时，您才能设置此选项。设置它会隐式设置 **mixWithOthers**选项。 使用此选项将您的应用程序的音频与其他应用程序的音频混合。当您的应用程序播放其音频时，系统会降低其他音频会话的音量以使您的应用程序更加突出。如果您的应用程序偶尔提供语音音频，例如在逐步导航应用程序或锻炼应用程序中，您还应该设置 **interruptSpokenAudioAndMixWithOthers**选项。 请注意，当您激活应用程序的音频会话时，闪避开始，并在您停用会话时结束。如果您清除此选项，激活您的会话会中断其他音频会话。 | AVAudioSessionCategoryAmbient AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute 用于压低其他声音播放的音量，使期音量变小 |
| interruptSpokenAudioAndMixWithOthers | 用于确定在您的应用播放其音频时是否暂停来自其他会话的语音音频内容。 仅当音频会话类别为 **playAndRecord**、**playback**或 **multiRoute** 时，您才能设置此选项。设置此选项还会设置 **mixWithOthers**。 如果您清除此选项，您的音频会话中的音频会中断其他会话。如果设置此选项，系统会将您的音频与其他音频会话混合，但会中断（并停止）使用 speakAudio 音频会话模式的音频会话。只要您的会话处于活动状态，它就会暂停其他应用程序的音频。在您的音频会话停用后，系统会恢复中断的应用程序的音频。 如果您的应用程序的音频是偶尔的和口头的，请设置此选项，例如在逐向导航应用程序或锻炼应用程序中。这避免了两个语音音频应用程序混合时的可理解性问题。如果你设置了这个选项，除非你有特定的理由不这样做，否则还要设置duckOthers 选项。当其他音频不是口语音频时，避开其他音频而不是打断它是合适的。 当您使用此选项配置音频会话类别时，请在停用会话时通知系统上的其他应用程序，以便它们可以恢复音频播放。为此，请使用 **notifyOthersOnDeactivation** 选项停用您的会话。 | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryPlayback AVAudioSessionCategoryMultiRoute |
| allowBluetooth                       | 确定蓝牙免提设备是否显示为可用输入路径的选项。 您需要设置此选项以允许将音频输入和输出路由到配对的蓝牙免提配置文件 (HFP) 设备。如果您清除此选项，配对的蓝牙 HFP 设备不会显示为可用的音频输入路由。 如果应用程序使用 setPreferredInput(_:) 方法选择蓝牙 HFP 输入，则输出会自动更改为相应的蓝牙 HFP 输出。同样，使用 MPVolumeView 对象的路由选择器选择蓝牙 HFP 输出会自动将输入更改为相应的蓝牙 HFP 输入。因此，即使您只选择了输入或输出，音频输入和输出也会路由到蓝牙 HFP 设备。 仅当音频会话类别为 **playAndRecord** 或**record**时，您才能设置此选项。 | AVAudioSessionCategoryRecord and AVAudioSessionCategoryPlayAndRecord 用于是否支持蓝牙设备耳机等 |
| allowBluetoothA2DP                   | 确定您是否可以将此会话中的音频流式传输到支持高级音频分发配置文件 (A2DP) 的蓝牙设备的选项。 A2DP 是一种仅用于输出的立体声配置文件，适用于更高带宽的音频用例，例如音乐播放。如果您将应用程序的音频会话配置为使用**ambient**、**soloAmbient** 或**playback**类别，系统会自动路由到 A2DP 端口。 从 iOS 10.0 开始，使用 playAndRecord 类别的应用程序还可以允许将输出路由到配对的蓝牙 A2DP 设备。要启用此行为，请在设置音频会话的类别时传递此类别选项。 使用 **multiRoute** 或**record**类别的音频会话会隐式清除此选项。如果清除它，配对的蓝牙 A2DP 设备不会显示为可用的音频输出路径。 笔记 如果同时设置了该选项和**allowBluetooth** 选项，则当单个设备同时支持免提协议（HFP）和A2DP 时，系统会赋予免提端口更高的路由优先级。 | AVAudioSessionCategoryPlayAndRecord 蓝牙和a2dp               |
| allowAirPlay                         | 确定您是否可以将此会话中的音频流式传输到 AirPlay 设备的选项。 设置此选项可使音频会话将音频输出路由到 AirPlay 设备。如果音频会话的类别设置为 **playAndRecord**，您只能显式设置此选项。对于大多数其他音频会话类别，系统会隐式设置此选项。 使用 **multiRoute** 或**record**类别的音频会话会隐式清除此选项。 | AVAudioSessionCategoryPlayAndRecord airplay                  |
| defaultToSpeaker                     | 一个选项，用于确定会话中的音频是否默认为内置扬声器而不是接收器。 只有在使用 **playAndRecord** 类别时才能设置此选项。它用于修改类别的路由行为，以便在没有使用其他配件（例如耳机）时，音频始终路由到扬声器而不是接收器。 使用此选项时，系统尊重用户手势。例如，插入耳机会导致路由更改为耳机麦克风/耳机，拔下耳机会导致路由更改为内置麦克风/扬声器（而不是内置麦克风/接收器）这个覆盖。 在使用仅 USB 输入附件的情况下，音频输入来自附件，系统将音频路由到耳机（如果已连接）或扬声器（如果耳机未插入）。用例是路由在音频通常会传输到接收器的情况下，音频传输到扬声器而不是接收器。 路线更改和中断不会重置此覆盖。只有更改音频会话类别才会重置此选项。 | AVAudioSessionCategoryPlayAndRecord 用于将声音从Speaker播放，外放，即免提 |
| overrideMutedMicrophoneInterruption  | 指示系统在使内置麦克风静音时是否中断音频会话的选项。 某些设备包含隐私功能，可在特定条件下（例如当您合上 iPad 的 Smart Folio 保护套时）在硬件级别使内置麦克风静音。发生这种情况时，系统会中断从麦克风捕获输入的音频会话。在系统将麦克风静音后尝试开始音频输入会导致错误。 如果您的应用使用支持输入和输出的音频会话类别，例如 **playAndRecord**，您可以设置此选项以禁用默认行为并继续使用会话。禁用默认行为可能有助于让您的应用在录制或监控静音麦克风时继续播放不会导致糟糕的用户体验。当您设置此选项时，播放将照常继续，并且麦克风硬件会生成样本缓冲区，但值为 0。 尝试将此选项用于不支持音频输入的会话类别会导致错误。 |                                                              |

#### 模式 AVAudioSession.Mode

虽然类别为您的应用程序设置了基本行为，但您使用模式将专门的行为分配给音频会话类别。 指定音频会话类别不支持的模式，例如为 multiRoute 类别设置 gameChat 模式，会导致音频会话使用默认模式行为。

[官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Favfaudio%2Favaudiosession%2Fmode)

```swift
extension AVAudioSession.Mode {
    @available(iOS 5.0, *)
    public static let `default`: AVAudioSession.Mode
  
    @available(iOS 5.0, *)
    public static let voiceChat: AVAudioSession.Mode

    @available(iOS 5.0, *)
    public static let gameChat: AVAudioSession.Mode

    @available(iOS 5.0, *)
    public static let videoRecording: AVAudioSession.Mode

    @available(iOS 5.0, *)
    public static let measurement: AVAudioSession.Mode

    @available(iOS 6.0, *)
    public static let moviePlayback: AVAudioSession.Mode

    @available(iOS 7.0, *)
    public static let videoChat: AVAudioSession.Mode

   
    @available(iOS 9.0, *)
    public static let spokenAudio: AVAudioSession.Mode

    @available(iOS 12.0, *)
    public static let voicePrompt: AVAudioSession.Mode
}
```

| 模式           | 作用                                                         | 适用类别                                                     |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| default        | 默认的音频会话模式。默认的音频会话模式。                     | 默认的模式，适用于所有的场景，可用于场景还原                 |
| gameChat       | GameKit 框架代表使用 GameKit 语音聊天服务的应用程序设置的模式。 此模式仅对 **playAndRecord** 音频会话类别有效。 不要直接设置此模式。如果您需要类似的行为并且不使用 **GKVoiceChat** 对象，请改用 **voiceChat**或 **videoChat**。 | AVAudioSessionCategoryPlayAndRecord 应用场景游戏录制，由GKVoiceChat自动设置，无需手动调用 |
| measurement    | 表明您的应用正在执行音频输入或输出的测量 对于需要最大限度地减少系统提供的对输入和输出信号的信号处理量的应用程序，请使用此模式。如果在具有多个内置麦克风的设备上录制，会话将使用主麦克风。 用于**playback**、**record**或 **playAndRecord** 音频会话类别。 | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryRecord AVAudioSessionCategoryPlayback |
| moviePlayback  | 表示您的应用正在播放电影内容的模式。 当您设置此模式时，音频会话使用信号处理来增强某些音频路径（例如内置扬声器或耳机）的电影播放。您只能将此模式与**playback**音频会话类别一起使用。 | AVAudioSessionCategoryPlayBack 应用场景视频播放              |
| spokenAudio    | 一种用于连续语音的模式，用于在另一个应用播放简短的音频提示时暂停音频。 此模式适用于播放连续语音的应用程序，例如播客或有声读物。设置此模式表示如果另一个应用程序播放语音提示，您的应用程序应该暂停而不是躲避它的音频。中断应用的音频结束后，您可以恢复应用的音频播放。 |                                                              |
| videoChat      | 表明您的应用正在参与在线视频会议。 将此模式用于使用 **playAndRecord** 或**record**类别的视频聊天应用程序。当您设置此模式时，音频会话会优化设备的语音音调均衡。它还将允许的音频路由集减少到仅适用于视频聊天的那些。 使用此模式具有启用 **allowBluetooth** 类别选项的副作用。 对于使用语音或视频聊天的应用程序，还可以使用语音处理 I/O 音频单元。语音处理 I/O 单元为 VoIP 应用程序提供了多种功能，包括自动增益校正、语音处理调整和静音。有关详细信息，请参阅语音处理 I/O 单元。 如果应用程序使用语音处理 I/O 音频单元并且没有将其模式设置为其中一种聊天模式（语音、视频或游戏），则会话会隐式设置语音聊天模式。另一方面，如果应用程序之前已将其类别设置为 **playAndRecord** 并将其模式设置为 **videoChat** 或 **gameChat**，则实例化 Voice-Processing I/O 音频单元不会导致模式更改。 | AVAudioSessionCategoryPlayAndRecord应用场景视频通话          |
| videoRecording | 表示您的应用正在录制电影的模式。 此模式仅对 **record** 和 **playAndRecord** 音频会话类别有效。在具有多个内置麦克风的设备上，音频会话使用离摄像机最近的麦克风。 使用此模式可确保系统提供适当的音频信号处理。 将 **AVCaptureSession** 与视频录制模式结合使用，可以更好地控制输入和输出路径。例如，设置 **automaticConfiguresApplicationAudioSession**属性会导致会话自动为所使用的设备和摄像头选择最佳输入路由。 | AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryRecord 应用场景视频录制 |
| voiceChat      | 表明您的应用正在执行双向语音通信，例如使用互联网协议语音 (VoIP)。 将此模式用于使用 **playAndRecord** 类别的 IP 语音 (VoIP) 应用程序。当您设置此模式时，会话会优化设备的语音音调均衡，并将允许的音频路由集减少到仅适用于语音聊天的那些。 使用此模式具有启用 **allowBluetooth** 类别选项的副作用。 对于使用语音或视频聊天的应用程序，还可以使用语音处理 I/O 音频单元。语音处理 I/O 单元为 VoIP 应用程序提供了多种功能，包括自动增益校正、语音处理调整和静音。有关详细信息，请参阅语音处理 I/O 单元。 如果应用程序使用语音处理 I/O 音频单元并且没有将其模式设置为其中一种聊天模式（语音、视频或游戏），则会话会隐式设置语音聊天模式。另一方面，如果应用程序之前已将其类别设置为 **playAndRecord** 并将其模式设置为 **videoChat** 或 **gameChat**，则实例化 Voice-Processing I/O 音频单元不会导致模式更改。 | AVAudioSessionCategoryPlayAndRecord应用场景VoIP              |
| voicePrompt    | 指示您的应用使用文本转语音播放音频。 当您的应用程序连接到某些音频设备（例如 CarPlay）时，设置此模式允许不同的路由行为。使用此模式的应用程序示例是向用户播放简短提示的逐向导航应用程序。 通常，相同类型的应用程序还会将其会话配置为使用 **duckOthers** 和 **interruptSpokenAudioAndMixWithOthers** 选项。 |                                                              |

#### AVAudioSession.RouteSharingPolicy

指示音频会话可能的路由共享策略的案例。路由共享策略允许您指定音频会话应在替代路由可用时将其输出路由到默认系统输出以外的其他位置。

[官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Favfaudio%2Favaudiosession%2Froutesharingpolicy)

```swift
public enum RouteSharingPolicy : UInt, @unchecked Sendable {

      case `default` = 0

      case longFormAudio = 1

      @available(iOS, introduced: 11.0, deprecated: 13.0, renamed: "AVAudioSession.RouteSharingPolicy.longFormAudio")
      public static var longForm: AVAudioSession.RouteSharingPolicy { get }

      case independent = 2

      @available(iOS 13.0, *)
      case longFormVideo = 3
  }
```

| 策略          | 作用                                                         |
| ------------- | ------------------------------------------------------------ |
| default       | 遵循用于路由音频输出的标准规则的策略。                       |
| longFormAudio | 将输出路由到共享长格式音频输出的策略。 播放长格式音频（如音乐或有声读物）的应用程序可以使用此策略播放到与内置音乐和播客应用程序相同的输出。长格式音频应用程序还应该使用媒体播放器框架来添加对远程控制事件的支持并提供正在播放的信息。 在使用此策略的 watchOS 中运行的应用程序能够在后台播放音频，只要音频会话可以激活符合条件的音频路由。这些应用程序必须使用 **activate(options:completionHandler:)** 方法激活它们的音频会话。这确保了当音频会话无法自动选择一个时，用户有机会选择适当的音频路由。 |
| longFormVideo | 将输出路由到共享长格式视频输出的策略。 播放长视频内容的应用程序可以使用此策略播放到与其他长视频应用程序（例如内置电视应用程序）相同的输出。这些应用程序还应将其 Info.plist 中的 **AVInitialRouteSharingPolicy** 键设置为 **LongFormVideo**。即使系统将长格式视频内容路由到 AirPlay，不使用此路由共享策略的视频内容仍保留在播放设备本地。 |
| independent   | 路由选择器 UI 将视频定向到无线路由的策略。 在 iOS 中，系统会在用户使用路由选择器 UI 将视频定向到无线路由的情况下设置此策略。应用程序不应尝试直接设置此值。 |
| longForm      | 将输出路由到共享长格式音频输出的策略。 主要用例是作为音乐或播客播放器的音频会话可以使用此值播放到与音乐和播客应用程序相同的输出。系统上使用此策略的所有应用程序都将其音频路由到同一位置。 |