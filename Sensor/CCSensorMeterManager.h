//
//  CCSensorMeterManager.h
//  CCSDK
//
//  Created by wangcong on 15/9/10.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPunchMeterData.h"

// 跳高
typedef void(^CCHighMeterHandler)(CGFloat high, NSError *error);

// 挥拳
typedef NS_ENUM(NSInteger, CCSex) {
    CCSEX_MALE,             // 男
    CCSEX_FEMALE            // 女
};
typedef void(^CCPunchMeterHandler)(CCPunchMeterData *punchMeterData,BOOL stop, NSError *error);

/**
 *  用于跳高、快速打拳测速度等
 */
@interface CCSensorMeterManager : NSObject

+ (instancetype) sharedInstance;

/**
 *  通过步数计算卡路里
 *
 *  @param numberOfSteps 步数
 *  @param age           年龄
 *  @param sex           性别 1:男  2:女
 *  @param weight        体重
 *  @param time          空闲时长sec 如（8:00 ~ 9:00）时常 60 * 60
 *  @return
 */
+ (CGFloat)calculateCalorieWithStep:(NSInteger)numberOfSteps age:(NSInteger)age sex:(NSInteger)sex weight:(CGFloat)weight time:(NSTimeInterval)time;

/**
 *  通过步数计算行走里程
 *
 *  @param numberOfSteps 步数
 *  @param height        身高 cm
 *  @return
 */
+ (CGFloat)calculateDistanceWithStep:(NSInteger)numberOfSteps height:(CGFloat)height;

/**
 *  跳高测试
 *  @param handler 跳高回调
 */
- (void)startHighMeterWithHandler:(CCHighMeterHandler)handler;
- (void)stopHighMeter;

/**
 *  挥拳测试 （较大力量）
 *
 *  @param time    测试时长
 *  @param sex     性别
 *  @param handler 回调
 */
- (void)startPunchMeterWithTestingTime:(NSTimeInterval)testingTime sex:(CCSex)sex handler:(CCPunchMeterHandler)handler;
- (void)stopPunchMeter;

@end
