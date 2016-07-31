//
//  WLLAboutDailyNoteViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLAboutDailyNoteViewController.h"

@interface WLLAboutDailyNoteViewController ()

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end

@implementation WLLAboutDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addCircleCornerToCommitButton];
}

/**
 *  给评价button添加圆角
 */
- (void)addCircleCornerToCommitButton {
    self.commitButton.layer.masksToBounds = YES;
    self.commitButton.layer.cornerRadius = 5.0;
}

/**
 *  评价button的点击方法
 *
 *  @param sender 评价button
 */
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
