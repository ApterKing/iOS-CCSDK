//
//  CCBadgeView.m
//  CCSDK
//
//  Created by wangcong on 15/11/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCBadgeView.h"
#import "NSString+CCCategory.h"

@interface CCBadgeView ()

@property(nonatomic, strong) UIImageView *badgeImageView;
@property(nonatomic, strong) UILabel *badgeLabel;

@property(nonatomic, assign) CGRect orginalFrame;

@end

@implementation CCBadgeView

- (instancetype)init
{
    return [[[self class] alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        [self _initSubviews];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if (self.badgeLabel.text == nil || self.badgeLabel.text.length == 0) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    // 计算大小
    CGSize size = [self.badgeLabel.text textSizeWithFont:_badgeTextFont constrainedToSize:CGSizeMake(APP_WIDTH, APP_WIDTH) lineBreakMode:NSLineBreakByCharWrapping];
    self.size = CGSizeMake(size.width < size.height ? size.height + 2 : size.width + 2, size.height + 2);
    
    self.badgeImageView.frame = self.bounds;
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0;
    self.badgeLabel.frame = self.badgeImageView.bounds;
}

- (void)_initSubviews
{
    _badgeColor = [UIColor redColor];
    _badgeTextColor = [UIColor whiteColor];
    _badgeTextFont = [UIFont systemFontOfSize:10];
    
    self.badgeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0;
    self.layer.masksToBounds = YES;
    self.badgeImageView.backgroundColor = _badgeColor;
    [self addSubview:_badgeImageView];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:self.badgeImageView.bounds];
    self.badgeLabel.backgroundColor = [UIColor clearColor];
    self.badgeLabel.textColor = _badgeTextColor;
    self.badgeLabel.font = _badgeTextFont;
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    [_badgeImageView addSubview:_badgeLabel];
}

#pragma mark - public
- (void)setBadgeImage:(UIImage *)badgeImage
{
    _badgeImage = [badgeImage stretchwithTop:0 left:10 bottom:0 right:10];
    self.badgeImageView.image = _badgeImage;
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    _badgeTextColor = badgeTextColor;
    self.badgeLabel.textColor = badgeTextColor;
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont
{
    _badgeTextFont = badgeTextFont;
    self.badgeLabel.font = _badgeTextFont;
    [self setNeedsLayout];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    NSString *badgeText = _badgeNumber <= 0 ? nil : (_badgeNumber > 99 ? @"99+" : [NSString stringWithFormat:@"%lu", _badgeNumber]);
    self.badgeLabel.text = badgeText;
    [self setNeedsLayout];
}

@end
