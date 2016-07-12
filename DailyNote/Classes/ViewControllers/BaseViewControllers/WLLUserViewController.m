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
#import "WLLFunctionController.h"
#import "WLLSettingViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "WLLShareViewController.h"

@interface WLLUserViewController ()<UITableViewDelegate,
                                    UITableViewDataSource,
                                    UIScrollViewDelegate,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *userTableView;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UIImageView *theBackgroundImageView;
@property (strong, nonatomic) UIImageView *fuckImageView;
@property (strong, nonatomic) UILabel *nickNameLabel;
@property (strong, nonatomic) UIImageView *starImageView;
@property (strong, nonatomic) UILabel *starNumberLabel;
@property (strong, nonatomic) UILabel *signatureLabel;
@property (strong, nonatomic) AppDelegate *userDelegate;
@property (strong, nonatomic) NSManagedObjectContext *userContext;
@property (assign, nonatomic) BOOL isTheBackgroundImageView;
@property (assign, nonatomic) BOOL isHeadImageView;
@property (strong, nonatomic) AVUser *theCurrentUser;

@end

@implementation WLLUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //得到当前用户
    self.theCurrentUser = [AVUser currentUser];
    
    [self settingTableViewHeaderView];
    
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    
    [self addData];
    
    [self.userTableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"CW_Cell"];
    
    //设置返回键名字，使下一页面的返回键显示“返回”
    UIBarButtonItem *theBarButtonItem = [[UIBarButtonItem alloc] init];
    theBarButtonItem.title = @"返回";
    self.parentViewController.navigationItem.backBarButtonItem = theBarButtonItem;
    
    //查询nickName及signature
    [self searchForNickNameAndSignature];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    //计算用户获得的总赞数
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
//    [query whereKey:@"isPrivate" equalTo:@"public"];
    [query whereKey:@"belong" equalTo:self.theCurrentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSInteger totalStar = 0;
        if (error == nil) {
            for (AVObject *object in objects) {
                NSNumber *num = [object objectForKey:@"starNumber"];
                totalStar = totalStar + [num integerValue];
            }
        }
        self.starNumberLabel.text = [NSString stringWithFormat:@"%ld", totalStar];
        [self.theCurrentUser setObject:self.starNumberLabel.text forKey:@"starNumber"];
        [self.theCurrentUser saveInBackground];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

#pragma mark - 设置tableHeaderView
- (void)settingTableViewHeaderView {
    
    //查询背景图片和
    CGRect viewRect = CGRectMake(0, 0, kWidth, kHeight / 3);
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    view.backgroundColor = [UIColor greenColor];

    self.theBackgroundImageView = [[UIImageView alloc] initWithFrame:viewRect];
    self.theBackgroundImageView.backgroundColor = [UIColor cyanColor];
    
    NSString *nickName = [self.theCurrentUser objectForKey:@"nickName"];
    NSLog(@"%@", nickName);
    
    AVFile *theBackgroundImageFile = [self.theCurrentUser objectForKey:@"theBackgroundImage"];
    
    [self.theBackgroundImageView sd_setImageWithURL:[NSURL URLWithString:theBackgroundImageFile.url]];
    
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(theBackgroudImageViewTapAction)];
    [self.theBackgroundImageView addGestureRecognizer:tapGestureRecognizer];
    self.theBackgroundImageView.userInteractionEnabled = YES;
    [view addSubview:self.theBackgroundImageView];
    
    
    CGRect headImageViewRect = CGRectMake(kWidth / 2 - kHeight / 18, kHeight / 18, kHeight / 9, kHeight / 9);
    self.headImageView = [[UIImageView alloc] initWithFrame:headImageViewRect];
    self.headImageView.backgroundColor = [UIColor purpleColor];
    
    AVFile *headImageFile = [self.theCurrentUser objectForKey:@"headImage"];

    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:headImageFile.url]];
    self.headImageView.layer.cornerRadius = kHeight / 18;
    self.headImageView.layer.masksToBounds = YES;
    
    
    UITapGestureRecognizer *headImageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewTapAction)];
    [self.headImageView addGestureRecognizer:headImageViewTapGestureRecognizer];
    self.headImageView.userInteractionEnabled = YES;
    
    [view addSubview:self.headImageView];
    
    CGRect nickNameLabelRect = CGRectMake(20, CGRectGetMaxY(headImageViewRect) + kHeight / 36, kWidth - 40, kHeight * 5 / 108);
    self.nickNameLabel = [[UILabel alloc] initWithFrame:nickNameLabelRect];
    self.nickNameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.nickNameLabel];
    
    CGRect starImageViewRect = CGRectMake(kWidth / 2  - 10, CGRectGetMaxY(nickNameLabelRect), 20, kHeight * 5 / 108);
    self.starImageView = [[UIImageView alloc] initWithFrame:starImageViewRect];
    self.starImageView.image = [UIImage imageNamed:@"heartSelected15X15"];
    self.starImageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:self.starImageView];
    
    CGRect starNumberLabelRect = CGRectMake(CGRectGetMaxX(starImageViewRect) + 5, starImageViewRect.origin.y, 50, kHeight * 5 / 108);
    self.starNumberLabel = [[UILabel alloc] initWithFrame:starNumberLabelRect];
    self.starNumberLabel.text = @"100";
    self.starNumberLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:self.starNumberLabel];
    
    CGRect signatureLabelRect = CGRectMake(20, CGRectGetMaxY(starNumberLabelRect), kWidth - 40, kHeight * 5 / 108);
    self.signatureLabel = [[UILabel alloc] initWithFrame:signatureLabelRect];
    self.signatureLabel.text = @"Life is so hard now, but you have no choice, you have to move on, man";
    self.signatureLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.signatureLabel];
    self.userTableView.tableHeaderView = view;
    
    CGRect footViewRect = CGRectMake(0, 0, kWidth, 100);
    UIView *footView = [[UIView alloc] initWithFrame:footViewRect];
    
    CGRect logOutButtonRect = CGRectMake(kWidth / 2 - 100, 10, 200, 30);
    UIButton *logOutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [logOutButton setTitle:@"退出系统" forState:UIControlStateNormal];
    logOutButton.backgroundColor = [UIColor greenColor];
    logOutButton.titleLabel.font = [UIFont systemFontOfSize:20];
    logOutButton.frame = logOutButtonRect;
    [footView addSubview:logOutButton];
    [logOutButton addTarget:self action:@selector(logOutAction:) forControlEvents:UIControlEventTouchUpInside];
    logOutButton.layer.cornerRadius = 5;
    
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
    if (indexPath.row == 0 && indexPath.section == 0) {
        
        //修改nickName和signature
        WLLModifyInfomationViewController *modifyVC = [[WLLModifyInfomationViewController alloc] initWithNibName:@"WLLModifyInfomationViewController" bundle:[NSBundle mainBundle]];
        [self.parentViewController.navigationController pushViewController:modifyVC animated:YES];
        
        modifyVC.nickNameString = self.nickNameLabel.text;
        modifyVC.signatureString = self.signatureLabel.text;
        
        //block反向传值实现
        modifyVC.block = ^ (NSString *nickName, NSString *signature) {
            self.nickNameLabel.text = nickName;
            self.signatureLabel.text = signature;
        };
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        
        //进入收藏页面
        WLLShareViewController *shareController = [[WLLShareViewController alloc] initWithNibName:@"WLLShareViewController" bundle:[NSBundle mainBundle]];
        
        //传入indexpath作为从这个页面推过去的标记，而不是分享页面
        shareController.passedIndexPath = indexPath;
        [self.navigationController pushViewController:shareController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        
        //进入AppStore去评价
        NSString *str = @"https://itunes.apple.com/us/app/wu-ji-zuo-zui-hao-jing-zhi/id1084747109?mt=8";
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        //进入更多功能的界面
        WLLFunctionController *fucntionController = [[WLLFunctionController alloc] initWithNibName:@"WLLFunctionController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:fucntionController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        
        //进入设置页面
        WLLSettingViewController *viewController = [[WLLSettingViewController alloc] initWithNibName:@"WLLSettingViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 3) {
        
        //进入分享页面
//        NSArray* imageArray = @[[UIImage imageNamed:@"blue_circle"]];
//        if (imageArray) {
//            
//            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//            [shareParams SSDKSetupShareParamsByText:@"分享内容"
//                                             images:imageArray
//                                                url:[NSURL URLWithString:@"http://mob.com"]
//                                              title:@"分享标题"
//                                               type:SSDKContentTypeAuto];
//            //2、分享（可以弹出我们的分享菜单和编辑界面）
//            [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                     items:nil
//                               shareParams:shareParams
//                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//                           
//                           switch (state) {
//                               case SSDKResponseStateSuccess:
//                               {
//                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                       message:nil
//                                                                                      delegate:nil
//                                                                             cancelButtonTitle:@"确定"
//                                                                             otherButtonTitles:nil];
//                                   [alertView show];
//                                   break;
//                               }
//                               case SSDKResponseStateFail:
//                               {
//                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                                   message:[NSString stringWithFormat:@"%@",error]
//                                                                                  delegate:nil
//                                                                         cancelButtonTitle:@"OK"
//                                                                         otherButtonTitles:nil, nil];
//                                   [alert show];
//                                   break;
//                               }
//                               default:
//                                   break;
//                           }
//                       }  
//             ];}
    }
}

#pragma mark - 数组添加数据

- (void)addData {
    self.data = [NSMutableArray array];
    NSMutableArray *firstSection = [NSMutableArray array];
    
    SystemModel *userDocumentModel = [[SystemModel alloc] init];
    userDocumentModel.systemImage = [UIImage imageNamed:@"changeUserInformation"];
    userDocumentModel.systemString = @"资料修改";
    
    SystemModel *collectionModel = [[SystemModel alloc] init];
    collectionModel.systemImage = [UIImage imageNamed:@"systemNotice2"];
    collectionModel.systemString = @"个人收藏";
    
    [firstSection addObject:userDocumentModel];
    [firstSection addObject:collectionModel];
    [self.data addObject:firstSection];
    
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
    
    [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
    
}

#pragma mark - tableview下拉滚动视图

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.y;
    if (offset < 0) {
        CGFloat heightAfterScroll = kHeight / 3 - (offset);
        CGFloat zoomingScale = heightAfterScroll / (kHeight / 3);
        self.theBackgroundImageView.frame = CGRectMake(-(kWidth * zoomingScale - kWidth) / 2, offset,
                                                       kWidth * zoomingScale, heightAfterScroll);
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
    self.nickNameLabel.text = [self.theCurrentUser objectForKey:@"nickName"];
    self.signatureLabel.text = [self.theCurrentUser objectForKey:@"signature"];
    
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
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:@"相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换图像"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    //判断是点击背景图片还是图像图片
    if (self.isTheBackgroundImageView == YES) {
        self.theBackgroundImageView.image = info[UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(self.theBackgroundImageView.image);
        AVFile *file = [AVFile fileWithData:data];
        [self.theCurrentUser setObject:file forKey:@"theBackgroundImage"];
        self.isTheBackgroundImageView = NO;
    } else if (self.isHeadImageView == YES) {
        self.headImageView.image = info[UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(self.headImageView.image);
        AVFile *file = [AVFile fileWithData:data];
        [self.theCurrentUser setObject:file forKey:@"headImage"];
        self.isHeadImageView = NO;
    }
    
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"hey i' here");
    return UIStatusBarStyleLightContent;
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
