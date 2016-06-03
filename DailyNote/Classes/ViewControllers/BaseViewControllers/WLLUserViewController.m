//
//  WLLUserViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLUserViewController.h"
#import "SystemModel.h"
#import "WLLLogInViewController.h"
#import "WLLModifyInfomationViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"


//屏幕宽高
#define UIScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define UIScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface WLLUserViewController ()<UITableViewDelegate,
                                    UITableViewDataSource,
                                    UIScrollViewDelegate,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *userTableView;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UIImageView *theBackgroundImageView;
@property (strong, nonatomic) UILabel *nickNameLabel;
@property (strong, nonatomic) UIImageView *starImageView;
@property (strong, nonatomic) UILabel *starNumberLabel;
@property (strong, nonatomic) UILabel *signatureLabel;
@property (strong, nonatomic) AppDelegate *userDelegate;
@property (strong, nonatomic) NSManagedObjectContext *userContext;
@property (assign, nonatomic) BOOL isTheBackgroundImageView;
@property (assign, nonatomic) BOOL isHeadImageView;

@end

@implementation WLLUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置userTableView的代理
    self.parentViewController.navigationController.navigationBar.opaque = YES;
    self.automaticallyAdjustsScrollViewInsets = YES
    ;
    [self settingTableViewHeaderView];
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    
    [self addData];
    
    [self.userTableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"CW_Cell"];
    
    //设置返回键名字，使下以页面的返回键显示“返回”
    UIBarButtonItem *theBarButtonItem = [[UIBarButtonItem alloc] init];
    theBarButtonItem.title = @"返回";
    self.parentViewController.navigationItem.backBarButtonItem = theBarButtonItem;
    
    //查询nickName及signature
    [self searchForNickNameAndSignature];
    
}

#pragma mark - 设置tableHeaderView
- (void)settingTableViewHeaderView {
    CGRect viewRect = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight / 3);
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    view.backgroundColor = [UIColor greenColor];
    
    self.theBackgroundImageView = [[UIImageView alloc] initWithFrame:viewRect];
    self.theBackgroundImageView.backgroundColor = [UIColor grayColor];
    self.theBackgroundImageView.image = [UIImage imageNamed:@"scenery"];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(theBackgroudImageViewTapAction)];
    [self.theBackgroundImageView addGestureRecognizer:tapGestureRecognizer];
    self.theBackgroundImageView.userInteractionEnabled = YES;

    [view addSubview:self.theBackgroundImageView];
    
    
    CGRect headImageViewRect = CGRectMake(UIScreenWidth / 2 - UIScreenHeight / 18, UIScreenHeight / 9 - 30, UIScreenHeight / 9, UIScreenHeight / 9);
    self.headImageView = [[UIImageView alloc] initWithFrame:headImageViewRect];
    self.headImageView.backgroundColor = [UIColor blueColor];
    self.headImageView.image = [UIImage imageNamed:@"wanting"];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = UIScreenHeight / 18;
    
    UITapGestureRecognizer *headImageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewTapAction)];
    [self.headImageView addGestureRecognizer:headImageViewTapGestureRecognizer];
    self.headImageView.userInteractionEnabled = YES;
    
    [view addSubview:self.headImageView];
    
    CGRect nickNameLabelRect = CGRectMake(20, CGRectGetMaxY(headImageViewRect) + 10, UIScreenWidth - 40, 20);
    self.nickNameLabel = [[UILabel alloc] initWithFrame:nickNameLabelRect];
//    self.nickNameLabel.text = @"LionelMessi";
    self.nickNameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.nickNameLabel];
    
    CGRect starImageViewRect = CGRectMake(UIScreenWidth / 2  - 10, CGRectGetMaxY(nickNameLabelRect) + 10, 20, 20);
    self.starImageView = [[UIImageView alloc] initWithFrame:starImageViewRect];
    self.starImageView.image = [UIImage imageNamed:@"star"];
    [view addSubview:self.starImageView];
    
    CGRect starNumberLabelRect = CGRectMake(CGRectGetMaxX(starImageViewRect) + 5, starImageViewRect.origin.y, 50, 20);
    self.starNumberLabel = [[UILabel alloc] initWithFrame:starNumberLabelRect];
    self.starNumberLabel.text = @"100";
    self.starNumberLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:self.starNumberLabel];
    
    CGRect signatureLabelRect = CGRectMake(20, CGRectGetMaxY(starNumberLabelRect) + 10, UIScreenWidth - 40, 40);
    self.signatureLabel = [[UILabel alloc] initWithFrame:signatureLabelRect];
    self.signatureLabel.text = @"Life is so hard now, but you have no choice, you have to move on, man";
    self.signatureLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.signatureLabel];
    
    self.userTableView.tableHeaderView = view;
    
    CGRect footViewRect = CGRectMake(0, 0, UIScreenWidth, 80);
    UIView *footView = [[UIView alloc] initWithFrame:footViewRect];
    
    CGRect logOutButtonRect = CGRectMake(UIScreenWidth / 2 - 100, 10, 200, 30);
    UIButton *logOutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [logOutButton setTitle:@"退出系统" forState:UIControlStateNormal];
    logOutButton.backgroundColor = [UIColor greenColor];
    logOutButton.titleLabel.font = [UIFont systemFontOfSize:20];
    logOutButton.frame = logOutButtonRect;
    [footView addSubview:logOutButton];
    [logOutButton addTarget:self action:@selector(logOutAction:) forControlEvents:UIControlEventTouchUpInside];
    logOutButton.layer.cornerRadius = 2;
    
    self.userTableView.tableFooterView = footView;
    
}
#pragma mark - tableView代理方法设置
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW_Cell"
                                                            forIndexPath:indexPath];
    SystemModel *cellModel = self.data[indexPath.section][indexPath.row];
    cell.imageView.image = cellModel.systemImage;
    cell.textLabel.text = cellModel.systemString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        WLLModifyInfomationViewController *modifyVC = [[WLLModifyInfomationViewController alloc] initWithNibName:@"WLLModifyInfomationViewController" bundle:[NSBundle mainBundle]];
        [self.parentViewController.navigationController pushViewController:modifyVC animated:YES];
        
        modifyVC.nickNameString = self.nickNameLabel.text;
        modifyVC.signatureString = self.signatureLabel.text;
        
        modifyVC.block = ^ (NSString *nickNameString, NSString *signatureString) {
            self.nickNameLabel.text = nickNameString;
            self.signatureLabel.text = signatureString;
        };
    }
}

#pragma mark - 数组添加数据
- (void)addData {
    self.data = [NSMutableArray array];
    NSMutableArray *firstSection = [NSMutableArray array];
    SystemModel *userDocumentModel = [[SystemModel alloc] init];
    userDocumentModel.systemImage = [UIImage imageNamed:@"changeUserInformation"];
    userDocumentModel.systemString = @"资料修改";
    SystemModel *upGradeModel = [[SystemModel alloc] init];
    upGradeModel.systemImage = [UIImage imageNamed:@"UpGrade"];
    upGradeModel.systemString = @"升级账户";
    [firstSection addObject:userDocumentModel];
    [firstSection addObject:upGradeModel];
    [self.data addObject:firstSection];
    
    NSMutableArray *secondSection = [NSMutableArray array];
    SystemModel *systemNoticeModel = [[SystemModel alloc] init];
    systemNoticeModel.systemImage = [UIImage imageNamed:@"systemNotice2"];
    systemNoticeModel.systemString = @"系统通知";
    [secondSection addObject:systemNoticeModel];
    [self.data addObject:secondSection];
    
    NSMutableArray *thirdSection = [NSMutableArray array];
    
    SystemModel *encourageModel = [[SystemModel alloc] init];
    encourageModel.systemImage = [UIImage imageNamed:@"encourage"];
    encourageModel.systemString = @"给予好评";
    
    SystemModel *moreFunctionModel = [[SystemModel alloc] init];
    moreFunctionModel.systemImage = [UIImage imageNamed:@"moreFunction"];
    moreFunctionModel.systemString = @"更多功能";
    
    SystemModel *settingModel = [[SystemModel alloc] init];
    settingModel.systemImage = [UIImage imageNamed:@"setting"];
    settingModel.systemString = @"设置";
    
    SystemModel *shareModel = [[SystemModel alloc] init];
    shareModel.systemImage = [UIImage imageNamed:@"share"];
    shareModel.systemString = @"分享给朋友";
    
    [thirdSection addObject:encourageModel];
    [thirdSection addObject:moreFunctionModel];
    [thirdSection addObject:settingModel];
    [thirdSection addObject:shareModel];
    [self.data addObject:thirdSection];
    
    
}

#pragma mark - 退出系统
- (void)logOutAction:(UIButton *)sender {
    [AVUser logOut];
    WLLLogInViewController *logInViwController = [[WLLLogInViewController alloc] initWithNibName:@"WLLLogInViewController" bundle:[NSBundle mainBundle]];
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:logInViwController];
    UITabBarController *controller = (UITabBarController *)self.parentViewController;
    controller.selectedIndex = 0;
    [self.navigationController presentViewController:naviController animated:YES completion:nil];
    
//    [[[UIApplication sharedApplication] delegate ] application:[UIApplication sharedApplication]
//                                 didFinishLaunchingWithOptions:nil]  ;
}

#pragma mark - tableview下拉滚动视图
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (offset < 0) {
        CGFloat heightAfterScroll = UIScreenHeight / 3 - (offset);
        CGFloat zoomingScale = heightAfterScroll / (UIScreenHeight / 3);
        
        self.theBackgroundImageView.frame = CGRectMake(-(UIScreenWidth * zoomingScale - UIScreenWidth) / 2, offset, UIScreenWidth * zoomingScale, heightAfterScroll);
    }
}

#pragma mark - 使用coreData查询用户的nickName及signature
- (void)searchForNickNameAndSignature {
    
    //CoreData查询用户的nickName和signature
    /*
    //创建查询对象
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //创建查询实体
    self.userDelegate = [UIApplication sharedApplication].delegate;
    self.userContext = self.userDelegate.managedObjectContext;
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.userContext];
    [fetchRequest setEntity:description];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.userContext executeFetchRequest:fetchRequest error:&error];
    UserInfo *userInfo = fetchedObjects[0];
    self.nickNameLabel.text = userInfo.nickName;
    self.signatureLabel.text = userInfo.signature;*/
    
    //通过数据库查询用户的nickName和signature
    AVUser *user = [AVUser currentUser];
    self.nickNameLabel.text = [user objectForKey:@"nickName"];
    self.signatureLabel.text = [user objectForKey:@"signature"];
    
}

#pragma mark - 轻击手势切换图片
- (void)theBackgroudImageViewTapAction {
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更换背景" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil ];
    }];
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:@"相册选取" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:pictureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    self.isTheBackgroundImageView = YES;
}

- (void)headImageViewTapAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换图像" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    
    self.isHeadImageView = YES;
                                          
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (self.isTheBackgroundImageView == YES) {
        self.theBackgroundImageView.image = info[UIImagePickerControllerOriginalImage];
        self.isTheBackgroundImageView = NO;
    } else if (self.isHeadImageView == YES) {
        self.headImageView.image = info[UIImagePickerControllerOriginalImage];
        self.isHeadImageView = NO;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
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
