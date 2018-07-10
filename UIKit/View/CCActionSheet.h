//
//  CCActionSheet.h
//  CCSDK
//
//  Created by wangcong on 16/1/25.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCActionSheet;
typedef void(^didSelectedItemAtIndex)( CCActionSheet * _Nonnull actionSheet, NSInteger index);

@interface CCActionSheet : NSObject

@property (nonatomic, assign) NSInteger tag;// 标识

@property (nonatomic, assign         ) CGFloat titleHeight;// title高度  default: 38  42
@property (nonatomic, strong, nullable) UIFont  *titleFont;// default: 13 14
@property (nonatomic, strong, nullable) UIColor *titleTextColor;// default: #9b9b9b

@property (nonatomic, assign         ) CGFloat itemHeight;// 每个条目高度 default: 40  44
@property (nonatomic, strong, nullable) UIFont  *itemFont;// default: 16.5 17.5
@property (nonatomic, strong, nullable) UIColor *itemTextColor;// default: #4a4a4a

- (nonnull instancetype)initWithTitle:(nullable NSString *)title delegate:(nullable didSelectedItemAtIndex)selected cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

- (void)setTitle:(NSString * _Nonnull)title;
- (void)addButtonTitle:( NSString * _Nonnull)title atIndex:(NSInteger)index;
- (void)addButtontitles:(NSArray * _Nonnull)titles atIndex:(NSIndexSet * _Nonnull)indexSet;

- (void)show;

@end
