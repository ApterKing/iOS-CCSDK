//
//  UIViewController+CCCategory.m
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "UIViewController+CCCategory.h"
#import <objc/runtime.h>

static const void *MBProgressHUDKey = &MBProgressHUDKey;

@implementation UIViewController (CCCategory)


@end

@implementation UIViewController (HUD)

- (void)showHudWithHint:(NSString *)hint
{
    MBProgressHUD *hud = objc_getAssociatedObject(self, MBProgressHUDKey);
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        objc_setAssociatedObject(self, MBProgressHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    hud.labelText = hint;
    [hud show:YES];
}

- (void)showHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint delay:(NSTimeInterval)timeInterval {
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:timeInterval];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset
{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset delay:(NSTimeInterval)timeInterval {
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:timeInterval];
}

- (void)hideHud
{
    MBProgressHUD *hud = objc_getAssociatedObject(self, MBProgressHUDKey);
    if (hud) {
        [hud hide:YES];
    }
}

- (void)showErrorHudWithHint:(NSString *)hint delay:(NSTimeInterval)timeInterval
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController != nil ? self.navigationController.view : self.view];
    [self.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_hud_error@2x.png"]]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = hint;
    [HUD show:YES];
    [HUD hide:YES afterDelay:timeInterval];
}

- (void)showSuccessHudWithHint:(NSString *)hint delay:(NSTimeInterval)timeInterval
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController != nil ? self.navigationController.view : self.view];
    [self.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_hud_success@2x.png"]]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = hint;
    [HUD show:YES];
    [HUD hide:YES afterDelay:timeInterval];
}
@end

@implementation UIViewController (DismissKeyboard)
- (void)setupForDismissKeyboard
{
    __block UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] init];
    
    @weakify(self);
    [gestureRecognizer.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.view addGestureRecognizer:gestureRecognizer];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.view removeGestureRecognizer:gestureRecognizer];
    }];
}

@end