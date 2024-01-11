# VideoToolBox



## 解码

#### 属性



##### VTDecodeFrameFlags

```
kVTDecodeFrame_EnableAsynchronousDecompression：
- 表示解码器是否可以异步处理帧。当此标志被清除时，视频解码器必须在返回之前发出每个帧。当该标志被设置时，解码器可以异步处理帧，但不一定要这样做。

kVTDecodeFrame_DoNotOutputFrame：
- 提示解压会话和视频解码器不要为该帧生成CVImageBuffer，而是返回NULL。

kVTDecodeFrame_1xRealTimePlayback：
- 提示视频解码器可以使用低功耗模式进行解码，但解码速度不能超过1倍的实时速度。

kVTDecodeFrame_EnableTemporalProcessing：
- 控制视频解码器是否可以延迟帧的发出。当此标志被清除时，视频解码器应该在完成帧的解码后立即发出该帧，不能无限期地延迟帧。当该标志被设置时，解码器可以无限期地延迟帧的发出，直到调用VTDecompressionSessionFinishDelayedFrames或VTDecompressionSessionInvalidate函数。
```

##### VTDecodeInfoFlags

```
kVTDecodeInfo_Asynchronous：
- 如果解码是异步执行的，可以设置该标志。

kVTDecodeInfo_FrameDropped：
- 如果帧被丢弃，可以设置该标志。

kVTDecodeInfo_ImageBufferModifiable：
- 如果设置了kVTDecodeInfo_ImageBufferModifiable标志，客户端可以安全地修改imageBuffer。

kVTDecodeInfo_SkippedLeadingFrameDropped：
- 如果在同步帧之后丢弃了一个前导帧，则可以设置该标志。当进行同步帧的搜索并且由于帧重新排序而出现在同步帧之后的前导帧由于缺少引用而无法解码时，会发生这种情况。丢弃这些帧对播放没有影响，因为无法解码的帧不会被渲染。如果设置了kVTDecodeInfo_SkippedLeadingFrameDropped标志，也会设置kVTDecodeInfo_FrameDropped标志。
```

