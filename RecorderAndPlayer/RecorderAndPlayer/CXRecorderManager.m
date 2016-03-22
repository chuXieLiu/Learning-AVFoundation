//
//  CXRecorderManager.m
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXRecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CXMeterTable.h"

@interface CXRecorderManager ()
<
    AVAudioRecorderDelegate
>

@property (nonatomic,strong) AVAudioRecorder *recorder;

@property (nonatomic,strong) AVAudioPlayer *player;

@property (nonatomic,copy) CXRecorderCompletionBlock recorderCompletionBlock;

@property (nonatomic,copy) CXRecorderSaveBlock recorderSaveBlock;

// 录音时间
@property (nonatomic,assign) NSTimeInterval currentTime;

// 格式化时间
@property (nonatomic,copy) NSString *formattedTime;

@property (nonatomic,strong) CXMeterTable *meterTable; // 分贝转浮点值对应列表对象

@end

@implementation CXRecorderManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)record
{
    return [self.recorder record];
}


- (void)pause
{
    [self.recorder pause];
}

- (void)stopCompletion:(CXRecorderCompletionBlock)block
{
    _recorderCompletionBlock = block ? block : nil;
    [self.recorder stop];
}


- (void)saveRecorderWithName:(NSString *)alias completion:(CXRecorderSaveBlock)block
{
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    // 保存为apple IMA4格式
    NSString *filename = [NSString stringWithFormat:@"%@-%f.m4a",alias,timestamp];
    
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *destpath = [docsDir stringByAppendingPathComponent:filename];
    
    NSURL *srcURL = self.recorder.url;
    NSURL *destURL = [NSURL fileURLWithPath:destpath];
    NSLog(@"%@",destURL);
    
    // 拷贝文件
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:destURL error:&error];
    if (success) {
        !block ? : block(success,destURL);
        [self.recorder prepareToRecord];
    } else {
        !block ? : block(success,nil);
        NSLog(@"%@",[error localizedDescription]);
    }
    
}

- (void)playRecorderWithURL:(NSURL *)url
{
    
    [_player stop];
    _player = nil;
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (_player) {
        [_player prepareToPlay];
        [_player play];
    } else {
        NSLog(@"%@",error);
    }
}

- (NSTimeInterval)currentTime
{
    return self.recorder.currentTime;
}

- (NSString *)formattedTime
{
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = time / 3600;
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    return [NSString stringWithFormat:@"%02zd:%02zd:%02zd",hours,minutes,seconds];
}

- (void)levelsBlock:(CXRecorderDBPower)block
{
    [self.recorder updateMeters];
    float avgPower = [self.recorder averagePowerForChannel:0];
    float peakPower = [self.recorder peakPowerForChannel:0];
    float linearLevel = [self.meterTable valueForPower:avgPower];
    float linearPeak = [self.meterTable valueForPower:peakPower];
    !block ? : block(linearLevel,linearPeak);
}

#pragma mark - AVAudioRecorderDelegate

/**
 *  结束录音或者stop的时候会调用，出现中断事件的时候不会调用
 *
 *  @param recorder
 *  @param flag
 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    !_recorderCompletionBlock ? : _recorderCompletionBlock(flag);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    if ([_delegate respondsToSelector:@selector(RecorderBeginInterruption)]) {
        [_delegate RecorderBeginInterruption];
    }
}


#pragma mark - lazy

- (AVAudioRecorder *)recorder
{
    if (_recorder == nil) {
        // 设置临时路径
        NSString *tmpDir = NSTemporaryDirectory();
        // 音频录制过程中Core Audio Format（caf）通常是最好的容器格式，它和内容无关并可以保存Core Audio支持的任何音频格式
        NSString *filePath = [tmpDir stringByAppendingPathComponent:@"memo.caf"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        // 初始化录音设置
        NSMutableDictionary *setting = @{}.mutableCopy;
        // 定义音频格式(未压缩：kAudioFormatLinearPCM->.wav，kAudioFormatAppleIMA4压缩格式在保证高质量的同时显著缩小文件)
        setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);
        // 采样率，定义了对输入的模拟音频信号每一秒内的采样数
        // 低采样率：8kHz，粗粒度、AM广播类型的录制效果
        // CD质量采样率： 44.1kHz，文件较大
        // 标准采样率：8kHz，16kHz，22050Hz或44.1kHz
        setting[AVSampleRateKey] = @44100.0f;
        // 通道数 定义记录音频内容的通道数
        // 默认值1：单声道录制 值为2表示立体声录制
        setting[AVNumberOfChannelsKey] = @1;
        // 采样深度 位深16位，记录声音精度（强度）
        setting[AVEncoderBitDepthHintKey] = @16;
        // 音频质量，AVAudioQualityMedium：中等音频质量
        setting[AVEncoderAudioQualityKey] = @(AVAudioQualityMedium);
        
        
        // 创建录音对象
        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:fileURL
                                                settings:setting
                                                   error:&error];
        if (_recorder) {
            _recorder.delegate = self;
            _recorder.meteringEnabled = YES;
            [_recorder prepareToRecord];
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
        
    }
    return _recorder;
}

- (CXMeterTable *)meterTable
{
    if (_meterTable == nil) {
        _meterTable = [[CXMeterTable alloc] init];
    }
    return _meterTable;
}






@end
