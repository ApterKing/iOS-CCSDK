//
//  CCJsonUtil.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCJsonUtil.h"

@implementation CCJsonUtil

+ (NSString *)jsonEnclose:(NSObject *)obj encoding:(NSStringEncoding)encoding error:(NSError *)error
{
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json_str = [[NSString alloc] initWithData:json_data encoding:encoding];
    json_str = [[[json_str stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return json_str;
}

+ (id)jsonParse:(NSData *)data error:(NSError *)error
{
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
}

@end
