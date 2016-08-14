//
//  WLLFunctionController.m
//  DailyNote
//
//  Created by Messi on 16/6/6.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLFunctionController.h"
#import "SystemModel.h"
#import "WLLSetReminderTimeViewController.h"
#import "WLLDailyNoteViewController.h"
#import "WLLDailyNoteDataManager.h"

@interface WLLFunctionController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *functionTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation WLLFunctionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //获取用户信息
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    //加载数据
    [self loadData];
    
    self.navigationItem.title = @"更多功能";
    
    self.functionTableView.delegate = self;
    self.functionTableView.dataSource = self;
    
}

//懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}

//创建tableview的标题
- (void)loadData {
    NSMutableArray *firstSection = [NSMutableArray array];
    
    SystemModel *reminderModel = [[SystemModel alloc] init];
    reminderModel.systemString = @"提醒写日记";
    [firstSection addObject:reminderModel];
    [self.data addObject:firstSection];
    
    NSMutableArray *secondSection = [NSMutableArray array];
    SystemModel *dustbinModel = [[SystemModel alloc] init];
    dustbinModel.systemString = @"垃圾箱";
    [secondSection addObject:dustbinModel];
    [self.data addObject:secondSection];
}

#pragma mark - tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CW_Cell"];
    }
    
    SystemModel *model = self.data[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = model.systemString;
    if (indexPath.section == 0) {
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        NSArray *channels = currentInstallation.channels;
        
        if (channels.count != 0) {
            cell.detailTextLabel.text = channels[0];
        } else {
            cell.detailTextLabel.text = @"已关闭";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        //提醒写日记
        WLLSetReminderTimeViewController *reminderController = [[WLLSetReminderTimeViewController alloc] initWithNibName:@"WLLSetReminderTimeViewController" bundle:[NSBundle mainBundle]];
        
        //反向传值
        reminderController.block = ^ (NSString *string) {
            [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = string;
        };
        [self.navigationController pushViewController:reminderController animated:YES];
    } else if (indexPath.section == 1) {
        
        //进入回收站
        WLLDailyNoteViewController *dailyNoteVC;
        dailyNoteVC = [[WLLDailyNoteViewController alloc] initWithNibName:@"WLLDailyNoteViewController"
                                                                   bundle:[NSBundle mainBundle]];
        dailyNoteVC.isFromRecycle = YES;
        [self.navigationController pushViewController:dailyNoteVC animated:YES];
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
