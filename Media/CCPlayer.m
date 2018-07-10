//
//  CCPlayer.m
//  CCSDK
//
//  Created by wangcong on 15-1-29.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPlayer.h"
#import <AVFoundation/AVFoundation.h>

static CCPlayer *instance = nil;
@implementation CCPlayer

+ (instancetype)sharedInstance
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[[self class] alloc] init];
        }
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//播放音乐
- (void)playWithData:(NSData *)data block:(block_player)bPlayer
{
    if (!lastBlock) lastBlock = bPlayer;
    currentBlock = bPlayer;
    
    if (_player) [_player stop];
    if (currentBlock != lastBlock) lastBlock(NO);
    
    lastBlock = currentBlock;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    _player.delegate = self;
    if (_player && [_player prepareToPlay] && [_player play]) {
        if (currentBlock) currentBlock(YES);
    } else {
        if (currentBlock) currentBlock(NO);
    }
}

- (void)stop
{
    if (_player && _player.isPlaying) [_player stop];
    if (currentBlock) currentBlock(NO);
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag && currentBlock) currentBlock(NO);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (currentBlock) currentBlock(NO);
}

@end
