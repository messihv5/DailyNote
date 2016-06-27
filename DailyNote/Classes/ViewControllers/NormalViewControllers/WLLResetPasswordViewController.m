//
//  WLLResetPasswordViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLResetPasswordViewController.h"

@interface WLLResetPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *resetImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;

@end

@implementation WLLResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"重置密码";
    self.resetPasswordButton.layer.cornerRadius = 10;
    
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    
    self.emailTextField.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)resetPasswordAction:(UIButton *)sender {
    
    [AVUser requestPasswordResetForEmailInBackground:self.emailTextField.text
                                               block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置密码" message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"请去邮箱重置密码"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邮箱错误"
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}

#pragma mark -textField代理方法

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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
