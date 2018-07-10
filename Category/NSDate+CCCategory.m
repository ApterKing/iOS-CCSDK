//
//  NSDate+CCCategory.m
//  CCSDK
//
//  Created by wangcong on 15-6-11.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "NSDate+CCCategory.h"

@implementation NSDate (CCCategory)

- (NSString *)chineseDate
{
    //        NSArray *chineseYears = [NSArray arrayWithObjects:
    //                                 @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
    //                                 @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
    //                                 @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
    //                                 @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
    //                                 @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
    //                                 @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"冬月", @"腊月", nil];
    NSArray *chineseDays=[NSArray arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十", @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:self];
    //        NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    NSString *chineseCal_str =[NSString stringWithFormat: @"农历%@%@", m_str, d_str];
    return chineseCal_str;
}

- (NSString *)formatDate:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFrom:(NSString *)dateString formatter:(NSString *)formatter
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = formatter;
    return [format dateFromString:dateString];
}

+ (NSString *)configTimeWithDate:(NSDate *)date
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (interval / 60.0 < 1) {
        return @"刚刚";
    } else if (interval / 60.0 >= 1 && interval / 60.0 < 60) {
        return [NSString stringWithFormat:@"%.f分钟前", interval / 60.0];
    } else if (interval / 3600.0 >= 1 && interval / 3600.0 < 24) {
        return [NSString stringWithFormat:@"%.f小时前", interval / 3600.0];
    } else if (interval / (3600 * 24.0) >= 1 && interval / (3600 * 24.0) < 30) {
        return [NSString stringWithFormat:@"%.f天前", interval / (3600 * 24)];
    } else if (interval / (3600 * 24 * 30.0) >= 1 && interval / (3600 * 24 * 30.0) < 12) {
        return [NSString stringWithFormat:@"%.f月前", interval / (3600 * 24 * 30.0)];
    } else {
        return [date formatDate:@"yyyy-MM-dd"];
    }
}

@end
