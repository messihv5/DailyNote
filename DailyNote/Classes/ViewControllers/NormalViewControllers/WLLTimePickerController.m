//
//  WLLTimePickerController.m
//  DailyNote
//
//  Created by Messi on 16/6/14.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLTimePickerController.h"

@interface WLLTimePickerController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *myTimePick;
@property (weak, nonatomic) IBOutlet UIButton *chooseTimeButton;

@end

@implementation WLLTimePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//通过datePicker设定时间
- (IBAction)chooseTimeAction:(UIButton *)sender {
    NSDate *selectedDate = self.myTimePick.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *timeString = [dateFormatter stringFromDate:selectedDate];
    self.block(timeString);
    [self.navigationController popViewControllerAnimated:YES];
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
