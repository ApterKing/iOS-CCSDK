//
//  CCStepSlider.h
//  CCSDK
//
//  Created by wangcong on 15-1-23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  滑竿，实现分步滑动滑竿
 */
@interface CCStepSlider : UIControl

@property(nonatomic, retain) UIColor *sliderColor;
@property(nonatomic, assign) int selectedIndex;

- (instancetype)initWithFrame:(CGRect) frame titles:(NSArray *) titles;

/**
 *  设置字体颜色
 *
 *  @param color
 */
- (void)setTitleColor:(UIColor *)color;

/**
 *  设置字体font
 *  @param font
 */
- (void)setTitleFont:(UIFont *)font;

/**
 *  设置滑块颜色
 *  @param color
 */
- (void)setThumbColor:(UIColor *)color;

/**
 *  设置滑块大小
 *
 *  @param radius 
 */
- (void)setThumbRadius:(CGFloat)radius;


@end
