//
//  CCHttpRequestCallback.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  Http请求代理，监听请求失败及上传进度
 */
#import <Foundation/Foundation.h>

@class CCHttpError;

// CCHttpRequestCallback 代理
@protocol CCHttpRequestCallbackDelegate <NSObject>

// 请求失败
- (void)onFail:(CCHttpError *)error userInfo:(NSDictionary *)userInfo;

// 请求进度
- (void)onProgress:(NSInteger)totalLength current:(NSInteger)currentLength userInfo:(NSDictionary *)userInfo;

@end

// 请求失败 block
typedef void(^block_req_fail)(CCHttpError *error, NSDictionary *userInfo);

//请求进度 block
typedef void(^block_req_progress)(NSInteger totalLength, NSInteger currentLength, NSDictionary *userInfo);

@interface CCHttpRequestCallback : NSObject

@property (nonatomic, copy)block_req_fail reqFail;
@property (nonatomic, copy)block_req_progress reqProgress;

@property (nonatomic, assign)id<CCHttpRequestCallbackDelegate> delegate;

- (instancetype)initWithFail:(block_req_fail)fail progress:(block_req_progress)progress;

@end
