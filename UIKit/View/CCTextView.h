//
//  CCTextView.h
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTextView : UITextView

@property(nonatomic, assign) NSInteger limitLength;
@property(nonatomic, strong, setter=setPlaceholder:)NSString *placeholder;

- (void)setPlaceholder:(NSString *)placeholder;

- (void)textChanged:(NSNotification*)notification;

@end
