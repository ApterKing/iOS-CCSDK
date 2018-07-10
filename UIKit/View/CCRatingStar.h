//
//  CCRatingStar.h
//  CCSDK
//
//  Created by wangcong on 15/7/7.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCRatingStar;
@protocol CCRatingStarDelegate <NSObject>
@optional
- (void)ratingStar:(CCRatingStar *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;
@end

@interface CCRatingStar : UIView

@property(nonatomic, assign) CGFloat scorePercent;     //得分值，范围为0--1，默认为1
@property(nonatomic, assign) BOOL hasAnimation;        //是否允许动画，默认为YES
@property(nonatomic, assign) BOOL allowIncompleteStar; //评分时是否允许不是整星，默认为YES
@property(nonatomic, assign) BOOL allowUserChange;     // 是否允许用户操作控件，默认NO

@property(nonatomic, strong) UIImage *foregroundImage;
@property(nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, weak) id<CCRatingStarDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;

@end