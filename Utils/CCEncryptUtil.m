//
//  CCEncryptUtil.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCEncryptUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation CCEncryptUtil

+ (NSString *)MD5HexDigest:(NSString *)source
{
    if ((NSNull *)source == [NSNull null]) return @"";
    if (!source || (source && [source isEqualToString:@""])) return @"";
    const char *utf8Chars = [source UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(utf8Chars, (unsigned)strlen(utf8Chars), result);
    NSMutableString *mutableStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [mutableStr appendFormat:@"%02X", result[i]];
    }
    return mutableStr;
}

+ (NSString *)HMAC_SHA1:(NSString *)secretKey text:(NSString *)text
{
    const char *cKey  = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [HMAC base64Encoding];
    return hash;
}

@end
