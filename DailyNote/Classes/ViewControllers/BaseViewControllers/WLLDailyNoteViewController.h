//
//  WLLDailyNoteViewController.h
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

/**
 *  日记页面
 */

#import <UIKit/UIKit.h>

@interface WLLDailyNoteViewController : UIViewController

/**
 *  在dailyNoteVC页面通过这个，判断是不是从calendar加载日记
 */
@property (assign, nonatomic) BOOL isFromCalendar;

/**
 *  点击日历日期，传过来的日期字符串
 */
@property (copy, nonatomic) NSString *dateString;

@end
