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

- (void)loadView {
    self.WV = [[WLLView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    self.view = self.WV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presentCalendarView];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self addLeftAction];
}

- (void)addLeftAction {
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = left;
}

- (void)backAction:(UIBarButtonItem *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)presentCalendarView {
    
    WLLCalendarView *calendarView = [WLLCalendarView showOnView:self.view];
    calendarView.showDelegate = self;
    // MARK: ???
    calendarView.today = [NSDate date];
    calendarView.date = calendarView.today;
    calendarView.frame = CGRectMake(0, 100, kWidth, kHeight*0.7);
    calendarView.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
        
        self.dateString = [NSString stringWithFormat:@"%li-%li-%li", year, month, day];
    };
    self.calendarView = calendarView;
}

- (void)pushNotePage {
    WLLDailyNoteViewController *dailyNoteVC = [[WLLDailyNoteViewController alloc] initWithNibName:@"WLLDailyNoteViewController" bundle:[NSBundle mainBundle]];
    
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
