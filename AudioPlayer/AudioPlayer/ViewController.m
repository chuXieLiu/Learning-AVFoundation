//
//  ViewController.m
//  AudioPlayer
//
//  Created by c_xie on 16/3/21.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CXPlayerButton.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *rateSlider;

@property (weak, nonatomic) IBOutlet CXPlayerButton *playerButton;

@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *panSliders;

@property (nonatomic,strong) IBOutletCollection(UISlider) NSArray *volumeSliders;

@property (nonatomic,strong) NSArray *players;

@property (nonatomic,assign) BOOL isPlaying;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UISlider *slider in _panSliders) {
        slider.minimumValue = 0.f;
        slider.maximumValue = 1.f;
        slider.value = 0.f;
    }
    
    for (UISlider *slider in _volumeSliders) {
        slider.minimumValue = 0.f;
        slider.maximumValue = 1.f;
        slider.value = 1.f;
    }
    
    _rateSlider.minimumValue = 0.5f;
    _rateSlider.maximumValue = 1.5f;
    _rateSlider.value =1.0f;
    
    
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    // 处理中断事件(电话)
    [noteCenter addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    // 线路变化（耳机）
    [noteCenter addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleInterruption:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    AVAudioSessionInterruptionType type = [userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {  // 中断开始
        [self stop];    // 更新播放状态
    } else {                                            // 中断结束
        AVAudioSessionInterruptionOptions options = [userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {  // 音频会话是否可以继续播放
            [self play];
        }
    }
}

- (void)handleRouteChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    AVAudioSessionRouteChangeReason reason = [userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {    // 耳机断开停止播放
        AVAudioSessionRouteDescription *previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey];    // 上一个线路
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs.firstObject;// 输出源
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self stop];
        }
    }
}

- (IBAction)playMusic:(UIButton *)sender {
    
    if (_isPlaying) {
        [self stop];
    } else {
        [self play];
    }
}

- (IBAction)rateDidChange:(UISlider *)sender {
    for (AVAudioPlayer *player in self.players) {
        player.rate = sender.value;
    }
}


// 播放
- (void)play
{
    if (!_isPlaying) {
        _playerButton.selected = !_playerButton.selected;
        NSTimeInterval delayTime = [self.players[0] deviceCurrentTime] + 0.01;// 播放延时，保持同步播放
        for (AVAudioPlayer *player in self.players) {
            [player playAtTime:delayTime];
        }
        _isPlaying = YES;
    }
}
// 暂停
- (void)stop
{
    if (_isPlaying) {
        _playerButton.selected = !_playerButton.selected;
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.currentTime = 0.f;
        }
        _isPlaying = NO;
    }
}

// 立体声
- (IBAction)valueDidChange:(UISlider *)sender {
    AVAudioPlayer *player = self.players[sender.tag];
    player.pan = sender.value;
}

// 音量
- (IBAction)volumeDidChange:(UISlider *)sender {
    AVAudioPlayer *player = self.players[sender.tag];
    player.volume = sender.value;
}


- (NSArray *)players
{
    if (_players == nil) {
        _players = @[
                         [self playerWithFilename:@"bass"],
                         [self playerWithFilename:@"drums"],
                         [self playerWithFilename:@"guitar"]
                     ];
    }
    return _players;
}

- (AVAudioPlayer *)playerWithFilename:(NSString *)filename
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"caf"];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (player) {
        player.numberOfLoops = -1;
        player.enableRate = YES;
        [player prepareToPlay];
    } else {
        NSLog(@"%@",[error localizedDescription]);
    }
    return player;
}

@end
