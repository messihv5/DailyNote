//
//  NSString+WeekDay.m
//  DailyNote
//
//  Created by CapLee on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "NSString+WeekDay.h"

@implementation NSString (WeekDay)

+ (NSString *)nt_nowDateFromDate:(NSDate *)date {

    // 设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M.dd"];
    return [formatter stringFromDate:date];
}

+ (NSString *)nt_monthAndYearFromDate:(NSDate *)date {

    // 设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM"];
    return [formatter stringFromDate:date];
}

+ (NSString *)nt_timeFromDate:(NSDate *)date {

    // 设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

+ (NSString *)wd_weekDayFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 初始dateComponents
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:date];
    
    NSString *weekStr = [NSString string];
    
    NSInteger week = [comps weekday];
    
    weekStr = [self getweek:week];
    
    return weekStr;
}


// 根据week对应为周几
+ (NSString*)getweek:(NSInteger)week {
    
    NSString *weekStr = nil;
    
    if (week==1) {
        weekStr = @"周日";
    } else if (week == 2) {
        weekStr = @"周一";
    } else if (week == 3) {
        weekStr = @"周二";
    } else if (week==4){
        weekStr = @"周三";
    } else if (week == 5) {
        weekStr = @"周四";
    } else if (week == 6) {
        weekStr = @"周五";
    } else if (week == 7){
        weekStr = @"周六";
    }
    return weekStr;
}

@end
