//
//  CCPBLoadingView.h
//  CCSDK
//
//  Created by wangcong on 15/9/30.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCPBLoadingView : UIView

@property(nonatomic, assign, setter=setProgress:) CGFloat progress;     // 0.0 ~ 1.0

@property(nonatomic, strong) UIColor *trackTintColor;                   // 进度条背景色
@property(nonatomic, strong) UIColor *progressTintColor;                // 进度条颜色
@property(nonatomic, strong) UIColor *textColor;                        // 中心文字颜色 默认：白色
@property(nonatomic, assign) CGFloat lineWidth;                         // 绘制progress宽度  default: 2

- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
