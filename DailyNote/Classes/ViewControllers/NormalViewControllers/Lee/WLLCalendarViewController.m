//
//  WLLCalendarViewController.m
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLCalendarViewController.h"
#import "WLLCalendarView.h"
#import "WLLNoteDetailViewController.h"

@interface WLLCalendarViewController ()<ShowNoteDelegate>

@property (nonatomic, strong) WLLCalendarView *calendarView;

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
        
        NSLog(@"%li-%li-%li", year,month,day);
    };
    self.calendarView = calendarView;
}

- (void)pushNotePage {
    WLLNoteDetailViewController *NoteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController" bundle:nil];
    
    [self.navigationController pushViewController:NoteDetailVC animated:YES];
    
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
