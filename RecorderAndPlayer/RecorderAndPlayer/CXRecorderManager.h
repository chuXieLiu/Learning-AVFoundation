//
//  CXRecorderManager.h
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CXRecorderManagerDelegate <NSObject>

@optional

// 中断事件
- (void)RecorderBeginInterruption;

@end

typedef void(^CXRecorderCompletionBlock)(BOOL success);

typedef void(^CXRecorderSaveBlock)(BOOL success,NSURL *fileURL);

typedef void(^CXRecorderDBPower)(float avgPower, float peakPower);

@interface CXRecorderManager : NSObject

@property (nonatomic,weak) id<CXRecorderManagerDelegate> delegate;

// 录音时间
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;

// 格式化时间
@property (nonatomic,copy,readonly) NSString *formattedTime;

/**
 *  开始录音
 *
 *  @return 
 */
- (BOOL)record;


/**
 *  暂停
 */
- (void)pause;


/**
 *  停止播放
 *
 *  @param block 停止播放回调
 */
- (void)stopCompletion:(CXRecorderCompletionBlock)block;



/**
 *  保存录音回调
 *
 *  @param name  文件别名
 *  @param block 保存回调
 */
- (void)saveRecorderWithName:(NSString *)alias completion:(CXRecorderSaveBlock)block;


/**
 *  播放录音
 *
 *  @param url 路径
 */
- (void)playRecorderWithURL:(NSURL *)url;


/**
 *  录制声音平均分贝与峰值
 *
 *  @param block 
 */
- (void)levelsBlock:(CXRecorderDBPower)block;






@end
