//
//  CCHighMeter.m
//  CCSDK
//
//  Created by wangcong on 15/9/8.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHighMeter.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

#define kUpdateInterval (1 / 100.0f)

#define KG                                      9.88f           // 重力加速度

#define kJumpMaxTimeInterval                    0.40        // 滞空最大时常
#define kJumpVertexMaxResultantVector           0.15f       // 跳高到顶点时合向量最大值
#define kJumpDownMinResultantVector             4.0f        // 跳高回落到地面产生的合向量需要达到的最小值

@interface CCHighMeter ()

@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *queue;


@property(nonatomic, strong) CMAccelerometerData *mJumpVertexAccelerometerData;          // 记录跳到最高点
@property(nonatomic, strong) CMAccelerometerData *mJumpDownFloorAccelerometerData;       // 记录落地点


@property(nonatomic, strong) CMAccelerometerData *recordAccelerometerData;          // 记录跳到最高点
@property(nonatomic, strong) CMAccelerometerData *firstAccelerometerData;          // 记录跳到最高点
@property(nonatomic, strong) CMAccelerometerData *secondAccelerometerData;       // 记录落地点
@property(nonatomic, strong) CMAccelerometerData *thirdAccelerometerData;          // 记录跳到最高点


@end

@implementation CCHighMeter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.motionManager = [CMMotionManager new];
        self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
        self.motionManager.showsDeviceMovementDisplay  = YES;
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)startOtherMethodWithHandler:(CCHighMeterHandler)handler
{
    if (self.motionManager.isAccelerometerAvailable) {
        if (!self.motionManager.isAccelerometerActive) {
            @weakify(self);
            [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
                @strongify(self);
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.recordAccelerometerData = accelerometerData;
                    CGFloat vector = [self _calculateResultantVector:self.recordAccelerometerData.acceleration];
                    if (vector > 2.0) {
                        //寻找到第一个波峰  并且第一个波峰vector > 2
                        if (self.firstAccelerometerData == nil || (vector - [self _calculateResultantVector:self.firstAccelerometerData.acceleration] > 0 && self.secondAccelerometerData == nil) ) {
                            self.firstAccelerometerData = self.recordAccelerometerData;
                        }else{
                            // 寻找第二个波峰
                            if (self.secondAccelerometerData == nil || (vector - [self _calculateResultantVector:self.secondAccelerometerData.acceleration]>0 && self.thirdAccelerometerData == nil)) {
                                self.secondAccelerometerData = self.recordAccelerometerData;
                            }else{
//                                if (vector < 5.0) return ;
                                // 寻找第三个波峰
                                if (self.thirdAccelerometerData == nil || vector - [self _calculateResultantVector:self.thirdAccelerometerData.acceleration] > 0) {
                                    self.thirdAccelerometerData = self.recordAccelerometerData;
                                }else{
                                    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$---->%f",[self _calculateResultantVector:self.thirdAccelerometerData.acceleration]);
                                    if (self.firstAccelerometerData == nil || self.secondAccelerometerData == nil || self.thirdAccelerometerData == nil) {
                                        self.thirdAccelerometerData = nil;
                                        self.secondAccelerometerData = nil;
                                        self.firstAccelerometerData = nil;
                                        return;

                                    }
                                    //计算测量结果
                                    NSTimeInterval timeInterval = (self.thirdAccelerometerData.timestamp - self.secondAccelerometerData.timestamp)/2;
                                    NSLog(@"落地时间---》%f***********起跳时间%f===========%f",self.thirdAccelerometerData.timestamp , self.secondAccelerometerData.timestamp,timeInterval);
                                    if (timeInterval > 0.4 || timeInterval < 0.05 ) {
                                        self.thirdAccelerometerData = nil;
                                        self.secondAccelerometerData = nil;
                                        self.firstAccelerometerData = nil;
                                        return;
                                    }
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                    self.thirdAccelerometerData = nil;
                                    self.secondAccelerometerData = nil;
                                    self.firstAccelerometerData = nil;
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        handler(KG * timeInterval * timeInterval / 2.0f, nil);
                                    }];
                                }
                            }
                        }
                    }
                }];
            }];
            
        }
    } else {
        NSLog(@"你的设备太差了，不支持DeviceMotion");
    }
}



- (void)startWithHandler:(CCHighMeterHandler)handler
{
    if (self.motionManager.isAccelerometerAvailable) {
        if (!self.motionManager.isAccelerometerActive) {
            @weakify(self);
            [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
                @strongify(self);
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    CGFloat vector = [self _calculateResultantVector:accelerometerData.acceleration];
                    NSLog(@"fuck--- %f --- %f --- %f --- %f----- %f ---->>>>>%@", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z, accelerometerData.timestamp, vector,self.mJumpDownFloorAccelerometerData);
                    
                    // 合向量大于一定的数值，并且存在最小合向量才表示跳高，规避打拳晃动等影响
                    if (vector > kJumpDownMinResultantVector && self.mJumpVertexAccelerometerData != nil) {
                        NSLog(@"fuck-----$$$$$$$$$$$$$$$$$$$$$$$$");
                        if (!self.mJumpDownFloorAccelerometerData ||
                            vector > [self _calculateResultantVector:self.mJumpDownFloorAccelerometerData.acceleration]) {
                            NSLog(@"fuck-----%%%%%%%%%%%%%%%%%%%%%%%%-----%f", vector);
                            self.mJumpDownFloorAccelerometerData = accelerometerData;
                        } else {
                            NSTimeInterval timeInterval = self.mJumpDownFloorAccelerometerData.timestamp - self.mJumpVertexAccelerometerData.timestamp;
                            NSLog(@"落地时间---》%f***********起跳时间%f===========%f",self.mJumpDownFloorAccelerometerData.timestamp , self.mJumpVertexAccelerometerData.timestamp,timeInterval);
                            if (timeInterval > 0.4) {
                                self.mJumpVertexAccelerometerData = nil;
                                self.mJumpDownFloorAccelerometerData = nil;
                                return;
                            }
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            self.mJumpVertexAccelerometerData = nil;
                            self.mJumpDownFloorAccelerometerData = nil;
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                handler(KG * timeInterval * timeInterval / 2.0f, nil);
                            }];
                        }
                    } else if (vector < kJumpVertexMaxResultantVector) {       // 得到最低点
                        if (self.mJumpVertexAccelerometerData == nil ||
                            (self.mJumpVertexAccelerometerData != nil && vector < [self _calculateResultantVector:self.mJumpVertexAccelerometerData.acceleration])) {
                            self.mJumpVertexAccelerometerData = accelerometerData;
                            NSLog(@"fuck-----####################");
                        }
                        
                    } else if (self.mJumpDownFloorAccelerometerData != nil && self.mJumpVertexAccelerometerData != nil) {  //
                        
                        NSTimeInterval timeInterval = self.mJumpDownFloorAccelerometerData.timestamp - self.mJumpVertexAccelerometerData.timestamp;
                        NSLog(@"落地时间---》%f***********起跳时间%f===========%f",self.mJumpDownFloorAccelerometerData.timestamp , self.mJumpVertexAccelerometerData.timestamp,timeInterval);
                        if (timeInterval > 0.4) {
                            self.mJumpVertexAccelerometerData = nil;
                            self.mJumpDownFloorAccelerometerData = nil;
                            return;
                        }
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        self.mJumpVertexAccelerometerData = nil;
                        self.mJumpDownFloorAccelerometerData = nil;
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            handler(KG * timeInterval * timeInterval / 2.0f, nil);
                        }];
                    }
                    
                }];
                }];
                
        }
    } else {
        NSLog(@"你的设备太差了，不支持DeviceMotion");
    }
}

- (void)stop
{
    if (self.motionManager.isAccelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

NSComparator cmptr = ^(id obj1, id obj2){
    if ([obj1 doubleValue] > [obj2 doubleValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 integerValue] < [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};




/**
 *  计算合向量
 *  @param acceleration
 *  @return
 */
- (CGFloat)_calculateResultantVector:(CMAcceleration)acceleration
{
    return sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
}

@end
