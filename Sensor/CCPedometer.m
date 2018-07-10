//
//  CCPedometer.m
//  CCSDK
//
//  Created by wangcong on 15/8/14.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPedometer.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPedometerManager.h"
#import "CCSDKDefines.h"
#import "NSDate+CCCategory.h"

#define kPedometerUpdateInterval 4.0f

@interface CCPedometer()
{

}

// 使用CMMotionManager 计步 (Iphone5s 以下手机)
@property(nonatomic, strong) NSDate *start;
@property(nonatomic, strong) CCPedometerHandler handler;

// 使用CMStepCounter 计步 (IOS7.0 ~ IOS8.0)
@property(nonatomic, strong) CMStepCounter *stepConter;

// 使用CMPedometer 计步 (IOS8.0 ~)
@property(nonatomic, strong) CMPedometer *pedometer;

@end

@implementation CCPedometer

+ (instancetype)sharedInstance
{
    static CCPedometer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initObjectIfNecessary];
    }
    return self;
}

- (void)initObjectIfNecessary
{
    if (SYSTEM_VERSION >= 8.0 && [CMPedometer isStepCountingAvailable]) {
        self.pedometer = [[CMPedometer alloc] init];
    } else if (SYSTEM_VERSION >= 7.0 && SYSTEM_VERSION < 8.0 && [CMStepCounter isStepCountingAvailable]) {
        self.stepConter = [[CMStepCounter alloc] init];
    }
}

- (void)queryPedometerDataFromDate:(NSDate *)start toDate:(NSDate *)end withHandler:(CCPedometerHandler)handler
{
    if (SYSTEM_VERSION < 7.0) return;
    if (SYSTEM_VERSION >= 8.0 && [CMPedometer isStepCountingAvailable]) {
        [self.pedometer queryPedometerDataFromDate:start toDate:end withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            CCPedometerData *destPedometerData = [[CCPedometerData alloc] init];
            destPedometerData.startDate = pedometerData.startDate;
            destPedometerData.endDate = pedometerData.endDate;
            destPedometerData.numberOfSteps = pedometerData.numberOfSteps;
            destPedometerData.distance = pedometerData.distance;
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(destPedometerData, error);
            });
        }];
    } else if (SYSTEM_VERSION >= 7.0 && SYSTEM_VERSION < 8.0 && [CMStepCounter isStepCountingAvailable]) {
        [self.stepConter queryStepCountStartingFrom:start to:end toQueue:[[NSOperationQueue alloc] init] withHandler:^(NSInteger numberOfSteps, NSError *error) {
            CCPedometerData *destPedometerData = [[CCPedometerData alloc] init];
            destPedometerData.startDate = start;
            destPedometerData.endDate = end;
            destPedometerData.numberOfSteps = [NSNumber numberWithInteger:numberOfSteps];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(destPedometerData, error);
            });
        }];
    }
}

- (void)startPedometerUpdatesFromDate:(NSDate *)start withHandler:(CCPedometerHandler)handler
{
    if (SYSTEM_VERSION < 7.0) return;
    if (SYSTEM_VERSION >= 8.0 && [CMPedometer isStepCountingAvailable]) {
        [self.pedometer startPedometerUpdatesFromDate:[NSDate dateFrom:[[NSDate date] formatDate:@"yyyy-MM-dd"] formatter:@"yyyy-MM-dd"] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            CCPedometerData *destPedometerData = [[CCPedometerData alloc] init];
            destPedometerData.startDate = pedometerData.startDate;
            destPedometerData.endDate = pedometerData.endDate;
            destPedometerData.numberOfSteps = pedometerData.numberOfSteps;
            destPedometerData.distance = pedometerData.distance;
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(destPedometerData, error);
            });
        }];
    } else if (SYSTEM_VERSION >= 7.0 && SYSTEM_VERSION < 8.0 && [CMStepCounter isStepCountingAvailable]) {
        [self.stepConter startStepCountingUpdatesToQueue:[[NSOperationQueue alloc] init] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            CCPedometerData *destPedometerData = [[CCPedometerData alloc] init];
            destPedometerData.startDate = start;
            destPedometerData.endDate = timestamp;
            destPedometerData.numberOfSteps = [NSNumber numberWithInteger:numberOfSteps];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(destPedometerData, error);
            });
        }];
    }
}

- (void)stopPedometerUpdates
{
    if (SYSTEM_VERSION >= 8.0 && [CMPedometer isStepCountingAvailable]) {
        [self.pedometer stopPedometerUpdates];
        self.pedometer = nil;
    } else if (SYSTEM_VERSION >= 7.0 && SYSTEM_VERSION < 8.0 && [CMStepCounter isStepCountingAvailable]) {
        [self.stepConter stopStepCountingUpdates];
    }
}

- (void)dealloc
{
    [self stopPedometerUpdates];
}

@end
