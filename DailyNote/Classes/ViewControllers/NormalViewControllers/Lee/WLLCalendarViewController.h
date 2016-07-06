//
//  WLLCalendarViewController.h
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WLLView.h"

@interface WLLCalendarViewController : UIViewController


//点击日历获得的日期字符串
@property (copy, nonatomic) NSString *dateString;

@property (nonatomic, strong) WLLView *WV;

@end
