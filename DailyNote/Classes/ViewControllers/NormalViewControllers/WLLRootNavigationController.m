//
//  WLLRootNavigationController.m
//  DailyNote
//
//  Created by Messi on 16/7/6.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLRootNavigationController.h"

@interface WLLRootNavigationController ()

@end

@implementation WLLRootNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
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
