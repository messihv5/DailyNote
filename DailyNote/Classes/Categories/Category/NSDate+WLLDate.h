//
//  NSDate+WLLDate.h
//  DailyNote
//
//  Created by CapLee on 16/7/6.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WLLDate)

- (NSInteger)day:(NSDate *)date;

- (NSInteger)month:(NSDate *)date;

- (NSInteger)year:(NSDate *)date;

- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date;

- (NSInteger)totaldaysInThisMonth:(NSDate *)date;

- (NSInteger)totaldaysInMonth:(NSDate *)date;

- (NSDate *)lastMonth:(NSDate *)date;

- (NSDate *)nextMonth:(NSDate *)date;

@end
