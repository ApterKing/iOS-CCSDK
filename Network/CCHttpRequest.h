//
//  CCHttpRequest.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  Created by wangcong on 14-11-12. <br>
 *  Http请求，支持设置请求回调
 */
#import <Foundation/Foundation.h>

@class CCHttpClientParam, CCHttpResponse, CCHttpRequestCallback;
@interface CCHttpRequest : NSObject
@property(nonatomic, strong, readonly) NSMutableURLRequest *urlRequest;
@property(nonatomic, strong, readonly) CCHttpRequestCallback *reqCallback;
@property(nonatomic, strong, readonly) CCHttpClientParam *clientParam;


- (instancetype)initWithClientParam:(CCHttpClientParam *)clientParam;

- (CCHttpResponse *)execute:(CCHttpRequestCallback *)callback;

@end
