//
//  CCSoundPool.h
//  CCSDK
//
//  Created by wangcong on 15-3-24.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    Sound_1,
    Sound_2,
    Sound_3,
    Sound_4,
    Sound_5
} CCSoundType;

@interface CCSoundPool : NSObject
{
    SystemSoundID soundID;
}

+ (instancetype)sharedInstance;

//-(id)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type;

//- (void)initForPlayingSoundEffectWith:(NSString *)filename;

- (void)playWithSoundType:(CCSoundType)type;

@end
