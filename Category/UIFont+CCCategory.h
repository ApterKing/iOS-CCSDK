//
//  UIFont+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15/9/29.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (CCCategory)

/**
 *  设置字体大小 以iphone6 为基准
 *  @param size
 *  @return
 */
+ (UIFont *)appFontOfSize:(CGFloat)size;


/**
 *  设置粗体字体大小  以 iphone6 为基准
 *  @param size
 *  @return
 */
+ (UIFont *)boldAppFontOfSize:(CGFloat)size;

// 黑体light
+ (UIFont *)STHeiTiLightFontOfSize:(CGFloat)size;

// 黑体medium
+ (UIFont *)STHeiTIMediumFontOfSize:(CGFloat)size;

@end
