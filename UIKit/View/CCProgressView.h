//
//  CCProgressView.h
//  CCSDK
//
//  Created by wangcong on 15/8/25.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCProgressViewStyle) {
    CCProgressViewStyleCircle,                                          // 圆形进度条
    CCProgressViewStyleBar,                                             // 条形进度条
    CCProgressViewStyleDefault = CCProgressViewStyleCircle,
};

@interface CCProgressView : UIView

@property(nonatomic, assign, setter=setProgress:) CGFloat progress;     // 0.0 ~ 1.0

@property (nonatomic, assign) CCProgressViewStyle progressViewStyle;// 进度条style
@property (nonatomic, strong) UIColor             *trackTintColor;// 进度条背景色
@property (nonatomic, strong) UIColor             *progressTintColor;// 进度条颜色
@property (nonatomic, strong) UIColor             *progressFullTintColor;// 进度完成时progressTint的颜色
@property (nonatomic, assign) CGFloat             lineWidth;// 绘制progress宽度  default: 10
@property (nonatomic, copy  ) NSString            *lineCap;// default: kCALineCapButt
@property (nonatomic, copy  ) NSString            *lineJoin;// default: kCALineCapButt

// CCProgressViewStyleCircle 有效
@property (nonatomic, strong) UIColor             *fillColor;// 中心颜色
@property (nonatomic, assign) BOOL                clockwise;// 是否是顺时针 default: YES
@property (nonatomic, assign) CGFloat             startAngle;// 进度条开始angle, default: -M_PI/2.0
@property (nonatomic, assign) BOOL                showProgress;// 是否在中心显示百分比进度，默认 NO

- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
