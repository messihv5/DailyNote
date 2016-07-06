//
//  WLLCalendarViewController.m
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLCalendarViewController.h"
#import "WLLCalendarView.h"
#import "WLLDailyNoteViewController.h"

@interface WLLCalendarViewController ()<ShowNoteDelegate>

@property (nonatomic, strong) WLLCalendarView *calendarView;

@property (assign, nonatomic) BOOL isFromCalendar;

@end

@implementation WLLCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presentCalendarView];
    
    
}

- (void)presentCalendarView {
    WLLCalendarView *calendarView = [WLLCalendarView showOnView:self.view];
    calendarView.showDelegate = self;
    calendarView.today = [NSDate date];
    calendarView.date = calendarView.today;
    calendarView.frame = CGRectMake(0, 100, self.view.frame.size.width, 352);
    calendarView.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
        
        self.dateString = [NSString stringWithFormat:@"%li-%li-%li", year, month, day];
        NSLog(@"%li-%li-%li", year,month,day);
    };
    self.calendarView = calendarView;
}

- (void)pushNotePage {
    WLLDailyNoteViewController *dailyNoteVC = [[WLLDailyNoteViewController alloc] initWithNibName:@"WLLDailyNoteViewController" bundle:nil];
    
    //给dailyNote传个标记，判断dailyNote来自calendar的点击
    self.isFromCalendar = YES;
    dailyNoteVC.isFromCalendar = self.isFromCalendar;
    dailyNoteVC.dateString = self.dateString;
    
    [self.navigationController pushViewController:dailyNoteVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
