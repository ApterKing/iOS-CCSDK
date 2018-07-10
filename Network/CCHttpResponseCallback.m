//
//  CCHttpResponseCallback.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpResponseCallback.h"

@implementation CCHttpResponseCallback

- (instancetype)initWithSuccess:(block_resp_success)success fail:(block_resp_fail)fail progress:(block_resp_progress)progress
{
    self = [super init];
    if (self) {
        _respSuccess = success;
        _respFail = fail;
        _respProgress = progress;
    }
    return self;
}

- (void)dealloc
{
}

@end
