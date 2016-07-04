//
//  WLLCalendarView.h
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowNoteDelegate <NSObject>

- (void)pushNotePage;

@end

@interface WLLCalendarView : UIView

@property (nonatomic , strong) NSDate *date;
@property (nonatomic , strong) NSDate *today;
@property (nonatomic, copy) void(^calendarBlock)(NSInteger day, NSInteger month, NSInteger year);

@property (nonatomic, weak) id <ShowNoteDelegate> showDelegate;

+ (instancetype)showOnView:(UIView *)view;

@end
