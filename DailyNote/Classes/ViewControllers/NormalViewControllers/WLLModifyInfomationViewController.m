//
//  WLLModifyInfomationViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/31.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLModifyInfomationViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"

@interface WLLModifyInfomationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *signatureTextField;
//@property (strong, nonatomic) AppDelegate *modifyDelegate;
//@property (strong, nonatomic) NSManagedObjectContext *modifyContext;

@end

@implementation WLLModifyInfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"修改资料";
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(modifyUserInfoAction)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    //接受从用户界面传过来的nickName和signature
    self.nickNameTextField.text = self.nickNameString;
    self.signatureTextField.text = self.signatureString;
    
//    self.modifyDelegate = [UIApplication sharedApplication].delegate;
//    self.modifyContext = self.modifyDelegate.managedObjectContext;
    
}

- (void)modifyUserInfoAction {
    
    //CoreData存储修改后的nickName和signature
    /*
    self.block(self.nickNameTextField.text, self.signatureTextField.text);
    [self.navigationController popViewControllerAnimated:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.modifyContext];
    [fetchRequest setEntity:description];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.modifyContext executeFetchRequest:fetchRequest error:&error];
    UserInfo *info = fetchedObjects[0];
    [info setValue:self.nickNameTextField.text forKey:@"nickName"];
    [info setValue:self.signatureTextField.text forKey:@"signature"];
    
    NSError *saveError = nil;
    [self.modifyContext save:&saveError];*/
    
    //leancloud存储nickName和signature
    AVUser *user = [AVUser currentUser];
    [user setObject:self.nickNameTextField.text forKey:@"nickName"];
    [user setObject:self.signatureTextField.text forKey:@"signature"];
    [user saveInBackground];
    
    self.block(self.nickNameTextField.text, self.signatureTextField.text);
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
