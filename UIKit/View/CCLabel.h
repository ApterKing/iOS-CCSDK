//
//  CCLabel.h
//  CCSDK
//
//  Created by wangcong on 15/10/29.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Constants for identifying link types we can detect
 */
typedef NS_ENUM(NSUInteger, CCLinkType)
{
    // @
    CCLinkTypeUserHandle,
    
    // #tag#
    CCLinkTypeHashtag,
    
    // http etc
    CCLinkTypeURL,
    
    // custom
    CCLinkTypeCustom,
};

typedef NS_OPTIONS(NSUInteger, CCLinkTypeOption)
{
    CCLinkTypeOptionNone = 0,
    
    CCLinkTypeOptionUserHandle = 1 << CCLinkTypeUserHandle,
    
    CCLinkTypeOptionHashtag = 1 << CCLinkTypeHashtag,
    
    CCLinkTypeOptionURL = 1 << CCLinkTypeURL,
    
    CCLinkTypeOptionAll = CCLinkTypeUserHandle|CCLinkTypeHashtag|CCLinkTypeURL,
    
    CCLinkTypeOptionCustom = 1 << CCLinkTypeCustom,
};


@class CCLabel;

typedef void (^CCLinkTapHandler)(CCLabel *label, NSString *string, NSRange range);

extern NSString * const CCLabelLinkTypeKey;
extern NSString * const CCLabelRangeKey;
extern NSString * const CCLabelLinkKey;

IB_DESIGNABLE
@interface CCLabel : UILabel <NSLayoutManagerDelegate>

/**
 * 是否自动检测 hashtags and usernames.
 */
@property (nonatomic, assign, getter = isAutomaticLinkDetectionEnabled) IBInspectable BOOL automaticLinkDetectionEnabled;

/**
 *  检测类型 如果检测类型为 CCLinkTypeOptionCustom, 则设置其他检测类型无效  default: CCLinkTypeOptionAll
 */
@property (nonatomic, assign) IBInspectable CCLinkTypeOption linkTypeOptions;

// 如果检测类型为custom 则 需要设置检测的正则表达式
@property (nonatomic, copy) IBInspectable NSString *regexPattern;

@property (nullable, nonatomic, strong) NSSet *ignoredKeywords;

// 选中后的背景颜色
@property (nullable, nonatomic, copy) IBInspectable UIColor *selectedLinkBackgroundColor;

/**
 * Flag sets if the sytem appearance for URLs should be used (underlined + blue color). Default value is NO.
 */
@property (nonatomic, assign) IBInspectable BOOL systemURLStyle;

@property (nullable, nonatomic, copy) CCLinkTapHandler userHandleLinkTapHandler;

@property (nullable, nonatomic, copy) CCLinkTapHandler hashtagLinkTapHandler;

@property (nullable, nonatomic, copy) CCLinkTapHandler urlLinkTapHandler;

@property (nullable, nonatomic, copy) CCLinkTapHandler customLinkTapHandler;

// 获取对应类型的 attributes
- (nullable NSDictionary*)attributesForLinkType:(CCLinkType)linkType;

// 设置对应类型的 attributes
- (void)setAttributes:(nullable NSDictionary*)attributes forLinkType:(CCLinkType)linkType;

/** ****************************************************************************************** **
 * @name Geometry
 ** ****************************************************************************************** **/

/**
 * Returns a dictionary of data about the link that it at the location. Returns nil if there is no link.
 *
 * A link dictionary contains the following keys:
 *
 * - **CCLabelLinkTypeKey**, a TDLinkType that identifies the type of link.
 * - **CCLabelRangeKey**, the range of the link within the label text.
 * - **CCLabelLinkKey**, the link text. This could be an URL, handle or hashtag depending on the linkType value.
 *
 * @param point The point in the coordinates of the label view.
 * @return A dictionary containing the link.
 */
- (nullable NSDictionary*)linkAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
