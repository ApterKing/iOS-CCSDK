//
//  CCMultiParam.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCMultiParam.h"

static NSString *PREFIX = @"--";
static NSString *SUBFIX = @"--";
static NSString *CR_LF = @"\r\n";

@implementation CCMultiParam

- (instancetype)init
{
    return [[[self class] alloc] initWithBoundary:@"gnocgnawybetaerc"];
}

- (instancetype)initWithBoundary:(NSString *)boundary
{
    if ((self = [super init])) {
        _dictString = [NSMutableDictionary dictionaryWithCapacity:0];
        _dictData = [NSMutableDictionary dictionaryWithCapacity:0];
        
        BOUNDARY = boundary;
        _boundary = BOUNDARY;
        BOUNDARY_LINE = [NSString stringWithFormat:@"%@%@", PREFIX, BOUNDARY];
        BOUNDARY_END = [NSString stringWithFormat:@"%@%@%@%@", PREFIX, BOUNDARY, SUBFIX, CR_LF];
    }
    return self;
}

- (void)dealloc
{
    _dictString = nil;
    _dictData = nil;
}

- (void)addString:(NSString *)value forKey:(NSString *)key
{
    [_dictString setObject:value forKey:key];
}

- (void)addData:(NSData *)value forKey:(NSString *)key
{
    [_dictData setObject:value forKey:key];
}

- (void)addInputStream:(NSInputStream *)value forKey:(NSString *)key
{
//    [_dict_is setObject:key forKey:is];
}

- (void)addBytes:(Byte *)value forKey:(NSString *)key
{
//    NSData *data = [[NSData alloc] initWithBytes:bts length:100];
//    [_dictData setObject:data forKey:data];
}

- (NSString *)contentType
{
    return _dictData.count == 1 ? @"application/x-www-form-urlencoded" : [NSString stringWithFormat:@"multipart/form-data;boundary=%@", BOUNDARY];
}

- (NSData *)toData:(NSStringEncoding)stringEncoding
{
    /* 首先对字符串进行处理 */
    int index = 0;
    NSMutableString *mutString = [NSMutableString stringWithCapacity:0];
    for (NSString *key in [_dictString allKeys]) {
        if (index > 0) [mutString appendString:@"&"];
        [mutString appendFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:stringEncoding], [[_dictString objectForKey:key] stringByAddingPercentEscapesUsingEncoding:stringEncoding]];
        index++;
    }
    if ([mutString length] != 0)
        [self addData:[mutString dataUsingEncoding:stringEncoding] forKey:BOUNDARY];
    
    /* 如果存在多数据，则需要采用HTTP的multipart */
    if (_dictData.count > 1) {
        NSMutableString *mut_res = [NSMutableString string];
        for (NSString *key in [_dictData allKeys]) {
            [mut_res appendFormat:@"%@%@", BOUNDARY_LINE, CR_LF];
            [mut_res appendFormat:@"Content-Disposition:form-data;name=\"%@\"%@", key, CR_LF];
            if ([key isEqualToString:BOUNDARY])
                [mut_res appendFormat:@"Content-Type:text/plain"];
            [mut_res appendFormat:@"%@", CR_LF];
            [mut_res appendFormat:@"%@", [[NSString alloc] initWithData:[_dictData objectForKey:key] encoding:stringEncoding]];
            [mut_res appendFormat:@"%@", CR_LF];
        }
        [mut_res appendFormat:@"%@", BOUNDARY_END];
        return [mut_res dataUsingEncoding:stringEncoding];
    } else {
        return [_dictData objectForKey:[_dictData allKeys][0]];
    }
}

@end
