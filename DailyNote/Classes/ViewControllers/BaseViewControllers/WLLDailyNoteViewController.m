//
//  WLLDailyNoteViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLDailyNoteViewController.h"
#import "DailyNoteCell.h"
#import "WLLNoteDetailViewController.h"
#import "EditNoteViewController.h"
#import "WLLCategoryButton.h"
#import "WLLNotesCategoryView.h"
#import "NoteDetail.h"
#import "WLLDailyNoteDataManager.h"
#import "WLLDailyNoteDataManager.h"
#import "WLLLogInViewController.h"

#define kWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface WLLDailyNoteViewController ()<UITableViewDelegate, UITableViewDataSource>
/* 日记页面 */
@property (weak, nonatomic) IBOutlet UITableView *notesTableView;
/* 日记分类页面 */
@property (nonatomic, strong) UITableView *notesCategoryView;
/* 判断日记分类页面隐藏与否 */
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
//messi did this
@property (strong, nonatomic) UIImage *firstPageImage;
//导航栏颜色
@property (strong, nonatomic) UIColor *theBarTintColor;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) AVUser *theCurrentUser;

@end

static NSString  *const reuseIdentifier = @"note_cell";

@implementation WLLDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // notesTableView 代理设置
    self.notesTableView.delegate = self;
    self.notesTableView.dataSource = self;
    // 注册 NoteCell
    [self.notesTableView registerNib:[UINib nibWithNibName:@"DailyNoteCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    // 设置分类button
    
    // 加载分类页面
    [self initCategoryView];
    
    // 请求数据
    [[WLLDailyNoteDataManager sharedInstance] requestDataAndFinished:^{
        [self.notesTableView reloadData];
    }];
    
    
    [WLLDailyNoteDataManager sharedInstance].topicImage = [self imageWithView:self.view];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
}



// 初始化分类页面按钮
- (void)initNaviButton {
    WLLCategoryButton *titleButton = [WLLCategoryButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, kWidth*0.2, kWidth*0.0725);
    [titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [titleButton setTitle:@"全部" forState:UIControlStateNormal];
    
    [titleButton addTarget:self action:@selector(notesCategory:) forControlEvents:UIControlEventTouchUpInside];
    
    self.parentViewController.navigationItem.titleView = titleButton;
}

// 加载分类页面初始位置
- (void)initCategoryView {
    
    [super viewDidAppear:YES];
    
    // 分类页面初始为隐藏
    self.hidden = YES;
    // 分类页面初始位置在屏幕以外, 将其高度设置为0
    self.notesCategoryView = [[WLLNotesCategoryView alloc] initWithFrame:CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0) style:UITableViewStylePlain];
    
    self.notesCategoryView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.notesCategoryView];
}

// 分类按钮响应
- (void)notesCategory:(UIButton *)button {
    
    // 如果分类页面隐藏, 则显示
    if (self.isHidden == YES) {
        // 为其高度赋值即可
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, kWidth*1.2077);
            [button setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }];
        // 将分类页面置为显示
        self.hidden = NO;
    }
    // 如果分类页面显示, 则隐藏
    else if (self.isHidden == NO) {
        // 将其高度更改为0
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0);
            [button setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }];
        // 分类页面隐藏
        self.hidden = YES;
    }
}

//在视图已出现的时候渲染image，保存所需的4种颜色的类型，最后的一种将显示在界面上
- (void)viewDidAppear:(BOOL)animated {
    
    //进入app时，弹出登录界面，如果用户没有退出系统，再进入时不用弹出登录界面
    if (![AVUser currentUser]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WLLLogInViewController *logController;
            logController = [[WLLLogInViewController alloc] initWithNibName:@"WLLLogInViewController"
                                                                     bundle:[NSBundle mainBundle]];
            UINavigationController *naviController;
            naviController= [[UINavigationController alloc] initWithRootViewController:logController];
            [self.parentViewController.navigationController presentViewController:naviController animated:NO completion:nil];
        });
    }

    //获取当前的导航栏和tab栏
    UITabBar *tabbar = self.tabBarController.tabBar;
    UINavigationBar *bar = self.tabBarController.navigationController.navigationBar;
    
    //第一次进入页面时，获取四种颜色的image
    NSData *imageData = [self.userDefaults objectForKey:@"navigationImagesAndTabbarImages"];
    if (imageData == nil) {
        NSMutableData *navigationImagesAndTabbarImages = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:navigationImagesAndTabbarImages];

        [tabbar setTintColor:[UIColor lightGrayColor]];
        [bar setBarTintColor:[UIColor lightGrayColor]];
        UIImage *tabbarImage4 = [self imageWithView:tabbar];
        UIImage *navigationImage4 = [self imageWithView:bar];
        
        [tabbar setTintColor:[UIColor darkTextColor]];
        [bar setBarTintColor:[UIColor darkTextColor]];
        UIImage *tabbarImage2 = [self imageWithView:tabbar];
        UIImage *navigationImage2 = [self imageWithView:bar];
        
        [tabbar setTintColor:[UIColor redColor]];
        [bar setBarTintColor:[UIColor redColor]];
        UIImage *tabbarImage3 = [self imageWithView:tabbar];
        UIImage *navigationImage3 = [self imageWithView:bar];
        
        [tabbar setTintColor:[UIColor blueColor]];
        [bar setBarTintColor:[UIColor blueColor]];
        UIImage *tabbarImage1 = [self imageWithView:tabbar];
        UIImage *navigationImage1 = [self imageWithView:bar];
        
        [archiver encodeObject:tabbarImage1 forKey:@"tabbarImage1"];
        [archiver encodeObject:navigationImage1 forKey:@"navigationImage1"];
        [archiver encodeObject:tabbarImage2 forKey:@"tabbarImage2"];
        [archiver encodeObject:navigationImage2 forKey:@"navigationImage2"];
        [archiver encodeObject:tabbarImage3 forKey:@"tabbarImage3"];
        [archiver encodeObject:navigationImage3 forKey:@"navigationImage3"];
        [archiver encodeObject:tabbarImage4 forKey:@"tabbarImage4"];
        [archiver encodeObject:navigationImage4 forKey:@"navigationImage4"];
        [archiver finishEncoding];
        
        //保存在NSUserDefaults里面，使得在同一手机登录的用户主题相同
        [self.userDefaults setObject:navigationImagesAndTabbarImages forKey:@"navigationImagesAndTabbarImages"];
        [self.userDefaults synchronize];
    }
    
    //从currentUser的navigationColor字段获取颜色
    NSString *colorString = [[AVUser currentUser] objectForKey:@"navigationColor"];
    if (colorString == nil) {
        [tabbar setTintColor:[UIColor blueColor]];
        [bar setBarTintColor:[UIColor blueColor]];
    } else if ([colorString isEqualToString:@"blue"]){
        [tabbar setTintColor:[UIColor blueColor]];
        [bar setBarTintColor:[UIColor blueColor]];
    } else if ([colorString isEqualToString:@"black"]) {
        [tabbar setTintColor:[UIColor darkTextColor]];
        [bar setBarTintColor:[UIColor darkTextColor]];
    } else if ([colorString isEqualToString:@"red"]) {
        [tabbar setTintColor:[UIColor redColor]];
        [bar setBarTintColor:[UIColor redColor]];
    } else if ([colorString isEqualToString:@"gray"]) {
        [tabbar setTintColor:[UIColor lightGrayColor]];
        [bar setBarTintColor:[UIColor lightGrayColor]];
    }

 
    
}

// 加载 barButton Item
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    [self initNaviButton];

    // 设置左侧barbutton
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendarNotes"]
                                                                 style:(UIBarButtonItemStylePlain)
                                                                target:self
                                                                action:@selector(checkPastNotes:)];
    self.parentViewController.navigationItem.leftBarButtonItem = leftItem;
    self.parentViewController.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
    
    // 设置右侧barbutton
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNote"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(newDaily:)];
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
    self.parentViewController.navigationController.navigationBar.opaque = YES;
}

//视图消失的时候取消掉navigationItem上的控件
- (void)viewWillDisappear:(BOOL)animated {
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    self.parentViewController.navigationItem.leftBarButtonItem = nil;
    self.parentViewController.navigationItem.titleView = nil;
}

// 查看以前日志
- (void)checkPastNotes:(UIBarButtonItem *)button {
    NSLog(@"%s", __func__);
}

// 写新日记
- (void)newDaily:(UIBarButtonItem *)button {
    
    EditNoteViewController *EditVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:EditVC animated:YES];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[WLLDailyNoteDataManager sharedInstance] countOfNoteArray];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DailyNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    NoteDetail *model = [[WLLDailyNoteDataManager sharedInstance] returnModelWithIndex:indexPath.row];
    cell.model = model;

    return cell;
}

// 返回cell 高度为屏幕高度的0.15倍
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kHeight * 0.15;
}

#pragma mark - cell 点击事件响应
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLLNoteDetailViewController *NoteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController" bundle:[NSBundle mainBundle]];
    
    NoteDetailVC.index = indexPath;
    
    [self.navigationController pushViewController:NoteDetailVC animated:YES];
    
}

//渲染view.layer获取image
- (UIImage *)imageWithView:(UIView *)view {
    
    //获取view的image
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 键值观察者方法
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//
//    NSLog(@"change me");
//    [WLLDailyNoteDataManager sharedInstance].topicImage = [self imageWithView:self.view];
//    UIView *tabbarView = self.tabBarController.tabBar;
//    [WLLDailyNoteDataManager sharedInstance].tabbarImage = [self imageWithView:tabbarView];
//    UIView *navigationView = self.tabBarController.navigationController.navigationBar;
//    [WLLDailyNoteDataManager sharedInstance].navigationImage = [self imageWithView:navigationView];
//}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
