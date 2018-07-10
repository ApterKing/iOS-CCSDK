//
//  CCSegmentedControl.h
//  CCSDK
//
//  Created by wangcong on 16/1/12.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCSegmentedControl : UIControl

// 左右maskView颜色 default : #4a4a4a
@property (nonatomic, strong, nonnull) UIColor *gradientColor;

// 左右颜色所占宽度 default : CGRectGetHeight(self.frame)
@property (nonatomic, assign) CGFloat   gradientOffset;

@property (nonatomic, assign) CGFloat   gradientPercentage;

// 选中第几个选项 default : 0
@property (nonatomic, assign) NSInteger selectedIndex;

// 默认item间隔宽度 default : auto
@property (nonatomic, assign) CGFloat edgeMargin;

// 标题 textColor: #a0a0a0 ; highlightedTextColor: #fb5f46
@property (nonatomic, strong, nonnull) UIColor *textColor;
@property (nonatomic, strong, nonnull) UIColor *highlightedTextColor;

// 标题字体
@property (nonatomic, strong, nonnull) UIFont *font;

// 选中文字缩放大小
@property (nonatomic, strong, nullable) UIFont *scaleSelectedItemFont;

// 选中回调
@property (nonatomic, strong, nullable) void(^didSelectedIndex) ( CCSegmentedControl * _Nonnull segmentedControl, NSInteger index);

// items must can be NSString
- (_Nonnull instancetype)initWithFrame:(CGRect)frame items:(nonnull NSArray *)items;

@end
