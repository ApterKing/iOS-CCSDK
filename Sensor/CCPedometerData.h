//
//  CCPedometerData.h
//  CCSDK
//
//  Created by wangcong on 15/9/12.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCPedometerData : NSObject

@property(nonatomic, strong) NSDate *startDate;               // 开始时间

@property(nonatomic, strong) NSDate *endDate;                 // 结束时间

@property(nonatomic, strong) NSNumber *numberOfSteps;         // 步数

@property(nonatomic, strong) NSNumber *distance;              // 距离 (iphone5s && IOS8.0 此参数有效)

@end
