//
//  CCKeyboardHelper.h
//  CCSDK
//
//  Created by wangcong on 15-1-23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  用于 UITextField 、UITextView，UISearchBar设置键盘监听，一行代码解决键盘弹出控件被隐藏的问题
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define IS_IOS7_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

typedef void(^CCKeyboardHelperDoneBlock)(id);
typedef void(^CCKeyboardHelperValidationError)(id,NSString*);

typedef NS_ENUM(NSInteger, CCKeyboardHelperDismissType) {
    CCKeyboardHelperDismissTypeNone = 0,
    CCKeyboardHelperDismissTypeCleanMaskView,
    CCKeyboardHelperDismissTypeTapGusture
};

typedef NS_ENUM(NSInteger, CCValidationType) {
    CCValidationTypeNone = 0,       //no limit
    CCValidationTypeNoWhiteSpace,   //no whitespace character
    CCValidationTypeNumberInt,      //int number only
    CCValidationTypePhone,          //phone only
    CCValidationTypeAlphabetAndNumber,     //alphabet and number
};


@interface CCKeyboardHelper : NSObject

+ (instancetype)sharedInstance;
- (void)dismissCCKeyboardHelper;

//keyboard
- (void)setupCCKeyboardHelperForView:(UIView *)view withDismissType:(CCKeyboardHelperDismissType)dismissType;
- (void)setupCCKeyboardHelperForView:(UIView *)view withDismissType:(CCKeyboardHelperDismissType)dismissType doneBlock:(CCKeyboardHelperDoneBlock)doneBlock;


//validation
- (void)setupValidationType:(CCValidationType)type forInputField:(UIView *)inputField;
- (void)limitTextLength:(NSInteger)length forInputField:(UIView *)inputField;

@end


@interface NSString (CCKeyboardHelper)
- (NSString *)trimmedString ;
/*
 email: @"^[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$"
 id card: @"^([1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3})|([1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X))$"
 phone: @"^1\\d{10}$"
 */
- (BOOL)isTextValidated:(NSString *)validation;

@end

#define KeybordHelper [CCKeyboardHelper sharedInstance]