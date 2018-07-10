//
//  CCTextField.h
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTextFieldPaddingWidth 5.0f
#define kTextFieldPaddingHeight 0.0f

@interface CCTextField : UITextField

@property(nonatomic, assign) NSInteger limitLength;

@property (nonatomic, assign) CGFloat paddingX;
@property (nonatomic, assign) CGFloat paddingY;

@end
