//
//  CCHttpResponse.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpResponse.h"
#import "CCHttpClient.h"
#import "CCHttpResponseInfo.h"
#import "CCHttpResponseCallback.h"
#import "CCHttpRequest.h"
#import "CCHttpRequestCallback.h"
#import "CCSDKConstant.h"
#import "CCHttpError.h"
#import "CCHttpErrorType.h"
#import "CCNetUtil.h"

@implementation CCHttpResponse

- (instancetype)initWithHttpRequest:(CCHttpRequest *)request exception:(NSException *)exception
{
    if ((self = [super init])) {
        _httpRequest = request;
        _httpError = [[CCHttpError alloc] init];
        _httpError.statusMessage = HTTP_ERROR_LOCAL_REASON;
        _httpError.exception = exception;
        _httpError.requestURL = _httpRequest.clientParam.requestURL;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_conn) {
        [_conn cancel];
    }
    _conn = nil;
}

- (CCHttpResponseInfo *)getResponstInfo
{
    return _respInfo;
}

- (NSData *)readSync
{
    NSData *syncData = [NSURLConnection sendSynchronousRequest:[_httpRequest urlRequest] returningResponse:nil error:nil];
    return syncData;
}

- (void)readAsync:(CCHttpResponseCallback *)respCallback
{
    _respCallback = respCallback;
    if (_httpError.exception) {  //发送请求数据初始化错误
        if (respCallback) {
            if (respCallback.delegate && [respCallback.delegate respondsToSelector:@selector(onFail:data:userInfo:)]) {
                [respCallback.delegate onFail:_httpError data:[_httpError.statusMessage dataUsingEncoding:_httpRequest.clientParam.stringEncoding] userInfo:nil];
            }
            block_resp_fail respFail = [respCallback respFail];
            if (respFail) respFail(_httpError, [_httpError.exception.description dataUsingEncoding:_httpRequest.clientParam.stringEncoding], nil);
        }
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNetStatusChanged:) name:CC_NETSTATUS_CHANGED object:nil];
    _conn = [[NSURLConnection alloc] initWithRequest:_httpRequest.urlRequest delegate:self startImmediately:YES];
    while (!_isFinishLoading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

/**
 *  网络状态改变
 */
- (void)notifyNetStatusChanged:(NSNotification *)notification
{
    NSInteger status = [notification.object integerValue];
    if (status == net_status_none) {
        _httpError.type = HTTP_ERROR_NET;
        _httpError.statusCode = _respInfo ? _respInfo.statusCode : 0;
        _httpError.statusMessage = HTTP_ERROR_NET_REASON;
        [self sendFail:_httpError data:[_httpError.statusMessage dataUsingEncoding:_httpRequest.clientParam.stringEncoding]];
        _isFinishLoading = YES;
        if (_conn) [_conn cancel];
        _conn = nil;
    }
}

- (void)cancel
{
    _isFinishLoading = YES;
    _isCancel = YES;
    _httpError.type = HTTP_ERROR_INTERRUPT;
    _httpError.statusCode = _respInfo ? _respInfo.statusCode : 0;
    _httpError.statusMessage = HTTP_ERROR_INTERRUPT_REASON;
    [self sendFail:_httpError data:[HTTP_ERROR_INTERRUPT_REASON dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@ --- didFailWithError --- %@", NSStringFromClass(self.class), error.description);
    if (error.code == -1001 || error.code == -1009) {   //连接超时
        _httpError.type = HTTP_ERROR_TIMEOUT;
        _httpError.statusMessage = HTTP_ERROR_TIMEOUT_REASON;
    } else {  //发送响应错误
        _httpError.type = HTTP_ERROR_RESPONSE;
        _httpError.statusMessage = _respInfo ? _respInfo.statusMessage : HTTP_ERROR_RESPONSE_REASON;
    }
    [self sendFail:_httpError data:[_httpError.statusMessage dataUsingEncoding:_httpRequest.clientParam.stringEncoding]];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _respInfo = [[CCHttpResponseInfo alloc] initWithNSHTTPURLResponse:httpResponse];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (_isCancel) return;
    
    if (_httpRequest.reqCallback) {
        if (_httpRequest.reqCallback.delegate && [_httpRequest.reqCallback.delegate respondsToSelector:@selector(onProgress:current:userInfo:)]) {
            [_httpRequest.reqCallback.delegate onProgress:totalBytesExpectedToWrite current:bytesWritten userInfo:nil];
        }
        block_req_progress reqProgress = [_httpRequest.reqCallback reqProgress];
        if (reqProgress) reqProgress(totalBytesExpectedToWrite, bytesWritten, nil);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_isCancel) return;
    
    if (!_mutData) _mutData = [[NSMutableData alloc] initWithData:data];
    else [_mutData appendData:data];
    if (_respCallback) {
        if (_respCallback.delegate && [_respCallback.delegate respondsToSelector:@selector(onProgress:current:userInfo:)]) {
            [_respCallback.delegate onProgress:_respInfo.expectedContentLength current:_mutData.length userInfo:nil];
        }
        block_resp_progress respProgress = [_respCallback respProgress];
        if (respProgress) respProgress(_respInfo.expectedContentLength, _mutData.length, nil);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    __weak CCHttpClientParam *weakParam = _httpRequest.clientParam;
    if (_respCallback) {
        if (_respInfo.statusCode >= 400) {
            _httpError.type = HTTP_ERROR_RESPONSE;
            _httpError.statusCode = _respInfo.statusCode;
            _httpError.statusMessage = _respInfo.statusMessage;
            [self sendFail:_httpError data:_mutData ? _mutData : [_httpError.statusMessage dataUsingEncoding:weakParam.stringEncoding]];
            return;
        }
        if (_respCallback.delegate && [_respCallback.delegate respondsToSelector:@selector(onSuccess:data:userInfo:)]) {
            [_respCallback.delegate onSuccess:_respInfo data:_mutData userInfo:nil];
        }
        block_resp_success respSuccess = [_respCallback respSuccess];
        if (respSuccess) respSuccess(_respInfo, _mutData, nil);
        _isFinishLoading = YES;
        [_conn cancel];
        _conn = nil;
    }
}

/**
 *  响应失败
 */
- (void)sendFail:(CCHttpError *)error data:(NSData *)failData
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_httpRequest.reqCallback) {
        if (_httpRequest.reqCallback.delegate && [_httpRequest.reqCallback.delegate respondsToSelector:@selector(onFail:userInfo:)]) {
            [_httpRequest.reqCallback.delegate onFail:_httpError userInfo:nil];
        }
        block_req_fail reqFail = [_httpRequest.reqCallback reqFail];
        if (reqFail) reqFail(_httpError, nil);
    }
    
    if (_respCallback) {
        if (_respCallback.delegate && [_respCallback.delegate respondsToSelector:@selector(onFail:userInfo:)]) {
            [_respCallback.delegate onFail:_httpError data:_mutData userInfo:nil];
        }
        block_resp_fail respFail = [_respCallback respFail];
        if (respFail) respFail(_httpError, _mutData, nil);
    }
    _isFinishLoading = YES;
    [_conn cancel];
    _conn = nil;
}

@end
