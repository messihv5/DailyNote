//
//  WLLSettingViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/6.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLSettingViewController.h"
#import "SystemModel.h"
#import "WLLSecurityViewController.h"
#import "WLLLockViewController.h"
#import "WLLPrivateCodeViewController.h"
#import "WLLTopicViewController.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "WLLAboutDailyNoteViewController.h"

@interface WLLSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation WLLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //获取用户数据
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    
    self.navigationItem.title = @"设置";
    
    [self loadData];
}

//懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}

//加载数据
- (void)loadData {
    NSMutableArray *firstSection = [NSMutableArray array];
    SystemModel *securityModel = [[SystemModel alloc] init];
    securityModel.systemString = @"设置密码";
    [firstSection addObject:securityModel];
    [self.data addObject:firstSection];
    
    NSMutableArray *secondSection = [NSMutableArray array];
    SystemModel *codeLockModel = [[SystemModel alloc] init];
    codeLockModel.systemString = @"隐私及密码锁";
    [secondSection addObject:codeLockModel];
    [self.data addObject:secondSection];
    
    NSMutableArray *thirdSection = [NSMutableArray array];
    SystemModel *topicModel = [[SystemModel alloc] init];
    topicModel.systemString = @"主题";
    SystemModel *addressInfoModel = [[SystemModel alloc] init];
    addressInfoModel.systemString = @"地址信息";
    SystemModel *clearCacheModel = [[SystemModel alloc] init];
    clearCacheModel.systemString = @"清除缓存";
    [thirdSection addObject:topicModel];
    [thirdSection addObject:addressInfoModel];
    [thirdSection addObject:clearCacheModel];
    [self.data addObject:thirdSection];
    
    NSMutableArray *forthSection = [NSMutableArray array];
    SystemModel *suggestionModel = [[SystemModel alloc] init];
    suggestionModel.systemString = @"建议反馈";
    SystemModel *aboutDailyNoteModel = [[SystemModel alloc] init];
    aboutDailyNoteModel.systemString = @"AboutDailyNote";
    [forthSection addObject:suggestionModel];
    [forthSection addObject:aboutDailyNoteModel];
    [self.data addObject:forthSection];

}

#pragma mark - tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取用户信息
    NSString *addressString = [self.userDefaults objectForKey:@"displayAddress"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CW"];
    }
    SystemModel *model = self.data[indexPath.section][indexPath.row];
    cell.textLabel.text = model.systemString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 2 && indexPath.row == 1) {
        if ([addressString isEqualToString:@"YES"]) {
            cell.detailTextLabel.text = @"显示地址";
        } else {
            cell.detailTextLabel.text = @"不显示地址";
        }
}
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        //修改密码
        WLLSecurityViewController *securityController = [[WLLSecurityViewController alloc] initWithNibName:@"WLLSecurityViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:securityController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        //添加手势锁
        WLLPrivateCodeViewController *privateCodeViewController = [[WLLPrivateCodeViewController alloc] initWithNibName:@"WLLPrivateCodeViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:privateCodeViewController animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        
        //设置主题颜色
        WLLTopicViewController *topicController = [[WLLTopicViewController alloc] initWithNibName:@"WLLTopicViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:topicController animated:YES];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        
        //是否显示地理信息,查看用户是否设置显示地理信息
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if ([[userDefault objectForKey:@"displayAddress"] isEqualToString:@"YES"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"关闭地理位置" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *executeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [userDefault setObject:@"NO" forKey:@"displayAddress"];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = @"不显示地理位置";
                [self.userDefaults setObject:@"NO" forKey:@"displayAddress"];
                [self.userDefaults synchronize];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:executeAction];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开地理位置" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *executeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [userDefault setObject:@"YES" forKey:@"displayAddress"];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = @"显示地理位置";
                [self.userDefaults setObject:@"YES" forKey:@"displayAddress"];
                [self.userDefaults synchronize];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:executeAction];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
            
        }
        
        
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        //清除缓存
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"清楚缓存" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *executeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AVQuery clearAllCachedResults];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:executeAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];

        
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        
        //用户建议反馈
        LCUserFeedbackViewController *feedbackViewController = [[LCUserFeedbackViewController alloc] init];
        feedbackViewController.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
        feedbackViewController.contactHeaderHidden = NO;
        feedbackViewController.feedbackTitle = [AVUser currentUser].username;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
        [self presentViewController:navigationController animated:YES completion: ^{
        }];

    } else if (indexPath.section == 3 && indexPath.row == 1) {
        WLLAboutDailyNoteViewController *aboutController = [[WLLAboutDailyNoteViewController alloc] initWithNibName:@"WLLAboutDailyNoteViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:aboutController animated:YES];
    }
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
