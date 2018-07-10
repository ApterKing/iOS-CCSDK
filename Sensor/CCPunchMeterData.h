//
//  CCPunchMeterData.h
//  CCSDK
//
//  Created by wangcong on 15/9/12.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCPunchMeterData : NSObject

@property(nonatomic, assign) NSInteger puchTimes;               // 挥拳次数

@property(nonatomic, assign) NSTimeInterval passedTime;         // 测试过了多长时间

@property(nonatomic, assign) NSTimeInterval testingTime;        // 测试时长

@end
