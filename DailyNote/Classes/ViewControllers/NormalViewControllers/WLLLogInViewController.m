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
#import "WLLDailyNoteDataManager.h"

@interface WLLLogInViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (assign, nonatomic) BOOL isBackFromLoginController;

@end

@implementation WLLLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
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
    
    self.logInButton.layer.cornerRadius = 5;
    self.logInButton.layer.masksToBounds = YES;
    
    self.headImageView.layer.cornerRadius = kWidth / 6;
    self.headImageView.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    
}

#pragma mark - 登录操作

- (IBAction)logInAction:(UIButton *)sender {
    BOOL isNetworkAvailble = [WLLDailyNoteDataManager sharedInstance].isNetworkAvailable;
    if (isNetworkAvailble == YES) {
        [AVUser logInWithUsernameInBackground:self.emailTextField.text
                                     password:self.passwordTextField.text
                                        block:^(AVUser *user, NSError *error) {
                                            if (error == nil) {
                                                self.isBackFromLoginController = YES;
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            } else {
                                                UIAlertController *alert;
                                                alert = [UIAlertController alertControllerWithTitle:@"邮箱或密码有误"
                                                                                            message:nil
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                                UIAlertAction *action;
                                                action = [UIAlertAction actionWithTitle:@"确定"
                                                                                  style:UIAlertActionStyleDestructive
                                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                                }];
                                                [alert addAction:action];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                        }];

    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请检查网络"
                                                                       message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                       }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
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

#pragma mark - textFiled代理方法，处理键盘

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailTextField]) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
        CGRect viewRect = self.view.frame;
        viewRect.origin.y = viewRect.origin.y - 20;
        self.view.frame = viewRect;
    } else {
        [textField resignFirstResponder];
    }
    return YES;
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
