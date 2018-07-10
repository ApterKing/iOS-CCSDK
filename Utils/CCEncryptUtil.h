//
//  CCEncryptUtil.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEncryptUtil : NSObject

/**
 *  MD5加密
 *
 *  @param source
 *  @return
 */
+ (NSString *)MD5HexDigest:(NSString *)source;

/**
 *  BASE(HMAC_SHA1) 加密
 *
 *  @param secretKey
 *  @param text
 *  @return
 */
+ (NSString *)HMAC_SHA1:(NSString *)secretKey text:(NSString *)text;

@end
