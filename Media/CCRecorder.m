//
//  CCRecoder.m
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCRecorder.h"

@interface CCRecorder ()
{
    AVAudioRecorder *_audioRecorder;
    NSInteger _length;
    NSTimer *_timer;
}

@end

@implementation CCRecorder

- (void)startRecorderAtPath:(NSString *)filePath withMaxDuration:(NSTimeInterval)interval
{
    if (!filePath) return;
    NSURL * url = [NSURL fileURLWithPath:filePath];
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                 settings:[self getAudioRecorderSettingDict]
                                                    error:nil];
    _audioRecorder.delegate = self;
    [_audioRecorder pause];
    [_audioRecorder prepareToRecord];
    _audioRecorder.meteringEnabled = YES;
    _length = 0;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:nil];
    if (interval > 0) {
        [_audioRecorder prepareToRecord];
        [_audioRecorder recordForDuration:interval];
    } else {
        [_audioRecorder record];
    }
    
    [_audioRecorder updateMeters];
    [self startTimer];
}

/**
 *  获取录音相关配置
 *  @return NSDictionary
 */
- (NSDictionary *)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   //[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                   [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                   //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                   nil];
    return recordSetting;
}

/**
 *  开启定时器
 */
- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(updatePower)
                                            userInfo:nil
                                             repeats:YES];
}

/**
 *  更新录音时常
 */
- (void)updatePower
{
    if ([_audioRecorder isRecording]) {
        [_audioRecorder updateMeters];
        if (_delegate && [_delegate respondsToSelector:@selector(recorder:averagePowerChanged:)]) {
            [_delegate recorder:self averagePowerChanged:_audioRecorder.currentTime];
        }
    }
}

- (void)stop
{
    [_audioRecorder stop];
    [_timer invalidate];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (_delegate && [_delegate respondsToSelector:@selector(recorder:didFinishRecording:)]) {
        [_delegate recorder:self didFinishRecording:flag];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(recorder:didFinishRecording:)]) {
        [_delegate recorder:self didFinishRecording:NO];
    }
}

@end
