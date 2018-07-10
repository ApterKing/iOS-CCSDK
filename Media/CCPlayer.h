//
//  CCPlayer.h
//  CCSDK
//
//  Created by wangcong on 15-1-29.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

/**
 * @parm isPlaying 是否正在播放
 */
typedef void(^block_player)(BOOL isPlaying);

@interface CCPlayer : NSObject<AVAudioPlayerDelegate>
{
    block_player lastBlock;
    block_player currentBlock;
    
    AVAudioPlayer *_player;
}

+ (instancetype)sharedInstance;
- (void)playWithData:(NSData *)data block:(block_player)bPlayer;
- (void)stop;

@end
