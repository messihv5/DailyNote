//
//  WLLLogInViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLLogInViewController.h"
#import "WLLLogUpViewController.h"
#import "WLLResetPasswordViewController.h"

@interface WLLLogInViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation WLLLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordTextField.secureTextEntry = YES;
    
    self.logInButton.layer.cornerRadius = 10;
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"注册"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(logUpAction)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"重置密码"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(resetPassword)];
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
    
    
    // Do any additional setup after loading the view from its nib.
    
}

#pragma mark - 登录操作
- (IBAction)logInAction:(UIButton *)sender {
    [AVUser logInWithUsernameInBackground:self.emailTextField.text
                                 password:self.passwordTextField.text
                                    block:^(AVUser *user, NSError *error) {
        if (user != nil) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邮箱或密码有误"
                                                                           message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}


#pragma mark - 跳转至注册页面以及重置密码
- (void)logUpAction {
    WLLLogUpViewController *logUpVC = [[WLLLogUpViewController alloc] initWithNibName:@"WLLLogUpViewController"
                                                                               bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:logUpVC animated:YES];
}

- (void)resetPassword {
    WLLResetPasswordViewController *resetVC;
    resetVC= [[WLLResetPasswordViewController alloc] initWithNibName:@"WLLResetPasswordViewController"
                                                              bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:resetVC animated:YES];
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
