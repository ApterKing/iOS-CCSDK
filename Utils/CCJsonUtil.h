//
//  CCJsonUtil.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCJsonUtil : NSObject

/**
 *  将对象封装为json对象
 *  @param obj   将要封装的对象
 *  @param error 错误描述
 *  @return 返回json字符串
 */
+ (NSString *)jsonEnclose:(NSObject *)obj encoding:(NSStringEncoding)encoding error:(NSError *)error;

/**
 *  解析json对象
 *  @param data  将要解析的数据
 *  @param error 错误描述
 *  @return JSONObject
 */
+ (id)jsonParse:(NSData *)data error:(NSError *)error;

@end
