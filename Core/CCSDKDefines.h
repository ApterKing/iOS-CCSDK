//
//  CCSDKDefines.h
//  CCSDK
//
//  Created by wangcong on 15/6/10.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#ifndef DynamicMargin_CCSDKDefines_h
#define DynamicMargin_CCSDKDefines_h

/* -------------- 部分宏定义 ------------ */
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 667.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 736.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define SCREEN_SCALE        [[UIScreen mainScreen] scale]                                       //屏幕缩放比例
#define SCREEN_SIZE         [[UIScreen mainScreen] bounds].size                                 //屏幕Size
#define STATUSBAR_HEIGHT    [UIApplication         sharedApplication].statusBarFrame.size.height//status_bar高度
#define APP_SIZE            [UIScreen              mainScreen].applicationFrame.size            //应用Size
#define APP_WIDTH           [UIScreen              mainScreen].applicationFrame.size.width      //应用宽度
#define APP_HEIGHT          [UIScreen              mainScreen].applicationFrame.size.height     //应用高度

// 版本号
#define SYSTEM_VERSION      \
        [[[UIDevice currentDevice] systemVersion] floatValue]

// 版本号是否小于version
#define SYSTEM_VERSION_LESS_THAN(version)       \
        ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)

// 拉伸图片
#define STRETCH_IMAGE(image, top, left, bottom, right)      \
        (SYSTEM_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:left topCapHeight:top] : [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch])

#define STRETCH_IMAGE_EDGEINSET(image, edgeInsets)      \
        (SYSTEM_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])

#endif

/* -----------  定义是否打印调试日志  ------ */
#define DEBUGABLE

#ifdef DEBUGABLE
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif
