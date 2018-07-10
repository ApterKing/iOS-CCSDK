//
//  CCSpecialTextView.h
//  DYSport
//
//  Created by wangcong on 15/11/12.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CCSpecialTextView;

typedef void (^CCTextViewDeleteHandler)(CCSpecialTextView *textView, NSString *string, NSRange range);

@interface CCSpecialTextView : UIView


// 字符串长度限制
@property (nonatomic, assign) NSInteger limitLength;

// 提示信息
@property (nonatomic, strong, setter=setPlaceholder:) NSString *placeholder;

// UITextView
@property(nonatomic, strong, readonly) UITextView *textView;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, readwrite, strong) UIView *inputAccessoryView;

// 删除回调
@property(nonatomic, copy) CCTextViewDeleteHandler deleteHandler;

/**
 *  设置提示信息
 *  @param placeholder
 */
- (void)setPlaceholder:(NSString *)placeholder;

// 获取对应 字符串pattern 的 attributes
- (nullable NSDictionary *)attributesForPattern:(NSString *)pattern;

// 添加对应 字符串pattern 的 attributes
- (void)addAttributes:(nullable NSDictionary *)attributes forPattern:(NSString *)pattern;

// 删除对应的字符串
- (void)delAttributesForPattern:(NSString *)pattern;

@end

NS_ASSUME_NONNULL_END
