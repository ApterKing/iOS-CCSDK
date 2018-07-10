//
//  UIFont+CCCategory.m
//  CCSDK
//
//  Created by wangcong on 15/9/29.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "UIFont+CCCategory.h"

@implementation UIFont (CCCategory)

+ (UIFont *)appFontOfSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)boldAppFontOfSize:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)STHeiTiLightFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"STHeitiSC-Light" size:size];
}

+ (UIFont *)STHeiTIMediumFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"STHeitiSC-Medium" size:size];
}

@end
