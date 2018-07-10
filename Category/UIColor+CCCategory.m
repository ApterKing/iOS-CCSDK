//
//  UIColor+CCCategory.m
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "UIColor+CCCategory.h"

@implementation UIColor (CCCategory)

+ (UIColor *)colorWithRGBHexString:(NSString *)rgbHex
{
    return rgbHex.length < 7 ? [UIColor whiteColor] : [UIColor colorWithRGBAHexString:[NSString stringWithFormat:@"%@ff", rgbHex]];
}

+ (UIColor *)colorWithRGBAHexString:(NSString *)rgbaHex
{
    if (rgbaHex.length < 9) {
        return [UIColor whiteColor];
    }
    unsigned int red_, green_, blue_, alpha_;
    NSRange exceptionRange;
    exceptionRange.length = 2;
    
    //red
    exceptionRange.location = 1;
    [[NSScanner scannerWithString:[rgbaHex substringWithRange:exceptionRange]] scanHexInt:&red_];
    
    //green
    exceptionRange.location = 3;
    [[NSScanner scannerWithString:[rgbaHex substringWithRange:exceptionRange]] scanHexInt:&green_];
    
    //blue
    exceptionRange.location = 5;
    [[NSScanner scannerWithString:[rgbaHex substringWithRange:exceptionRange]] scanHexInt:&blue_];
    
    //blue
    exceptionRange.location = 7;
    [[NSScanner scannerWithString:[rgbaHex substringWithRange:exceptionRange]] scanHexInt:&alpha_];
    
    UIColor *resultColor = RGBA(red_, green_, blue_, alpha_);
    return resultColor;
}

+ (UIImage *)createImageWithColor:(UIColor *)color{
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return theImage;
}

- (BOOL)isEqualToColor:(UIColor *)otherColor
{
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate( colorSpaceRGB, components );
            
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        } else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}
@end
