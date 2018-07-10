//
//  CCEmojiInputView.h
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCEmojiKeyboard.h"

@interface CCEmojiInputView : UIView

@property(nonatomic, assign) BOOL fitWhenKeyboardShowOrHide;
@property(nonatomic, copy) NSString *placeHolder;
@property(nonatomic, copy, setter=setKeyboardSend:) block_keyboard_send keyboardSend;

// 设置点击了发送的后续操作
- (void)setKeyboardSend:(block_keyboard_send)keyboardSend;

// 清空输入的字符
- (void)clearText;

+ (instancetype)emojiInputView;

@end
