//
//  AppDelegate.m
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        NSLog(@"%@",[error description]);
    }
    if (![session setActive:YES error:&error]) {
        NSLog(@"%@",[error description]);
    }
    return YES;
}

@end
