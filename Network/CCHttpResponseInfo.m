//
//  CCHttpResponseInfo.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpResponseInfo.h"

@implementation CCHttpResponseInfo

- (instancetype)initWithNSHTTPURLResponse:(NSHTTPURLResponse *)response
{
    self = [super init];
    if (self) {
        _response = response;
        _allHeaderFields = response.allHeaderFields;
        _statusCode = response.statusCode;
        _statusMessage = [NSHTTPURLResponse localizedStringForStatusCode:_statusCode];
        _URL = response.URL;
        _MIMEType = response.MIMEType;
        _expectedContentLength = response.expectedContentLength;
        _textEncodingName = response.textEncodingName;
        _suggestedFilename = response.suggestedFilename;
    }
    return self;
}

- (NSString *)firstHeaderValue:(NSString *)headerField
{
    NSArray *values = [_allHeaderFields objectForKey:headerField];
    return (!values || (values && values.count == 0)) ? nil : values[0];
}

- (NSString *)contentType
{
    NSString *content_type = [self firstHeaderValue:@"Content-Type"];
    if (!content_type) return nil;
    NSRange range = [content_type rangeOfString:@";"];
    return range.location == NSNotFound ? content_type : [content_type componentsSeparatedByString:@";"][0];
}

- (NSString *)contentCharset
{
    NSString *content_type = [self firstHeaderValue:@"Content-Type"];
    if (!content_type) return nil;
    NSRange range = [content_type rangeOfString:@";"];
    return range.location == NSNotFound ? @"utf-8" : [content_type componentsSeparatedByString:@","][1];
}

- (unsigned long long)contentRangeSize
{
    NSString *content_range = [self firstHeaderValue:@"Content-Range"];
    return content_range ? [content_range longLongValue] : _expectedContentLength;
}

@end
