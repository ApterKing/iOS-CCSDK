//
//  CCEmojiKeyboardPreview.m
//  CCSDK
//
//  Created by wangcong on 15/10/7.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCEmojiKeyboardPreview.h"
#import "CCSDKDefines.h"

@interface CCEmojiKeyboardPreview ()

@property(nonatomic, strong) UILabel *emojiLabel;

@end

@implementation CCEmojiKeyboardPreview

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 102.5, 100)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 102.5, 100)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ccsdk.bundle/images/keyboard_preview_bg%@.png", SCREEN_SCALE <= 2.0 ? @"@2x" : @"@3x"]]];
        [self addSubview:imageView];
        
        self.emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 102.5, 50)];
        self.emojiLabel.font = [UIFont systemFontOfSize:28];
        self.emojiLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.emojiLabel];
    }
    return self;
}

- (void)setEmojiString:(NSString *)emojiString
{
    self.emojiLabel.text = emojiString;
}

@end
