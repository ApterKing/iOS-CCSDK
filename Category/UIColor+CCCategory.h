//
//  UIColor+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA(r , g, b, a) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a/255.]

@interface UIColor (CCCategory)

/**
 *  通过16进制解析RGB 默认Alpha：1.0
 *  @param rgbHex   16进制颜色  #ffaacc
 *
 *  @return
 */
+ (UIColor *)colorWithRGBHexString:(NSString *)rgbHex;

/**
 *  通过16进制颜色解析RGBA
 *
 *  @param rgbaHex 16进制颜色 #ffaaccff
 *
 *  @return 
 */
+ (UIColor *)colorWithRGBAHexString:(NSString *)rgbaHex;


// 将颜色转变为uiimage
+ (UIImage *)createImageWithColor:(UIColor *)color;

/**
 *  判定颜色是否相同
 *  @param otherColor
 *  @return
 */
- (BOOL)isEqualToColor:(UIColor *)otherColor;

@end
