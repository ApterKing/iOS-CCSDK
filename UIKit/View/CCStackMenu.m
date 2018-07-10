//
//  CCStackMenu.m
//  DYSport
//
//  Created by wangcong on 16/3/22.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import "CCStackMenu.h"
#import "UIColor+CCCategory.h"
#import "NSString+CCCategory.h"
#import "UIFont+CCCategory.h"
#import "CCSDKDefines.h"

const CGFloat kDefaultItemsInternMargin = 10.0f;
const CGFloat kDefaultItemsLabelMargin = 10.0f;

const CGFloat kDefaultAnimateDuration   = 0.9f;
const CGFloat kDefaultAnimateDelay      = 0.1f;
const CGFloat kDefaultSpringDamping     = 0.53f;
const CGFloat kDefaultSpringVelocity    = 0.65f;

#pragma mark - CCStackMenuItem
@interface CCStackMenuItem ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel  *titleLabel;

- (void)setFont:(UIFont *)font;

@end

@implementation CCStackMenuItem

+ (instancetype)stackMenuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage title:(NSString *)title titlePosition:(CCStackMenuItemTitlePosition)titlePosition {
    CCStackMenuItem *menuItem = [[CCStackMenuItem alloc] initWithFrame:CGRectZero image:image highlightedImage:highlightedImage title:title titlePosition:titlePosition];
    return menuItem;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage title:(NSString *)title titlePosition:(CCStackMenuItemTitlePosition)titlePosition {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.image = image;
        self.highlightedImage = highlightedImage;
        self.title = title;
        self.titlePosition = titlePosition;
        
        self.button = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.button setBackgroundImage:self.image forState:UIControlStateNormal];
        if (self.highlightedImage) {
            [self.button setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];
        }
        [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.layer.masksToBounds = YES;
        self.titleLabel.layer.cornerRadius = IS_IPHONE_5_OR_LESS ? 5 : 6;
        self.titleLabel.text = self.title;
        self.titleLabel.font = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 13.5 : 14];
        self.titleLabel.textColor = [UIColor colorWithRGBHexString:@"#9b9b9b"];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
    [self _restTitleLableFrame];
}

// 重置titleLabel frame
- (void)_restTitleLableFrame {
    CGSize titleSize = CGSizeMake(0, 0);
    if (self.title) {
        if (self.titlePosition == CCStackMenuItemTitlePositionUp || self.titlePosition == CCStackMenuItemTitlePositionDown) {
            self.titleLabel.numberOfLines = 0;
            titleSize = [self.title textSizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(20, APP_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
            self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - titleSize.width) / 2.0, self.titlePosition == CCStackMenuItemTitlePositionUp ? CGRectGetMinY(self.button.frame) - titleSize.height - kDefaultItemsInternMargin - kDefaultItemsLabelMargin : CGRectGetMaxY(self.button.frame) + kDefaultItemsInternMargin, titleSize.width + kDefaultItemsLabelMargin / 2.0, titleSize.height + kDefaultItemsLabelMargin);
        } else {
            self.titleLabel.numberOfLines = 1;
            titleSize = [self.title textSizeWithFont:[UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 13.5 : 14] constrainedToSize:CGSizeMake(APP_WIDTH, APP_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
            self.titleLabel.frame = CGRectMake(self.titlePosition == CCStackMenuItemTitlePositionLeft ? CGRectGetMinX(self.button.frame) - titleSize.width - kDefaultItemsInternMargin - kDefaultItemsLabelMargin : CGRectGetMaxX(self.button.frame) + kDefaultItemsInternMargin, (CGRectGetHeight(self.frame) - titleSize.height - kDefaultItemsLabelMargin / 2.0) / 2.0, titleSize.width + kDefaultItemsLabelMargin, titleSize.height + kDefaultItemsLabelMargin / 2.0);
        }
    }
}

- (void)setFont:(UIFont *)font {
    self.titleLabel.font = font;
    [self _restTitleLableFrame];
}

#pragma mark - setter
- (void)setImage:(UIImage *)image {
    _image = image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    _highlightedImage = highlightedImage;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setTitlePosition:(CCStackMenuItemTitlePosition)titlePosition {
    _titlePosition = titlePosition;
}

- (void)setDelegate:(id<CCStackMenuItemDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - 
- (void)buttonClicked:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackMenuItemDidTouched:)]) {
        [self.delegate stackMenuItemDidTouched:self];
    }
}

@end

#pragma mark - CCStackMenu
@interface CCStackMenu ()<CCStackMenuItemDelegate>
{
@private
    BOOL _isAnimating;
    CGRect _appendFrame;
}

@property (nonatomic, strong) NSArray   *menuItems;
@property (nonatomic, strong) UIControl *maskView;

@end

@implementation CCStackMenu

- (instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    if(self) {
        self.menuItems = [NSArray arrayWithArray:items];
        self.maskView = [[UIControl alloc] init];
        self.maskView.backgroundColor = [UIColor whiteColor];
        self.maskView.alpha = .5f;
        [self.maskView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        self.itemsSize = CGSizeMake(IS_IPHONE_5_OR_LESS ? 45 : 55, IS_IPHONE_5_OR_LESS ? 45 : 55);
        self.itemsSpacing = IS_IPHONE_5_OR_LESS ? 6 : 8;
        self.stackDirection = CCStackMenuDirectionUp;
    }
    return self;
}

- (void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
}

#pragma mark - public
- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    for (CCStackMenuItem *item in [self items]) {
        [item setFont:itemTitleFont];
    }
}

- (void)setItemTitleTextColor:(UIColor *)itemTitleTextColor {
    for (CCStackMenuItem *item in [self items]) {
        item.titleLabel.textColor = itemTitleTextColor;
    }
}

- (void)setItemTitleBackgroundColor:(UIColor *)itemTitleBackgroundColor {
    for (CCStackMenuItem *item in [self items]) {
        item.titleLabel.backgroundColor = itemTitleBackgroundColor;
    }
}

- (NSArray *)items {
    return self.menuItems;
}

- (void)showInView:(UIView *)superView append:(UIView *)appendView {
    if(_isAnimating || self.isShow) return;
    _isAnimating = YES;
    _appendFrame = appendView.frame;
    self.maskView.frame = superView.bounds;
    [superView addSubview:self.maskView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(stackMenuWillShow:)])
        [self.delegate stackMenuWillShow:self];
    for (int i = 0; i < self.menuItems.count; i++) {
        CCStackMenuItem *menuItem = self.menuItems[i];
        menuItem.frame = CGRectMake(CGRectGetMinX(_appendFrame) + (CGRectGetWidth(_appendFrame) - self.itemsSize.width) / 2.0, CGRectGetMinY(_appendFrame) + (CGRectGetHeight(_appendFrame) - self.itemsSize.height) / 2.0, self.itemsSize.width, self.itemsSize.height);
        menuItem.layer.cornerRadius = self.itemsSize.width / 2.0;
        menuItem.tag = i;
        menuItem.delegate = self;
        [superView addSubview:menuItem];
        menuItem.alpha = .0f;
        [UIView animateWithDuration:kDefaultAnimateDuration + kDefaultAnimateDelay animations:^{
            self.maskView.alpha = .8f;
            menuItem.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            menuItem.alpha = 1.0f;
        }];
        [UIView animateWithDuration:kDefaultAnimateDuration
                              delay:kDefaultAnimateDelay
             usingSpringWithDamping:kDefaultSpringDamping
              initialSpringVelocity:kDefaultSpringVelocity
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                if (self.stackDirection == CCStackMenuDirectionUp) {
                                    menuItem.frame = CGRectMake(CGRectGetMinX(menuItem.frame), CGRectGetMinY(_appendFrame) - (i + 1) * (self.itemsSize.height + self.itemsSpacing), CGRectGetWidth(menuItem.frame), CGRectGetHeight(menuItem.frame));
                                } else if (self.stackDirection == CCStackMenuDirectionDown) {
                                    menuItem.frame = CGRectMake(CGRectGetMinX(menuItem.frame), CGRectGetMaxY(_appendFrame) + self.itemsSpacing + i * (self.itemsSize.height + self.itemsSpacing), CGRectGetWidth(menuItem.frame), CGRectGetHeight(menuItem.frame));
                                } else if (self.stackDirection == CCStackMenuDirectionLeft) {
                                    menuItem.frame = CGRectMake(CGRectGetMinX(_appendFrame) - (i + 1) * (self.itemsSize.width + self.itemsSpacing), CGRectGetMinY(menuItem.frame), CGRectGetWidth(menuItem.frame), CGRectGetHeight(menuItem.frame));
                                } else {
                                    menuItem.frame = CGRectMake(CGRectGetMaxX(_appendFrame) + self.itemsSpacing + i * (self.itemsSize.width + self.itemsSpacing), CGRectGetMinY(menuItem.frame), CGRectGetWidth(menuItem.frame), CGRectGetHeight(menuItem.frame));
                                }
                                
                            }
                         completion:^(BOOL finished) {
                             _isAnimating = NO;
                             if(self.delegate && [self.delegate respondsToSelector:@selector(stackMenuDidShow:)])
                                 [self.delegate stackMenuDidShow:self];
                         }];
    }
    self.isShow = YES;
}

- (void)dismiss {
    if(_isAnimating || !self.isShow) return;
    _isAnimating = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(stackMenuWillDismiss:)])
        [self.delegate stackMenuWillDismiss:self];
    for (int i = 0; i < self.menuItems.count; i++) {
        CCStackMenuItem *menuItem = self.menuItems[i];
        [UIView animateWithDuration:.35 animations:^{
            menuItem.frame = CGRectMake(CGRectGetMinX(_appendFrame) + (CGRectGetWidth(_appendFrame) - self.itemsSize.width) / 2.0, CGRectGetMinY(_appendFrame) + (CGRectGetHeight(_appendFrame) - self.itemsSize.height) / 2.0, self.itemsSize.width, self.itemsSize.height);
            self.maskView.alpha = .0f;
            menuItem.transform = CGAffineTransformMakeScale(.5f, .5f);
            menuItem.alpha = .0f;
        } completion:^(BOOL finished) {
            _isAnimating = NO;
            menuItem.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            [self.maskView removeFromSuperview];
            [menuItem removeFromSuperview];
            if(self.delegate && [self.delegate respondsToSelector:@selector(stackMenuDidDismiss:)])
                [self.delegate stackMenuDidDismiss:self];
        }];
    }
    self.isShow = NO;
}

#pragma mark - CCStackMenuItemDelegate
- (void)stackMenuItemDidTouched:(CCStackMenuItem *)menuItem {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stackMenu:didTouchedItem:)]) {
        [self.delegate stackMenu:self didTouchedItem:menuItem];
    }
}

@end
