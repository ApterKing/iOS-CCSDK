//
//  CCHttpClient.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  HTTP访问客户端(支持同步和异步请求)，初始化客户端发起http请求; 编码方式、cookie、userAgent等
 *  <br>支持（POST/GET/PUT/HEAD/DELETE）方式访问服务器端，支持请求设置缓存，默认支持gzip压缩，
 *  支持多文件上传，支持取消操作，支持下载进度，支持断点续传功能
 */
#import <Foundation/Foundation.h>

#ifndef cc_http_client_macro
#define cc_http_client_macro

// 默认请求时长 ( 30s )
#define DEFAULT_TIME_INTERVAL 30

// 默认字符编码 ( utf-8 )
#define DEFAULT_STRING_ENCODING NSUTF8StringEncoding

// 默认缓存策略 ( NSURLRequestUserProtocolCachePolicy )
#define DEFAULT_CACHE_POLICY NSURLRequestUseProtocolCachePolicy

#endif

@class CCMultiParam, CCHttpRequestCallback, CCHttpResponseCallback;
@interface CCHttpClientParam : NSObject

@property(nonatomic, assign) NSURLRequestCachePolicy cachePolicy;                //缓存策略
@property(nonatomic, assign) NSTimeInterval timeInterval;                        //请求时长
@property(nonatomic, assign) NSStringEncoding stringEncoding;                    //编码
@property(nonatomic, copy) NSString *userAgent;                                  //UserAgent
@property(nonatomic, strong) NSMutableDictionary *cookies;                       //cookie
@property(nonatomic, strong) NSMutableDictionary *requestHeaders;                //请求头
@property(nonatomic, copy) NSString *host;
@property(nonatomic, assign) NSInteger port;
@property(nonatomic, copy) NSString *range;
@property(nonatomic, copy) NSString *requesMethod;                               //请求方法
@property(nonatomic, copy) NSString *requestURL;                                 //请求连接
@property(nonatomic, strong) CCMultiParam *multiParam;                           // post、put、delete 请求参数
@property(nonatomic, strong) NSDictionary *kvParam;                              // get 、head 请求参数
@property(nonatomic, retain) CCHttpRequestCallback *requestCallback;             // 请求回调
@property(nonatomic, retain) CCHttpResponseCallback *responseCallback;           // 响应回调

@end

@class CCMultiParam;
@interface CCHttpClient : NSObject

+ (instancetype)newClient;

- (instancetype)setCachePolicy:(NSURLRequestCachePolicy)policy;
- (instancetype)setTimeInterval:(NSTimeInterval)timeInterval;
- (instancetype)setStringEncoding:(NSStringEncoding)stringEncoding;
- (instancetype)setUserAgent:(NSString *)userAgent;
- (instancetype)setCookies:(NSDictionary *)cookies;
- (instancetype)setRequestHeaders:(NSDictionary *)requestHeaders;
- (instancetype)setHost:(NSString *)host;
- (instancetype)setPort:(NSInteger)port;

/**
 *  设置请求数据范围
 *  格式如：
 * <br>从某个位置开始到结尾: bytes=1024-
 * <br>从某个位置到某个位置: bytes=1024-2048
 * <br>同时指定几个range: bytes=512-1024,2048-4096
 *  @param range NSString
 */
- (instancetype)setRange:(NSString *)range;

/**
 *  设置请求头
 *  @param header 头域值
 *  @param field  头名称
 */
- (instancetype)setHeader:(NSString *)header forField:(NSString *)field;

@end

@interface CCHttpClient (CCHttpClientSync)

/**
 *  get同步请求方式
 *  @param url      base_url
 *  @param kvParam  请求参数：NSDictionary
 *  @return NSData
 */
- (NSData *)getSync:(NSString *)url param:(NSDictionary *)kvParam;

/**
 *  head同步请求方式
 *  @param baseUri base_url
 *  @param kvParam  请求参数：NSDictionary
 *  @return NSData
 */
- (NSData *)headSync:(NSString *)url param:(NSDictionary *)kvParam;

/**
 *  post同步请求方式
 *  @param baseUri base_url
 *  @param multiParam  请求参数：CCMultiParam
 *  @return NSData
 */
- (NSData *)postSync:(NSString *)url param:(CCMultiParam *)multiParam;

/**
 *  put同步请求方式
 *  @param baseUri base_url
 *  @param multiParam  请求参数：CCMultiParam
 *  @return NSData
 */
- (NSData *)putSync:(NSString *)url param:(CCMultiParam *)multiParam;

/**
 *  delete同步请求方式
 *  @param baseUri base_url
 *  @param multiParam  请求参数：CCMultiParam
 *  @return NSData
 */
- (NSData *)deleteSync:(NSString *)url param:(CCMultiParam *)multiParam;

@end

/**
 *  用于CCHttpClientAsync处理
 */
@class CCHttpRequest, CCHttpResponse;
@interface CCHttpClientOperation : NSOperation
{
    CCHttpRequest *_request;
    
    CCHttpResponse *_response;
}

@property(retain, nonatomic) CCHttpClientParam *clientParam;

// 处理请求
- (void)doResponse;

@end

@class CCHttpRequestCallback, CCHttpResponseCallback;
@interface CCHttpClient (CCHttpClientAsync)

/**
 *  get请求方式
 *  @param url              请求链接
 *  @param kvParam          请求键值对参数
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)getAsync:(NSString *)url param:(NSDictionary *)kvParam responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  head请求方式
 *  @param url              请求链接
 *  @param kvParam          请求键值对参数
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)headAsync:(NSString *)url param:(NSDictionary *)kvParam responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  post异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  post异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param requestCallback  请求回调
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  put异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  put异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param requestCallback  请求回调
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  delete异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  delete异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param requestCallback  请求回调
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

@end

@interface CCHttpClient (CCHttpClientAsync_UserInfo)

/**
 *  get请求方式
 *  @param url              请求链接
 *  @param kvParam          请求键值对参数
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)getAsync:(NSString *)url param:(NSDictionary *)kvParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  head请求方式
 *  @param url              请求链接
 *  @param kvParam          请求键值对参数
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)headAsync:(NSString *)url param:(NSDictionary *)kvParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  post异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  post异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param requestCallback  请求回调
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)postAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  put异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  put异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param userInfo         用户需要返回的数据
 *  @param requestCallback  请求回调
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)putAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  delete异步请求方式 （无需知道请求进度）
 *  @param url          请求链接
 *  @param multiParam   多数据参数
 *  @param userInfo         用户需要返回的数据
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo responseCallback:(CCHttpResponseCallback *)responseCallback;

/**
 *  delete异步请求方式 （需知道请求进度）
 *  @param url              请求链接
 *  @param multiParam       多数据参数
 *  @param userInfo         用户需要返回的数据
 *  @param requestCallback  请求回调
 *  @param responseCallback 响应回调
 *
 *  @return
 */
- (CCHttpClientOperation *)deleteAsync:(NSString *)url param:(CCMultiParam *)multiParam userInfo:(NSDictionary *)userInfo requestCallback:(CCHttpRequestCallback *)requestCallback responseCallback:(CCHttpResponseCallback *)responseCallback;

@end
