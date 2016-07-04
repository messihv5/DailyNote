//
//  NSString+WeekDay.h
//  DailyNote
//
//  Created by CapLee on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WeekDay)


/**
 *  计算当前日期
 *
 *  @return 返回String格式日期
 */
+ (NSString *)nt_nowDateFromDate:(NSDate *)date;

/**
 *  计算当前年月
 *
 *  @return 返回String格式年月
 */
+ (NSString *)nt_monthAndYearFromDate:(NSDate *)date;

/**
 *  计算当前时间
 *
 *  @return 返回String格式时间
 */
+ (NSString *)nt_timeFromDate:(NSDate *)date;

/**
 *  计算周几
 *
 *  @param date 当前日期
 *
 *  @return 返回String格式周几
 */
+ (NSString *)wd_weekDayFromDate:(NSDate *)date;

@end
