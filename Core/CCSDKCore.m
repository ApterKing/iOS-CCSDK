//
//  CCSDKCore.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCSDKCore.h"
#import "CCNetUtil.h"

@interface CCSDKCore ()

@property(nonatomic, assign)CCNetworkStatus netStatus;

// 检测网络状态改变
- (void)detectNetStatusChange;

@end

static CCSDKCore *instance = nil;
static dispatch_once_t once_t;
@implementation CCSDKCore

+ (instancetype)sharedInstance
{
    dispatch_once(&once_t, ^{
        if (instance == nil) {
            instance = [[[self class] alloc] init];
        }
    });
    return instance;
}

+ (void)initializeSDK
{
    [CCSDKCore sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 检测网络状态变化
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.netStatus = [CCNetUtil networkStatus];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(detectNetStatusChange) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
        
        // 初始化缓存
        [[CCCacheManager sharedInstance] initialCache];
    }
    return self;
}

- (void)detectNetStatusChange
{
    CCNetworkStatus tmpStatus = [CCNetUtil networkStatus];
    if (self.netStatus != tmpStatus) {
        self.netStatus = tmpStatus;
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_NETSTATUS_CHANGED object:[NSNumber numberWithInteger:tmpStatus]];
    }
}

@end
