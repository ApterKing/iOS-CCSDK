//
//  CCRecoder.h
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CCRecorder;
@protocol CCRecorderDelegate <NSObject>

@optional
- (void)recorder:(CCRecorder *)voiceRecorder averagePowerChanged:(float)power;

- (void)recorder:(CCRecorder *)voiceRecorder didFinishRecording:(BOOL)flag;

@end

/**
 *  Created by wangcong on 14-11-26. <br>
 *  录音工具类，支持录音路径及录音最大时常设置
 */
@interface CCRecorder : NSObject<AVAudioRecorderDelegate>

@property (nonatomic, weak) id<CCRecorderDelegate> delegate;

/**
 *  制定最大录音时长开始录音，并将录音数据保存在制定路径
 *  @param filePath 音频保存路劲
 *  @param interval 最大录制时常
 */
- (void)startRecorderAtPath:(NSString *)filePath withMaxDuration:(NSTimeInterval)interval;

/**
 *  停止录音
 */
- (void)stop;

@end
