//
//  CCPBViewController.h
//  DYSport
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCPBVCShowType) {
    CCPBVCShowTypeModal = 0,            // modal
    CCPBVCShowTypePush,                 // push
    CCPBVCShowTypeTransition            // transition
};

@interface CCPBViewController : UIViewController

+ (void)showWithViewController:(UIViewController *)viewController photos:(NSArray *(^)())photoModelBlock type:(CCPBVCShowType)showType atIndex:(NSUInteger)index;

@end
