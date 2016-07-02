//
//  WLLSecurityViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/7.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLSecurityViewController.h"

@interface WLLSecurityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *previousCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNewCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondNewCodeTextField;

@end

@implementation WLLSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"修改密码";
    
    
    [self addRightButton];
}

//添加右边保存按钮
- (void)addRightButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(changeSecretCodeAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)changeSecretCodeAction {
    AVUser *user = [AVUser currentUser];
    if ([self.firstNewCodeTextField.text isEqualToString:self.secondNewCodeTextField.text]) {
        [user updatePassword:self.previousCodeTextField.text
                 newPassword:self.firstNewCodeTextField.text
                       block:^(id object, NSError *error) {
            if (error == nil) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"原密码错误"
                                                                                         message:@""
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(disappearAction:)
                                               userInfo:alertController
                                                repeats:NO];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
            }
        }];
    } else {
        
        //两次输入的新密码不一致时提示框,加上计时器，间隔一个时间退出
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请确保两次输入的密码一致"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [NSTimer scheduledTimerWithTimeInterval:1
                                         target:self
                                       selector:@selector(disappearAction:)
                                       userInfo:alertController
                                        repeats:NO];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
        
    }
    
}

//计时器方法，dismissAlertController
- (void)disappearAction:(NSTimer *)timer {
    UIAlertController *alertController = (UIAlertController *)[timer userInfo];
    [alertController dismissViewControllerAnimated:YES completion:nil];
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
