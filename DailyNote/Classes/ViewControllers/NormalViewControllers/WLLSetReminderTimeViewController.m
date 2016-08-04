//
//  WLLSetReminderTimeViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLSetReminderTimeViewController.h"
#import "WChaoReminderCellTableViewCell.h"
#import "WChaoPrivateCodeCellTableViewCell.h"
#import "WLLTimePickerController.h"

@interface WLLSetReminderTimeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *remindreTableView;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
/**
 *  是否支持改变日记提醒时间
 */
@property (assign, nonatomic) BOOL isReminderTimeChangable;

@end

@implementation WLLSetReminderTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //获取到用户的信息
//    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.title = @"提醒写日记";
    
    self.remindreTableView.delegate = self;
    self.remindreTableView.dataSource = self;
    
    [self.remindreTableView registerNib:[UINib nibWithNibName:@"WChaoPrivateCodeCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW"];
    [self.remindreTableView registerNib:[UINib nibWithNibName:@"WChaoReminderCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW2"];
    
    //自定义导航栏的leftBarbuttonItem
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 44);
    [button setTitle:@"更多功能" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"backButton2"] forState:UIControlStateNormal];
    
    //向左偏移使button的位置合适
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

//自定义导航栏按钮的方法
- (void)backAction {
    NSString *reminder = [[AVUser currentUser] objectForKey:@"noteReminder"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    WChaoReminderCellTableViewCell *cell = [self.remindreTableView cellForRowAtIndexPath:indexPath];
    NSString *time = cell.changeTimeButton.titleLabel.text;
    if ([reminder isEqualToString:@"YES"]) {
        self.block(time);
    } else {
        self.block(@"已关闭");
    }
    
    //把该状态设置到userDefault里面
    [[AVUser currentUser] setObject:time forKey:@"reminderTime"];
    [[AVUser currentUser] saveInBackground];

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
        WChaoPrivateCodeCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW" forIndexPath:indexPath];
        
        //判断提醒日记的开关状态
        NSString *reminder = [[AVUser currentUser] objectForKey:@"noteReminder"];
        if ([reminder isEqualToString:@"YES"]) {
            cell.privateCodeSwith.on = YES;
        } else {
            cell.privateCodeSwith.on = NO;
        }
        
        cell.titleLabel.text = @"提醒写日记";
        cell.instructionLabel.text = @"关闭后将不在提醒写日记";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.privateCodeSwith addTarget:self action:@selector(reminderSwitch:) forControlEvents:UIControlEventValueChanged];
        return cell;
    } else {
        
        //从用户数据里面获取写日记的提醒时间
        NSString *reminderTime = [[AVUser currentUser] objectForKey:@"reminderTime"];
        
        WChaoReminderCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW2" forIndexPath:indexPath];
        cell.titleLabel.text = @"提醒时间";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.changeTimeButton addTarget:self action:@selector(changeReminderTimeAction:)
                        forControlEvents:UIControlEventTouchUpInside];
        [cell.changeTimeButton setTitle:reminderTime forState:UIControlStateNormal];
        return cell;
    }
    return nil;
}

//开关日记提醒
- (void)reminderSwitch:(UISwitch *)sender {
    if (sender.on == YES) {
        [[AVUser currentUser] setObject:@"YES" forKey:@"noteReminder"];
        [[AVUser currentUser] saveInBackground];
        
    } else {
        [[AVUser currentUser] setObject:@"NO" forKey:@"noteReminder"];
        [[AVUser currentUser] saveInBackground];
    }
}

//改变日记提醒时间方法
- (void)changeReminderTimeAction:(UIButton *)sender {
    if (self.isReminderTimeChangable == NO) {
        return;
    }
    
    WLLTimePickerController *timeController = [[WLLTimePickerController alloc] initWithNibName:@"WLLTimePickerController" bundle:[NSBundle mainBundle]];
    
    timeController.block = ^ (NSString *string) {
        WChaoReminderCellTableViewCell *cell = (WChaoReminderCellTableViewCell *)[[sender superview] superview];
        [cell.changeTimeButton setTitle:string forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:timeController animated:YES];
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
