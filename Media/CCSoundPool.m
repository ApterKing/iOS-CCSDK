//
//  CCSoundPool.m
//  CCSDK
//
//  Created by wangcong on 15-3-24.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCSoundPool.h"

static CCSoundPool *instance;
@implementation CCSoundPool
{
    NSMutableDictionary *_soundDict;
}

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
        _soundDict = [NSMutableDictionary dictionaryWithCapacity:2];
        SystemSoundID soundID1 = [self initSystemSoundEffectWith:@"no1.mp3"];
        if (soundID1 != -1) {
            [_soundDict setObject:[NSNumber numberWithInt:soundID1] forKey:[NSNumber numberWithInt:Sound_1]];
        }
        
        SystemSoundID soundID2 = [self initSystemSoundEffectWith:@"no2.mp3"];
        if (soundID2 != -1) {
            [_soundDict setObject:[NSNumber numberWithInt:soundID2] forKey:[NSNumber numberWithInt:Sound_2]];
        }
        
        SystemSoundID soundID3 = [self initSystemSoundEffectWith:@"no3.mp3"];
        if (soundID3 != -1) {
            [_soundDict setObject:[NSNumber numberWithInt:soundID3] forKey:[NSNumber numberWithInt:Sound_3]];
        }
        
        SystemSoundID soundID4 = [self initSystemSoundEffectWith:@"no4.mp3"];
        if (soundID4 != -1) {
            [_soundDict setObject:[NSNumber numberWithInt:soundID4] forKey:[NSNumber numberWithInt:Sound_4]];
        }
        
        SystemSoundID soundID5 = [self initSystemSoundEffectWith:@"no5.mp3"];
        if (soundID5 != -1) {
            [_soundDict setObject:[NSNumber numberWithInt:soundID5] forKey:[NSNumber numberWithInt:Sound_5]];
        }
    }
    return self;
}
                                  
- (id)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type
{
    self = [super init];
    if (self) {
        NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",resourceName,type];
        if(path){
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path]), &theSoundID);
            if (error == kAudioServicesNoError){
                soundID = theSoundID;
            }else {
                NSLog(@"创建音频文件失败");
            }
        }
    }
    return self;
}

- (SystemSoundID)initSystemSoundEffectWith:(NSString *)filename
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    if (fileURL != nil) {
        SystemSoundID theSoundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
        if (error == kAudioServicesNoError){
            return theSoundID;
        } else {
            NSLog(@"创建音频文件失败");
        }
    }
    return -1;
}

- (void)playWithSoundType:(CCSoundType)type
{
    AudioServicesPlaySystemSound([[_soundDict objectForKey:[NSNumber numberWithInt:type]] intValue]);
}

- (void)dealloc
{
    NSArray *keys = [_soundDict allKeys];
    for (NSNumber *number in keys) {
        AudioServicesDisposeSystemSoundID([[_soundDict objectForKey:number] intValue]);
    }
}

@end
