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

//判断该页面是通过点击calendar加载的
@property (assign, nonatomic) BOOL isFromCalendar;

//点击日历传过来的日期
@property (copy, nonatomic) NSString *dateString;

@end
