//
//  NSDate+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15-6-11.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CCCategory)

/**
 *  获取农历
 *  @return
 */
- (NSString *)chineseDate;

/**
 *  根据指定的pattern格式化时间
 *
 *  @param formatter 时间格式
 *  @return
 */
- (NSString *)formatDate:(NSString *)formatter;

/**
 *  从指定字符串中获取NSDate
 *
 *  @param dateString 时间字符串
 *  @param formatter
 *  @return
 */
+ (NSDate *)dateFrom:(NSString *)dateString formatter:(NSString *)formatter;

/**
 *  将时间设置成  刚刚、N分钟前、N小时前、N月前
 *
 *  @param date
 *
 *  @return 
 */
+ (NSString *)configTimeWithDate:(NSDate *)date;

@end
