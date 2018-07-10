//
//  CCEmojiKeyboard.h
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

// 发送block
typedef void(^block_keyboard_send)(NSString *text);

@interface CCEmojiKeyboard : UIView<UIInputViewAudioFeedback>

@property(nonatomic, strong) id<UITextInput> textView;
@property(nonatomic, copy) block_keyboard_send keyboardSend;

+ (instancetype)emojiKeyboard;

@end
