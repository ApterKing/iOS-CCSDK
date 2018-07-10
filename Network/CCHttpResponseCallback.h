//
//  CCHttpResponseCallback.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  Http响应回调，用于响应成功、失败、进度
 */
#import <Foundation/Foundation.h>

@class CCHttpError, CCHttpResponseInfo;

// CCHttpResponseCallback 代理
@protocol CCHttpResponseCallbackDelegate <NSObject>

// 请求成功
- (void)onSuccess:(CCHttpResponseInfo *)info data:(NSData *)successData userInfo:(NSDictionary *)userInfo;

// 请求失败
- (void)onFail:(CCHttpError *)error data:(NSData *)failData userInfo:(NSDictionary *)userInfo;

// 请求进度
- (void)onProgress:(unsigned long long)totalLength current:(NSInteger)currentLength userInfo:(NSDictionary *)userInfo;

@end

//请求成功 block
typedef void(^block_resp_success)(CCHttpResponseInfo *info, NSData *successData, NSDictionary *userInfo);

// 请求失败 block
typedef void(^block_resp_fail)(CCHttpError *error, NSData *errorData, NSDictionary *userInfo);

//请求进度 block
typedef void(^block_resp_progress)(unsigned long long totalLength, NSInteger currentLength, NSDictionary *userInfo);

@interface CCHttpResponseCallback : NSObject

@property (nonatomic, copy)block_resp_success respSuccess;
@property (nonatomic, copy)block_resp_fail respFail;
@property (nonatomic, copy)block_resp_progress respProgress;

@property (nonatomic, assign)id<CCHttpResponseCallbackDelegate> delegate;

- (instancetype)initWithSuccess:(block_resp_success)success fail:(block_resp_fail)fail progress:(block_resp_progress)progress;

@end
