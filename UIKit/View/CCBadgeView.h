//
//  CCBadgeView.h
//  DYSport
//
//  Created by wangcong on 15/11/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBadgeView : UIView

// 背景图片 (default: nil)
@property(nonatomic, strong) UIImage *badgeImage;

// 背景颜色 (default: red)
@property(nonatomic, strong) UIColor *badgeColor;

// 字体颜色 (default: white)
@property(nonatomic, strong) UIColor *badgeTextColor;

// 字体大小 (default: systemFontOfSize:10)
@property(nonatomic, strong) UIFont *badgeTextFont;

// 设置显示数量
@property(nonatomic, assign) NSInteger badgeNumber;

@end
