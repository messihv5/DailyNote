//
//  WLLAboutDailyNoteViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLAboutDailyNoteViewController.h"

@interface WLLAboutDailyNoteViewController ()

@end

@implementation WLLAboutDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)commitAction:(UIButton *)sender {
    NSString *str = @"https://itunes.apple.com/us/app/wu-ji-zuo-zui-hao-jing-zhi/id1084747109?mt=8";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
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
