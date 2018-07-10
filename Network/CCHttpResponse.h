//
//  CCHttpResponse.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  网络响应，不直接初始化，通过HttpRequest的execute构造，支持同步异步方式响应网络
 */
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>


@class CCHttpResponseInfo, CCHttpRequest, CCHttpRequestCallback, CCHttpResponseCallback, CCHttpError;
@interface CCHttpResponse : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
@private
    
    BOOL _isCancel;                        //是否取消读取
    
    CCHttpError *_httpError;                //请求错误
    CCHttpRequest *_httpRequest;
    
    CCHttpResponseInfo *_respInfo;          //响应消息
    CCHttpResponseCallback *_respCallback;
    
    //请求成功相关
    NSURLConnection *_conn;                //请求连接
    
    NSMutableData *_mutData;               //返回的数据
    
    BOOL _isFinishLoading;                 //是否加载完成
    
}

/**
 *  初始化CCHttpResponse
 *  @param request
 *  @param exception
 *  @return
 */
- (instancetype)initWithHttpRequest:(CCHttpRequest *)request exception:(NSException *)exception;

/**
 *  获取响应相关信息，只有异步请求成功才会返回CCHttpResponseInfo，否则为nil
 *  @return
 */
- (CCHttpResponseInfo *)getResponstInfo;

/**
 *  同步将数据读取网络数据
 */
- (NSData *)readSync;

/**
 *  异步读取数据并作出相应的响应
 *  @param respCallback
 */
- (void)readAsync:(CCHttpResponseCallback *)respCallback;

/**
 *  取消读取数据
 */
- (void)cancel;

@end
