//
//  CCEmojiKeyboardCell.m
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCEmojiKeyboardCell.h"
#import "UIView+CCCategory.h"

@interface CCEmojiKeyboardCell ()

@property(nonatomic, strong) UIImageView *emojiImgv;

@end

@implementation CCEmojiKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.emojiImgv = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.emojiImgv.backgroundColor = [UIColor clearColor];
        self.emojiImgv.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.emojiImgv];
        
        @weakify(self);
        [[RACObserve(self, emojiString) ignore:nil] subscribeNext:^(id x) {
            @strongify(self);
            [self _configWithEmoji:x];
        }];
    }
    return self;
}

- (void)_configWithEmoji:(NSString *)emoji
{
    NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:kCCEmojiFontSize]};
    CGSize size = [emoji sizeWithAttributes:att];
    CGFloat scale = [UIScreen mainScreen].scale;
    self.contentView.size = CGSizeMake(size.width, size.height);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = CGRectMake(0, 0, size.width*scale, size.height*scale);
        UIGraphicsBeginImageContext(rect.size);
        [emoji drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kCCEmojiFontSize * scale]}];
        UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.emojiImgv.image = image;
        });
    });
}

@end
