//
//  CCMultiParam.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/*
 * http 请求多数据格式，支持NSString, NSData, NSInputstream, byte[]
 */
#import <Foundation/Foundation.h>

@interface CCMultiParam : NSObject
{
@private
    NSString *BOUNDARY;
    NSString *BOUNDARY_LINE;
    NSString *BOUNDARY_END;
    
    NSMutableDictionary *_dictString;    //封装字符串
    NSMutableDictionary *_dictData;   //封装数据
}
@property(nonatomic, strong, readonly)NSString *boundary;

- (instancetype)initWithBoundary:(NSString *)boundary;

/**
 *  添加字符串数据,每添加一个字段都将作为参数拼接如：key1=value1&key2=value2...
 *  @param value 值
 *  @param key   键
 */
- (void)addString:(NSString *)value forKey:(NSString *)key;

/**
 *  添加NSData
 *  @param value
 *  @param key
 */
- (void)addData:(NSData *)value forKey:(NSString *)key;

/**
 *  添加NSInputStream数据
 *  @param value
 *  @param key
 */
- (void)addInputStream:(NSInputStream *)value forKey:(NSString *)key;

/**
 *  添加Byte[]数据
 *  @param value
 *  @param key
 */
- (void)addBytes:(Byte *)value forKey:(NSString *)key;

/**
 *  根据添加数据获取到HTTP头 Content-Type，默认为：application/x-www-form-urlencoded
 *
 *  @return NSString
 */
- (NSString *)contentType;

/**
 *  根据将所添加的数据转换为NSData
 *  @param stringEncoding NSStringEncoding
 *  @return
 */
- (NSData *)toData:(NSStringEncoding)stringEncoding;

@end
