//
//  CCHttpResponseInfo.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  http响应成功后服务器返回的一些参数
 */
#import <Foundation/Foundation.h>

@interface CCHttpResponseInfo : NSObject

@property(nonatomic, assign, readonly) NSInteger statusCode;
@property(nonatomic, strong, readonly) NSString *statusMessage;
@property(nonatomic, strong, readonly) NSURL *URL;
@property(nonatomic, strong, readonly) NSString *MIMEType;
@property(nonatomic, assign, readonly) long long expectedContentLength;
@property(nonatomic, strong, readonly) NSString *textEncodingName;
@property(nonatomic, strong, readonly) NSString *suggestedFilename;
@property(nonatomic, strong, readonly) NSDictionary *allHeaderFields;
@property(nonatomic, strong, readonly) NSHTTPURLResponse *response;

- (instancetype)initWithNSHTTPURLResponse:(NSHTTPURLResponse *)response;

// 服务端返回的数据类型
- (NSString *)contentType;

// 数据编码
- (NSString *)contentCharset;

// 分段请求的数据大小
- (unsigned long long)contentRangeSize;

@end
