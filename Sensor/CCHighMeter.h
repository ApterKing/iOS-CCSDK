//
//  CCHighMeter.h
//  CCSDK
//
//  Created by wangcong on 15/9/8.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CCHighMeterHandler)(CGFloat high, NSError *error);

/**
 *  跳高测量
 */
@interface CCHighMeter : NSObject

- (void)startWithHandler:(CCHighMeterHandler)handler;
- (void)startOtherMethodWithHandler:(CCHighMeterHandler)handler;
- (void)stop;

@end
