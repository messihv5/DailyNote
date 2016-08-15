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
#import "WLLShareViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

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
    
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    //计算用户获得的总赞数
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
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
        
    AVFile *theBackgroundImageFile = [self.theCurrentUser objectForKey:@"theBackgroundImage"];
    if (theBackgroundImageFile == nil) {
        self.theBackgroundImageView.image = [UIImage imageNamed:@"appIconBackgroundImage"];
    } else {
        [AVFile getFileWithObjectId:theBackgroundImageFile.objectId withBlock:^(AVFile *file, NSError *error) {
            [self.theBackgroundImageView sd_setImageWithURL:[NSURL URLWithString:file.url]];
        }];
    }
    
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
    if (headImageFile == nil) {
        self.headImageView.image = [UIImage imageNamed:@"appIconHeadImage"];
    } else {
        [AVFile getFileWithObjectId:headImageFile.objectId withBlock:^(AVFile *file, NSError *error) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:file.url]];
        }];
    }
    
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
    self.starNumberLabel.text = @"0";
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
    logOutButton.tintColor = [UIColor whiteColor];
    logOutButton.backgroundColor = [UIColor colorWithRed:0.3 green:0.2 blue:0.1 alpha:0.5];
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
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
        NSString *str = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1143422067&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        //进入更多功能的界面
        WLLFunctionController *fucntionController = [[WLLFunctionController alloc] initWithNibName:@"WLLFunctionController"
                                                                                            bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:fucntionController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        
        //进入设置页面
        WLLSettingViewController *viewController = [[WLLSettingViewController alloc] initWithNibName:@"WLLSettingViewController"
                                                                                              bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 3) {
        
        //进入分享页面
        NSArray* imageArray = @[[UIImage imageNamed:@"mNote"]];
        
        if (imageArray) {
            NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1143422067&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
            
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:@"mNote带给你最好的日记体验"
                                             images:imageArray
                                                url:url
                                              title:@"mNote"
                                               type:SSDKContentTypeAuto];
            
            //2、分享（可以弹出我们的分享菜单和编辑界面）
            [ShareSDK showShareActionSheet:nil
                                     items:nil
                               shareParams:shareParams
                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                           
                           switch (state) {
                               case SSDKResponseStateSuccess:
                               {
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                       message:nil
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"确定"
                                                                             otherButtonTitles:nil];
                                   [alertView show];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   NSString *message = [NSString stringWithFormat:@"%@", error];
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                   message:message
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
                                   break;
                               }
                               default:
                                   break;
                           }
                       }  
             ];}
    }
}

#pragma mark - 数组添加数据
- (void)addData {
    self.data = [NSMutableArray array];
    NSMutableArray *firstSection = [NSMutableArray array];
    
    SystemModel *userDocumentModel = [[SystemModel alloc] init];
    userDocumentModel.systemImage = [UIImage imageNamed:@"editPersonalInfo"];
    userDocumentModel.systemString = @"资料修改";
    
    SystemModel *collectionModel = [[SystemModel alloc] init];
    collectionModel.systemImage = [UIImage imageNamed:@"personalCollection"];
    collectionModel.systemString = @"个人收藏";
    
    [firstSection addObject:userDocumentModel];
    [firstSection addObject:collectionModel];
    [self.data addObject:firstSection];
    
    NSMutableArray *thirdSection = [NSMutableArray array];
    SystemModel *encourageModel = [[SystemModel alloc] init];
    encourageModel.systemImage = [UIImage imageNamed:@"evaluateApp"];
    encourageModel.systemString = @"给予好评";
    
    SystemModel *moreFunctionModel = [[SystemModel alloc] init];
    moreFunctionModel.systemImage = [UIImage imageNamed:@"moreUserFunction"];
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

//通过数据库查询用户的nickName和signature
- (void)searchForNickNameAndSignature {
    
    self.nickNameLabel.text = [self.theCurrentUser objectForKey:@"nickName"];
    self.signatureLabel.text = [self.theCurrentUser objectForKey:@"signature"];
}

#pragma mark - 轻击手势切换背景图片
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

//轻击手势选取头像图片
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    
    self.isHeadImageView = YES;
                                          
}

//选图片代理方法
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    
    CGFloat scaleBetweenWidthAndHeight = pickedImage.size.width / pickedImage.size.height;
    
    CGSize size = CGSizeMake(2.0 / 3.0 * kHeight * scaleBetweenWidthAndHeight, 2.0 / 3.0 * kHeight);
    
    UIImage *compressedImage = [[self class] imageWithImageSimple:pickedImage scaledToSize:size];
    
    NSData *imageData = nil;
    
    NSString *string = nil;
    
    if (UIImageJPEGRepresentation(compressedImage, 1)) {
        imageData = UIImageJPEGRepresentation(compressedImage, 1);
        string = @".jpg";
    } else if (UIImagePNGRepresentation(compressedImage)) {
        imageData = UIImagePNGRepresentation(compressedImage);
        string = @".png";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];

    //判断是点击背景图片还是图像图片
    if (self.isTheBackgroundImageView == YES) {
        NSString *imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"theBackgroundImage%@", string]];
        
        [imageData writeToFile:imagePath atomically:YES];
        
        self.theBackgroundImageView.image = compressedImage;
        
        AVFile *file = [AVFile fileWithData:imageData];
        
        [self.theCurrentUser setObject:file forKey:@"theBackgroundImage"];
        self.isTheBackgroundImageView = NO;
    } else if (self.isHeadImageView == YES) {
        NSString *imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"headImage%@", string]];
        
        [imageData writeToFile:imagePath atomically:YES];

        self.headImageView.image = compressedImage;
        
        AVFile *file = [AVFile fileWithData:imageData];
        
        [self.theCurrentUser setObject:file forKey:@"headImage"];
        self.isHeadImageView = NO;
    }
    
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  压缩图片
 *
 *  @param image   被压缩的image
 *  @param newSize 压缩后的尺寸
 *
 *  @return 压缩后得到的image
 */
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    // Get the new image from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
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
