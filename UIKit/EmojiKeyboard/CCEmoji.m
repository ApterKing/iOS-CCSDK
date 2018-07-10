//
//  CCEmoji.m
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCEmoji.h"

@implementation CCEmoji

+ (NSDictionary *)emojis
{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/resource/emoji.json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}

+ (instancetype)peopleEmoji
{
    CCEmoji *emoji = [[CCEmoji alloc] init];
    emoji.title = @"人物";
    emoji.emojis = [self emojis][@"people"];
    emoji.type = CCEmojiTypePeople;
    return emoji;
}

+ (instancetype)flowerEmoji
{
    CCEmoji *emoji = [[CCEmoji alloc] init];
    emoji.title = @"自然";
    emoji.emojis = [self emojis][@"flower"];
    emoji.type = CCEmojiTypeFlower;
    return emoji;
}

+ (instancetype)bellEmoji
{
    CCEmoji *emoji = [[CCEmoji alloc] init];
    emoji.title = @"日常";
    emoji.emojis = [self emojis][@"bell"];
    emoji.type = CCEmojiTypeBell;
    return emoji;
}

+ (instancetype)vehicleEmoji
{
    CCEmoji *emoji = [CCEmoji new];
    emoji.title = @"建筑与交通";
    emoji.emojis = [self emojis][@"vehicle"];
    emoji.type = CCEmojiTypeVehicle;
    return emoji;
}

+ (instancetype)numberEmoji
{
    CCEmoji *emoji = [CCEmoji new];
    emoji.title = @"符号";
    emoji.emojis = [self emojis][@"number"];
    emoji.type = CCEmojiTypeNumber;
    return emoji;
}

+ (NSArray *)allEmojis
{
    return @[[self peopleEmoji], [self flowerEmoji], [self bellEmoji], [self vehicleEmoji], [self numberEmoji]];
}

@end
