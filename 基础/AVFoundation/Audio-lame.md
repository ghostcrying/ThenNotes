# Music

##### OC版本

```
https://www.jianshu.com/p/4604d7ef2649
```

#### 音频长度计算

```
+ (NSTimeInterval)AudioDurationFromUrl:(NSString *)url {
    //只有这个方法获取时间是准确的 audioPlayer.duration获得的时间不准
    AVURLAsset* audioAsset = nil;
    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if ([url hasPrefix:@"http://"]) {
        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:dic];
    }else {//播放本机录制的文件
        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:dic];
    }
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}
```

#### 音频转换

```
//CAF转换mp3的lame方法
+ (NSString *)audioCAFtoMP3:(NSString *)wavPath {
    
    NSString *cafFilePath = wavPath;
    
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@.mp3",[NSString stringWithFormat:@"%@%@",[cafFilePath substringToIndex:cafFilePath.length - 4],[self getTimestamp]]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame,2);//通道数跟原音频参数设置一致
        lame_set_in_samplerate(lame, 11025.0);//采样率跟原音频参数设置一致
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [YWCommonUtils deleteFileWithPath:cafFilePath];
        return mp3FilePath;
    }
}
```

```
所有文件指定最终文件目录, 不适用临时目录
```

