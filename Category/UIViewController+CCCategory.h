//
//  UIViewController+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (CCCategory)

@end

@interface UIViewController (HUD)

- (void)showHudWithHint:(NSString *)hint;

- (void)hideHud;

- (void)showHint:(NSString *)hint;

- (void)showHint:(NSString *)hint delay:(NSTimeInterval)timeInterval;

// 从默认(showHint:)显示的位置再往上(下)yOffset
- (void)showHint:(NSString *)hint yOffset:(float)yOffset;

- (void)showHint:(NSString *)hint yOffset:(float)yOffset delay:(NSTimeInterval)timeInterval;

- (void)showErrorHudWithHint:(NSString *)hint delay:(NSTimeInterval)timeInterval;

- (void)showSuccessHudWithHint:(NSString *)hint delay:(NSTimeInterval)timeInterval;

@end

@interface UIViewController (DismissKeyboard)

- (void)setupForDismissKeyboard;

@end
