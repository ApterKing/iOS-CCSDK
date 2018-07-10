//
//  CCHttpRequestCallback.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpRequestCallback.h"

@implementation CCHttpRequestCallback

- (instancetype)initWithFail:(block_req_fail)fail progress:(block_req_progress)progress
{
    self = [super init];
    if (self) {
        _reqFail = fail;
        _reqProgress = progress;
    }
    return self;
}

- (void)dealloc
{
}

@end
