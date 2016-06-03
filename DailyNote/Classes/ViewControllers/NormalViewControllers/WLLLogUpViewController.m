//
//  WLLLogUpViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLLogUpViewController.h"
#import "UserInfo.h"
#import "AppDelegate.h"

@interface WLLLogUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logUpImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logUpButton;
@property (strong, nonatomic) AppDelegate *logUpDelegate;


@end

@implementation WLLLogUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"注册";
    self.logUpButton.layer.cornerRadius = 10;
    self.passwordTextField.secureTextEntry = YES;
    
    
    
    }

#pragma mark - 注册操作
- (IBAction)logUpAction:(UIButton *)sender {
    
    AVUser *user = [AVUser user];
    user.username = self.emailTextField.text;
    user.email = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    
    //设置user的nickName
    [user setObject:self.nickNameTextField.text forKey:@"nickName"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            //通过coreData存储用户的nickName和signature
            /*//把用户的昵称通过coreData保存在本地
            //获取本app上下文
             self.logUpDelegate = [UIApplication sharedApplication].delegate ;
            NSManagedObjectContext *context = self.logUpDelegate.managedObjectContext;
            
            //获取实体描述
            NSEntityDescription *description = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:context];
            
            //创建被管理的对象
            UserInfo * info = [[UserInfo alloc] initWithEntity:description insertIntoManagedObjectContext:context];
            info.nickName = self.nickNameTextField.text;
//            [self.logUpDelegate saveContext];//需要有改动且没有错误
            NSError *error = nil;
            [context save:&error];//无论是否有改动都存储*/
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册成功,请到邮箱激活账号"
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"注册失败%@", error);

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证邮箱" message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"请检查邮箱"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
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
