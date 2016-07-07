//
//  WLLPrivateCodeViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLPrivateCodeViewController.h"
#import "PrivateModel.h"
#import "WChaoPrivateCodeCellTableViewCell.h"
#import "WLLLockViewController.h"

@interface WLLPrivateCodeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSUserDefaults *userDefault;

@end

@implementation WLLPrivateCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"设置手势锁";
    
    [self loadData];

    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    [self.theTableView registerNib:[UINib nibWithNibName:@"WChaoPrivateCodeCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW"];
    
    //拿到userDefault
    self.userDefault = [NSUserDefaults standardUserDefaults];
    
}

//懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray arrayWithCapacity:5];
    }
    return _data;
}

//加载数据
- (void)loadData {
    NSMutableArray *firstArray = [NSMutableArray arrayWithCapacity:5];
    PrivateModel *firstModel = [[PrivateModel alloc] init];
    firstModel.titleString = @"隐私密码";
    firstModel.detailString = @"开启后每次打开DailyNote需要输入该密码";
    [firstArray addObject:firstModel];
    [self.data addObject:firstArray];
}

#pragma mark - tableView的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.data[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WChaoPrivateCodeCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW"
                                                                              forIndexPath:indexPath];
    //从当前用户获取是否开启锁屏功能
    NSString *swithOnOrNot = [[AVUser currentUser] objectForKey:@"isLocked"];
    
    if ([swithOnOrNot isEqualToString:@"YES"]) {
        cell.privateCodeSwith.on = YES;
    } else {
        cell.privateCodeSwith.on = NO;
    }
    
    PrivateModel *model = self.data[indexPath.section][indexPath.row];
    cell.titleLabel.text = model.titleString;
    cell.instructionLabel.text = model.detailString;
    [cell.privateCodeSwith addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

//开关解屏密码方法
- (void)switchAction:(UISwitch *)sender {
    if (sender.on == YES) {
        
        //解屏锁为关的时候，就去设定解屏锁
        WLLLockViewController *lockController = [[WLLLockViewController alloc] init];
        lockController.indexPath = [self.theTableView indexPathForCell:(WChaoPrivateCodeCellTableViewCell *)[[sender superview] superview]];
        [self.navigationController pushViewController:lockController animated:YES];
        
        //在userDefault里设置手势锁为开
//        [self.userDefault setObject:@"YES" forKey:@"privateCode"];
//        [self.userDefault synchronize];
        
        //在当前用户里设置解屏锁为开
        [[AVUser currentUser] setObject:@"YES" forKey:@"isLocked"];
        [[AVUser currentUser] saveInBackground];
        
    } else {
        
        //解屏锁为开的时候，解除解屏锁
//        [self.userDefault setObject:@"NO" forKey:@"privateCode"];
//        [self.userDefault synchronize];
        
        [[AVUser currentUser] setObject:@"NO" forKey:@"isLocked"];
        [[AVUser currentUser] saveInBackground];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已取消手势锁" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        //设置NSTimer让alertController过一段时间自动消失
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissAlertAction:) userInfo:alertController repeats:NO];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

//取消alertController的操作
- (void)dismissAlertAction:(NSTimer*)timer {
    UIAlertController *alertController = timer.userInfo;
    [alertController dismissViewControllerAnimated:YES completion:nil];
    alertController = nil;
};

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
