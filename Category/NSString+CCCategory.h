//
//  NSString+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15-6-11.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CCCategory)

/**
 *  判定字符串是否为中文
 *
 *  @return
 */
- (BOOL)isChinese;

/**
 *  将字符串转换为Base64
 *
 *  @param encoding
 *  @return
 */
- (NSString *)encodeBase64WithEncoding:(NSStringEncoding)encoding;

/**
 *  将字符串转换为Base64
 *
 *  @param input
 *  @param encoding
 *  @return
 */
+ (NSString *)encodeBase64String:(NSString *)input encoding:(NSStringEncoding)encoding;

/**
 *  解码Base64字符串
 *
 *  @param encoding
 *  @return
 */
- (NSString *)decodeBase64WithEncoding:(NSStringEncoding)encoding;

/**
 *  解码Base64字符串
 *
 *  @param input
 *  @param encoding
 *  @return
 */
+ (NSString*)decodeBase64String:(NSString *)input encoding:(NSStringEncoding)encoding;

/**
 *  将NSData转换为base64字符串
 *
 *  @param data
 *  @param encoding
 *  @return
 */
+ (NSString*)encodeBase64Data:(NSData *)data encoding:(NSStringEncoding)encoding;

/**
 *  将NSData解码
 *
 *  @param data
 *  @param encoding
 *  @return
 */
+ (NSString*)decodeBase64Data:(NSData *)data encoding:(NSStringEncoding)encoding;

/**
 *  计算字符串的cgsize
 *
 *  @param font          字体大小
 *  @param size          约束size
 *  @param lineBreakMode
 *  @return
 */
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  url编码解决中文字符
 *
 *  @return
 */
- (NSString *)stringByEscapingForUrlArgument;


- (NSString *)stringByUnescapingFromUrlArgument;

@end

@interface NSString (STRegex)

///////////////////////////// 正则表达式相关  ///////////////////////////////

/** 邮箱验证 */
- (BOOL)isValidEmail;

/** 手机号码验证 */
- (BOOL)isValidPhoneNum;

/** 车牌号验证 */
- (BOOL)isValidCarNo;

/** 网址验证 */
- (BOOL)isValidUrl;

/** 邮政编码 */
- (BOOL)isValidPostalcode;

/** 纯汉字 */
- (BOOL)isValidChinese;



/**
 @brief     是否符合IP格式，xxx.xxx.xxx.xxx
 */
- (BOOL)isValidIP;

/** 身份证验证 refer to http://blog.csdn.net/afyzgh/article/details/16965107*/
//- (BOOL)isValidIdCardNum;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     containDigtal   包含数字
 @param     containLetter   包含字母
 @param     containOtherCharacter   其他字符
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/** 去掉两端空格和换行符 */
- (NSString *)stringByTrimmingBlank;

/** 去掉html格式 */
- (NSString *)removeHtmlFormat;

/** 工商税号 */
- (BOOL)isValidTaxNo;

/** 中文转换成拼音 */
+ (NSString *)chineseTransformToPing:(NSString *)chinese;

@end
