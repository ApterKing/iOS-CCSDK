//
//  CCHttpRequest.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpRequest.h"
#import "CCHttpClient.h"
#import "CCHttpResponse.h"
#import "CCHttpRequestCallback.h"
#import "CCHttpMethod.h"
#import "CCMultiParam.h"

@implementation CCHttpRequest

- (instancetype)initWithClientParam:(CCHttpClientParam *)clientParam
{
    self = [super init];
    if (self) {
        _clientParam = clientParam;
    }
    return self;
}

- (void)dealloc
{
    _urlRequest = nil;
    _reqCallback = nil;
}

- (CCHttpResponse *)execute:(CCHttpRequestCallback *)callback
{
    _reqCallback = callback;
    @try {
        NSMutableString *mutBaseUrl = [NSMutableString stringWithFormat:@"%@", _clientParam.requestURL];
        
        // get、head 请求方式
        if ([_clientParam.requesMethod isEqualToString:CCHTTP_GET] || [_clientParam.requesMethod isEqualToString:CCHTTP_HEAD]) {
            if (_clientParam.kvParam && _clientParam.kvParam.count != 0) {
                if (![mutBaseUrl hasSuffix:@"?"]) [mutBaseUrl appendString:@"?"];
                int index = 0;
                NSArray *tmpKeys = [_clientParam.kvParam allKeys];
                for (NSString *key in tmpKeys) {
                    if (index != 0) [mutBaseUrl appendString:@"&"];
                    NSString *encodeKey = [key stringByAddingPercentEscapesUsingEncoding:_clientParam.stringEncoding];
                    NSString *encodeValue = [[_clientParam.kvParam objectForKey:key] stringByAddingPercentEscapesUsingEncoding:_clientParam.stringEncoding];
                    [mutBaseUrl appendFormat:@"%@=%@", encodeKey, encodeValue];
                    index ++;
                }
            }
        }
        
        /* post/put/delete 请求方式 */
        NSData *multiData = nil;
        if (_clientParam.multiParam && ([_clientParam.requesMethod isEqualToString:CCHTTP_POST] || [_clientParam.requesMethod isEqualToString:CCHTTP_PUT] || [_clientParam.requesMethod isEqualToString:CCHTTP_DELETE])) {
            @try {
                multiData = [NSData dataWithData:[_clientParam.multiParam toData:_clientParam.stringEncoding]];
            }
            @catch (NSException *exception) {
                return [[CCHttpResponse alloc] initWithHttpRequest:self exception:exception];
            }
            @finally {
            }
        }
        
        //初始化请求，并且设置相应的头
        _urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:mutBaseUrl]
                                              cachePolicy:_clientParam.cachePolicy
                                          timeoutInterval:_clientParam.timeInterval];
        [_urlRequest setHTTPMethod:_clientParam.requesMethod];
        [_urlRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        NSLog(@"url---%@", mutBaseUrl);
        
        //如果是 post/put/delete访问则传送数据
        if (multiData) {
            NSLog(@"数据 --- %@", [[NSString alloc] initWithData:multiData encoding:_clientParam.stringEncoding]);
            [_urlRequest setHTTPBody:multiData];
            [_urlRequest setValue:[NSString stringWithFormat:@"%lul", (unsigned long)multiData.length] forHTTPHeaderField:@"Content-Length"];
            [_urlRequest setValue:[_clientParam.multiParam contentType] forHTTPHeaderField:@"Content-Type"];
        }
        
        //设置封装的http 头
        NSDictionary *reqHeaders = _clientParam.requestHeaders;
        for (NSString *key in [reqHeaders allKeys]) {
            [_urlRequest setValue:[reqHeaders objectForKey:key] forHTTPHeaderField:key];
        }
        return [[CCHttpResponse alloc] initWithHttpRequest:self exception:nil];
    }
    @catch (NSException *exception) {
        return [[CCHttpResponse alloc] initWithHttpRequest:self exception:exception];
    }
    @finally {
        
    }
}


@end
