//
//  WLLCalendarView.h
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

// 推送到主页代理
@protocol ShowNoteDelegate <NSObject>

/**
 *  从日历页面推送到主页
 */
- (void)pushNotePage;

@end

@interface WLLCalendarView : UIView

/* 日期 */
@property (nonatomic , strong) NSDate *date;
/* 今天 */
@property (nonatomic , strong) NSDate *today;
/* 回调 */
@property (nonatomic, copy) void(^calendarBlock)(NSInteger day, NSInteger month, NSInteger year);
/* 代理 */
@property (nonatomic, weak) id <ShowNoteDelegate> showDelegate;

/**
 *  展示日历
 *
 *  @param view 当前调用的View
 *
 *  @return 返回日历
 */
+ (instancetype)showOnView:(UIView *)view;

@end
