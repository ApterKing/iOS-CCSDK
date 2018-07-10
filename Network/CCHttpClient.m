//
//  CCHttpClient.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpClient.h"
#import "CCNetUtil.h"
#import "CCHttpError.h"
#import "CCHttpRequest.h"
#import "CCHttpRequest.h"
#import "CCHttpResponse.h"
#import "CCHttpMethod.h"
#import "CCHttpRequestCallback.h"
#import "CCHttpResponseCallback.h"
#import <objc/runtime.h>

static NSString *kCCHttpClientOperationUserInfo = @"kCCHttpclientOperationUserInfo";

@implementation CCHttpClientOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@   dealloc", NSStringFromClass(self.class));
    _request = nil;
    _response = nil;
}

- (void)main
{
    if (!self.cancelled) {
        [self doResponse];
    }
}

- (void)cancel
{
    if (self.isCancelled || self.isFinished) return;
    if (_response) [_response cancel];
//    [super cancel];
}

- (void)doResponse
{
    
    __block CCHttpClientParam *weakParam = _clientParam;
    __block NSDictionary *weakUserInfo = objc_getAssociatedObject(self, &kCCHttpClientOperationUserInfo);
    
    // 首先检测网络是否连接，未连接则直接返回
    if (![CCNetUtil connectedToNet]) {
        CCHttpError *httpError = [[CCHttpError alloc] init];
        httpError.type = HTTP_ERROR_NET;
        httpError.statusCode = 0;
        httpError.statusMessage = HTTP_ERROR_NET_REASON;
        httpError.requestURL = weakParam.requestURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 上传失败
            if (weakParam.requestCallback && weakParam.requestCallback.delegate && [weakParam.requestCallback.delegate respondsToSelector:@selector(onFail:userInfo:)]) {
                
                [weakParam.requestCallback.delegate onFail:httpError userInfo:weakUserInfo];
                
                block_req_fail reqFail = [weakParam.requestCallback reqFail];
                if (reqFail) reqFail(httpError, weakUserInfo);
            }
            
            
            // 请求失败
            if (!weakParam.responseCallback) return;
            if (weakParam.responseCallback.delegate && [weakParam.responseCallback.delegate respondsToSelector:@selector(onFail:data:userInfo:)]) {
                [weakParam.responseCallback.delegate onFail:httpError data:[httpError.statusMessage dataUsingEncoding:weakParam.stringEncoding] userInfo:weakUserInfo];
            }
            block_resp_fail respFail = [weakParam.responseCallback respFail];
            if (respFail) respFail(httpError, [httpError.statusMessage dataUsingEncoding:weakParam.stringEncoding], weakUserInfo);
        });
        return;
    }
    
    _request = [[CCHttpRequest alloc] initWithClientParam:_clientParam];
    
    CCHttpRequestCallback *innerReqCallback = [[CCHttpRequestCallback alloc] initWithFail:^(CCHttpError *error, NSDictionary *userInfo) {
        
        // 上传失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakParam.requestCallback) return;
            if (weakParam.requestCallback.delegate && [weakParam.requestCallback.delegate respondsToSelector:@selector(onFail:userInfo:)]) {
                [weakParam.requestCallback.delegate onFail:error userInfo:weakUserInfo];
            }
            
            block_req_fail reqFail = [weakParam.requestCallback reqFail];
            if (reqFail) reqFail(error, weakUserInfo);
        });
    } progress:^(NSInteger totalLength, NSInteger currentLength, NSDictionary *userInfo) {
        
        // 上传进度
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakParam.requestCallback) return;
            if (weakParam.requestCallback.delegate && [weakParam.requestCallback.delegate respondsToSelector:@selector(onProgress:current:userInfo:)]) {
                [weakParam.requestCallback.delegate onProgress:totalLength current:currentLength userInfo:weakUserInfo];
            }
            block_req_progress reqProgress = [weakParam.requestCallback reqProgress];
            if (reqProgress) reqProgress(totalLength, currentLength, weakUserInfo);
        });
    }];
    
    _response = [_request execute:innerReqCallback];
    
    CCHttpResponseCallback *innerRespCallback = [[CCHttpResponseCallback alloc] initWithSuccess:^(CCHttpResponseInfo *info, NSData *successData, NSDictionary *userInfo) {
        
        // 请求成功
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakParam.responseCallback) return;
            if (weakParam.responseCallback.delegate && [weakParam.responseCallback.delegate respondsToSelector:@selector(onSuccess:data:userInfo:)]) {
                [weakParam.responseCallback.delegate onSuccess:info data:successData userInfo:weakUserInfo];
            }
            block_resp_success respSuccess = [weakParam.responseCallback respSuccess];
            if (respSuccess) respSuccess(info, successData, weakUserInfo);
        });
    } fail:^(CCHttpError *error, NSData *errorData, NSDictionary *userInfo) {
        
        // 请求失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakParam.responseCallback) return;
            if (weakParam.responseCallback.delegate && [weakParam.responseCallback.delegate respondsToSelector:@selector(onFail:data:userInfo:)]) {
                [weakParam.responseCallback.delegate onFail:error data:errorData userInfo:weakUserInfo];
            }
            block_resp_fail respFail = [weakParam.responseCallback respFail];
            if (respFail) respFail(error, errorData, weakUserInfo);
        });
    } progress:^(unsigned long long totalLength, NSInteger currentLength, NSDictionary *userInfo) {
        
        // 请求进度
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakParam.responseCallback) return;
            if (weakParam.responseCallback.delegate && [weakParam.responseCallback.delegate respondsToSelector:@selector(onProgress:current:userInfo:)]) {
                [weakParam.responseCallback.delegate onProgress:totalLength current:currentLength userInfo:weakUserInfo];
            }
            block_resp_progress respProgress = [weakParam.responseCallback respProgress];
            if (respProgress) respProgress(totalLength, currentLength, userInfo);
        });
    }];
    // 开始读取数据
    [_response readAsync:innerRespCallback];
}

@end

@implementation CCHttpClientParam

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _timeInterval = DEFAULT_TIME_INTERVAL;
        _stringEncoding = DEFAULT_STRING_ENCODING;
        _userAgent = @"goncgnaw_yb_etaerc_kdscc";
        
        _cookies = [NSMutableDictionary dictionary];
        _requestHeaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    _cookies = nil;
    _requestHeaders = nil;
}

@end

@implementation CCHttpClient
{
@private
    CCHttpClientParam *_clientParam;
    
    NSOperationQueue *_operationQueue;
}

+ (instancetype)newClient
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        _clientParam = [[CCHttpClientParam alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@   dealloc", NSStringFromClass(self.class));
    _clientParam = nil;
    _operationQueue = nil;
}

- (instancetype)setCachePolicy:(NSURLRequestCachePolicy)policy
{
    _clientParam.cachePolicy = policy;
    return self;
}

- (instancetype)setTimeInterval:(NSTimeInterval)timeInterval
{
    _clientParam.timeInterval = timeInterval;
    return self;
}

- (instancetype)setStringEncoding:(NSStringEncoding)stringEncoding
{
    _clientParam.stringEncoding = stringEncoding;
    return self;
}

- (instancetype)setUserAgent:(NSString *)userAgent
{
    _clientParam.userAgent = userAgent;
    [_clientParam.requestHeaders setObject:userAgent forKey:@"User-Agent"];
    return self;
}

- (instancetype)setCookies:(NSDictionary *)cookies
{
    _clientParam.cookies = [NSMutableDictionary dictionaryWithDictionary:cookies];
    return self;
}

- (instancetype)setRequestHeaders:(NSDictionary *)requestHeaders
{
    _clientParam.requestHeaders = [NSMutableDictionary dictionaryWithDictionary:requestHeaders];
    return self;
}

- (instancetype)setHost:(NSString *)host
{
    _clientParam.host = host;
    [_clientParam.requestHeaders setObject:host forKey:@"Host"];
    return self;
}

- (instancetype)setPort:(NSInteger)port
{
    _clientParam.port = port;
    return self;
}

- (instancetype)setRange:(NSString *)range
{
    _clientParam.range = range;
    [_clientParam.requestHeaders setObject:range forKey:@"Range"];
    return self;
}

- (instancetype)setHeader:(NSString *)header forField:(NSString *)field
{
    [_clientParam.requestHeaders setObject:header forKey:field];
    return self;
}

#pragma mark - private
/**
 *  同步方法处理各种方式请求
 *
 *  @param url        url
 *  @param method     请求方法
 *  @param multiParam 多数据参数
 *  @param kvParam    键值对
 *  @return
 */
- (NSData *)requestWithUrl:(NSString *)url method:(NSString *)method multiParam:(CCMultiParam *)multiParam kvParam:(NSDictionary *)kvParam
{
    _clientParam.requestURL = url;
    _clientParam.requesMethod = method;
    _clientParam.multiParam = multiParam;
    _clientParam.kvParam = kvParam;
    
//    __weak typeof(_clientParam) weakParam = _clientParam;
    CCHttpRequest *httpRequest = [[CCHttpRequest alloc] initWithClientParam:_clientParam];
    CCHttpResponse *httpResponse = [httpRequest execute:nil];
    return [httpResponse readSync];
}

/**
 *  异步方法处理各种http请求
 *
 *  @param url
 *  @param method
 *  @param multiParam
 *  @param kvParam
 *  @param requestCallback
 *  @param responseCallback
 *  @param userInfo
 */
- (CCHttpClientOperation *)requestWithUrl:(NSString *)url method:(NSString *)method multiParam:(CCMultiParam *)multiParam kvParam:(NSDictionary *)kvParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    _clientParam.requestURL = url;
    _clientParam.requesMethod = method;
    _clientParam.multiParam = multiParam;
    _clientParam.kvParam = kvParam;
    _clientParam.requestCallback = requestCallback;
    _clientParam.responseCallback = responseCallback;
    
    CCHttpClientOperation *httpOperation = [[CCHttpClientOperation alloc] init];
    objc_setAssociatedObject(httpOperation, &kCCHttpClientOperationUserInfo, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    httpOperation.clientParam = _clientParam;
    [_operationQueue addOperation:httpOperation];
    return httpOperation;
}

@end

@implementation CCHttpClient (CCHttpClientSync)

- (NSData *)getSync:(NSString *)url param:(NSDictionary *)kvParam
{
    return [self requestWithUrl:url method:CCHTTP_GET multiParam:nil kvParam:kvParam];
}

- (NSData *)headSync:(NSString *)url param:(NSDictionary *)kvParam
{
    return [self requestWithUrl:url method:CCHTTP_HEAD multiParam:nil kvParam:kvParam];
}

- (NSData *)postSync:(NSString *)url param:(CCMultiParam *)multiParam
{
    return [self requestWithUrl:url method:CCHTTP_POST multiParam:multiParam kvParam:nil];
}

- (NSData *)putSync:(NSString *)url param:(CCMultiParam *)multiParam
{
    return [self requestWithUrl:url method:CCHTTP_PUT multiParam:multiParam kvParam:nil];
}

- (NSData *)deleteSync:(NSString *)url param:(CCMultiParam *)multiParam
{
    return [self requestWithUrl:url method:CCHTTP_DELETE multiParam:multiParam kvParam:nil];
}

@end

@implementation CCHttpClient (CCHttpClientAsync)

- (CCHttpClientOperation *)getAsync:(NSString *)url param:(NSDictionary *)kvParam responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_GET multiParam:nil kvParam:kvParam userInfo:nil requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)headAsync:(NSString *)url param:(NSDictionary *)kvParam responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_HEAD multiParam:nil kvParam:kvParam userInfo:nil requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_POST multiParam:multiParam kvParam:nil userInfo:nil requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_POST multiParam:multiParam kvParam:nil userInfo:nil requestCallback:requestCallback responseCallback:responseCallback];
}

- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_PUT multiParam:multiParam kvParam:nil userInfo:nil requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_PUT multiParam:multiParam kvParam:nil userInfo:nil requestCallback:requestCallback responseCallback:responseCallback];
}

- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_DELETE multiParam:multiParam kvParam:nil userInfo:nil requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_DELETE multiParam:multiParam kvParam:nil userInfo:nil requestCallback:requestCallback responseCallback:responseCallback];
}

@end

@implementation CCHttpClient (CCHttpClientAsync_UserInfo)

- (CCHttpClientOperation *)getAsync:(NSString *)url param:(NSDictionary *)kvParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_GET multiParam:nil kvParam:kvParam userInfo:userInfo requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)headAsync:(NSString *)url param:(NSDictionary *)kvParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_HEAD multiParam:nil kvParam:kvParam userInfo:userInfo requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_POST multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_POST multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:requestCallback responseCallback:responseCallback];
}

- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_PUT multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_PUT multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:requestCallback responseCallback:responseCallback];
}

- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_DELETE multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:nil responseCallback:responseCallback];
}

- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback
{
    return [self requestWithUrl:url method:CCHTTP_DELETE multiParam:multiParam kvParam:nil userInfo:userInfo requestCallback:requestCallback responseCallback:responseCallback];
}

@end
