//
//  CCEmoji.h
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCEmojiType) {
    CCEmojiTypePeople = 0,
    CCEmojiTypeFlower,
    CCEmojiTypeBell,
    CCEmojiTypeVehicle,
    CCEmojiTypeNumber,
};

@interface CCEmoji : NSObject

@property (assign, nonatomic) CCEmojiType type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *emojis;

+ (NSArray *)allEmojis;

@end
