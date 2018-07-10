//
//  CCPedometer.h
//  CCSDK
//
//  Created by wangcong on 15/8/14.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPedometerData.h"

typedef void (^CCPedometerHandler)(CCPedometerData *pedometerData, NSError *error);     // 回调

@interface CCPedometer : NSObject

// 查询
- (void)queryPedometerDataFromDate:(NSDate *)start
                            toDate:(NSDate *)end
                       withHandler:(CCPedometerHandler)handler;

// 开始监听步数的变化
- (void)startPedometerUpdatesFromDate:(NSDate *)start
                          withHandler:(CCPedometerHandler)handler;

- (void)stopPedometerUpdates;

@end
