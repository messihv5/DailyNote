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
#import "WLLDailyNoteDataManager.h"
#import "WLLLogInViewController.h"
#import "WLLCalendarViewController.h"

@interface WLLDailyNoteViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

/* 日记页面 */
@property (weak, nonatomic) IBOutlet UITableView *notesTableView;
/* 判断日记分类页面隐藏与否 */
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
/* 日志页面 */
@property (nonatomic, strong) WLLNoteDetailViewController *NoteDetailVC;
/* 编辑页面 */
@property (nonatomic, strong) EditNoteViewController *EditVC;
/* 存储分类按钮 */
//@property (nonatomic, weak) UIButton *button;

@property (nonatomic, strong) NoteDetail *model;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) UILabel *downLoadLabel;
@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UILabel *upLabel;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isBackFromLoginController;
@property (strong, nonatomic) NSDate *dateFromCalendar;
@property (assign, nonatomic) BOOL isLoadedFromViewDidLoad;

@end

static NSString  *const reuseIdentifier = @"note_cell";

@implementation WLLDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isLoadedFromViewDidLoad = YES;

    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    // notesTableView 代理设置
    self.notesTableView.delegate = self;
    self.notesTableView.dataSource = self;
    
    // 日志页面初始化
    self.NoteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController"
                                                                      bundle:[NSBundle mainBundle]];
    
    // 注册 NoteCell
    [self.notesTableView registerNib:[UINib nibWithNibName:@"DailyNoteCell" bundle:nil]
              forCellReuseIdentifier:reuseIdentifier];
    
    
    //添加下拉刷新
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力刷新中"];
    [self.notesTableView addSubview:refreshControl];
    refreshControl.userInteractionEnabled = NO;
    
    //给tableFooterView添加标签
    [self addViewToFooterView];
    
    //添加提示框
    [self addAlertView];
    
    if (self.isFromCalendar == YES) {
        
        //添加标题
        self.navigationItem.title = self.dateString;
        //从calendar点击来的，加载对应的那一天的日记
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfDateString:self.dateString finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            
            [self.data addObjectsFromArray:array];
            [self.notesTableView reloadData];
        }];
    }
    
    //注册更新日记通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNewNote:) name:@"readyToUpdateNewNote" object:nil];
}

//更新最新添加的日记方法
- (void)refreshNewNote:(NSNotification *)notification {
    [self refreshAction:nil];
}
 //数据数组懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}

//加载10篇日记
- (void)loadTenDiaries {
    NSDate *cacheDate = [[AVUser currentUser] objectForKey:@"cacheDate"];
    
    NSDate *date = [NSDate date];
    
    [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfTheCurrentUserByDate:date finished:^{
        NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
        [self.data addObjectsFromArray:array];
        [self.notesTableView reloadData];
        
        [[AVUser currentUser] setObject:date forKey:@"cacheDate"];
        [[AVUser currentUser] saveInBackground];
    } error:^{
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfTheCurrentUserByDate:cacheDate finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            [self.data addObjectsFromArray:array];
            [self.notesTableView reloadData];
            self.upLabel.hidden = YES;
        } error:^{
            //添加网络错误的代码
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"网络故障" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissAlertVC:) userInfo:alertVC repeats:NO];
            [self.navigationController presentViewController:alertVC animated:YES completion:nil];
        }];
    }];
}

//消失alertViewcontroller
- (void)dismissAlertVC:(NSTimer *)timer {
    if ([timer.userInfo isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertVC = timer.userInfo;
        [alertVC dismissViewControllerAnimated:YES completion:nil];
        alertVC = nil;
    } else {
        UILabel *label = timer.userInfo;
        label.text = @"日记已加载完";
        label.hidden = YES;
        self.isLoading = NO;
    }
    
    
    
}

//下拉刷新方法，加载最新的日记
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    self.isLoading = YES;
    
    BOOL networkAvailable = [WLLDailyNoteDataManager sharedInstance].isNetworkAvailable;
    
    if (networkAvailable == NO) {
        self.upLabel.hidden = NO;
        self.upLabel.text = @"网络错误";
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissAlertVC:) userInfo:self.upLabel repeats:NO];
        [refreshControl endRefreshing];
    } else {
        if (self.isFromCalendar) {
            
            //从calender点击过来的刷新
            //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
            
            if (self.data.count != 0) {
                //先从数组中获取日期
                NoteDetail *firstObject = self.data[0];
                
                NSDate *firstDate = firstObject.date;
                
                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiriesOfTheCurrentUserByDateString:self.dateString dateFromLoadDiary:firstDate finished:^{
                    
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    
                    if (array.count != 0) {
                        NSInteger number = array.count;
                        
                        NSRange range = NSMakeRange(0, number);
                        
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [self.data insertObjects:array atIndexes:set];
                        [self.notesTableView reloadData];
                    } else {
                   
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
                
            } else {
                //数据数组中没有数据时，数据数组直接添加数据
                NSDate *date = [NSDate date];
                [[WLLDailyNoteDataManager sharedInstance]  loadTenDiariesOfTheCurrentUserByDate:date finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        [self.data addObjectsFromArray:array];
                        [self.notesTableView reloadData];
                        [refreshControl endRefreshing];
                    } else {
                        [refreshControl endRefreshing];
                        self.isLoading = NO;
                    }
                } error:^{
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            }
        } else {
            //不是从calendar过来的数据,加载当前用户的所有数据
            
            //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
            
            if (self.data.count != 0) {
                
                //先从数组中获取日期
                NoteDetail *firstObject = self.data[0];
                
                NSDate *firstDate = firstObject.date;
                
                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiariesOfTheCurrentUserByDate:firstDate finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        NSInteger number = array.count;
                        
                        NSRange range = NSMakeRange(0, number);
                        
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        [self.data insertObjects:array atIndexes:set];
                        [self.notesTableView reloadData];
                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            } else {
                //数据数组中没有数据时，数据数组直接添加数据
                
                NSDate *date = [NSDate date];
                
                [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfTheCurrentUserByDate:date finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        [self.data addObjectsFromArray:array];
                        [self.notesTableView reloadData];
                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                } error:^{
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            }
        }
    }
}

//给tableViewFooterView添加刷新的view
- (void)addViewToFooterView {
    CGRect footerViewRect = CGRectMake(0, 0, kWidth, 60);
    UIView *footerView = [[UIView alloc] initWithFrame:footerViewRect];
    footerView.backgroundColor = [UIColor whiteColor];
    
    CGRect downLoadLabelRect = CGRectMake(0, 0, kWidth, 40);
    self.downLoadLabel = [[UILabel alloc] initWithFrame:downLoadLabelRect];
    self.downLoadLabel.text = @"上拉加载更多";
    self.downLoadLabel.textAlignment = NSTextAlignmentCenter;
    self.downLoadLabel.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:self.downLoadLabel];
    
    self.notesTableView.tableFooterView = footerView;
}

//给tableView添加一个alertView
- (void)addAlertView {
    
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.alertView.center = CGPointMake(kWidth*0.5, kHeight*0.5);
    
    self.upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.upLabel.text = @"日记已经加载完";
    self.upLabel.textColor = [UIColor whiteColor];
    self.upLabel.alpha = 0.5;
    self.upLabel.textAlignment = NSTextAlignmentCenter;
    self.upLabel.backgroundColor = [UIColor blackColor];
    self.upLabel.layer.masksToBounds = YES;
    self.upLabel.layer.cornerRadius = 5;
    
    [self.alertView addSubview:self.upLabel];
    
    [self.view addSubview:self.alertView];
    
    self.upLabel.hidden = YES;
}

//scrollView滑动的代理方法，上拉刷新
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    
    BOOL networkAvailable = [WLLDailyNoteDataManager sharedInstance].isNetworkAvailable;

    if (self.isLoading == YES) {
        return;
    }
    
    if (self.data.count < 10 ) {

        if (networkAvailable == NO) {
            if (offset > -50 ) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"网络出错";
            } else if (offset == -64) {
                self.upLabel.hidden = YES;
            }
            return;
        } else {
            if (offset > -50 ) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"日记已加载完";
            } else if (offset == -64) {
                self.upLabel.hidden = YES;
            }
            return;
        }
    }
    
    
    //contentsize减去scrollView的height + 富余量10
    CGFloat loadDataContentOffset = scrollView.contentSize.height - self.notesTableView.height + 10;
    
    if (offset > loadDataContentOffset) {
        
        if (networkAvailable == YES) {
            self.isLoading = YES;
            self.upLabel.hidden = NO;
            self.upLabel.text = @"日记已加载完";
            //调用加载方法
            [self loadTenMoreDiaries];
        } else {
            self.isLoading = YES;
            self.upLabel.hidden = NO;
            self.upLabel.text = @"网络出错";
            self.isLoading = NO;
        }
    } else {
        self.upLabel.hidden = YES;
    }
}

//每次上拉最多加载10篇日记
- (void)loadTenMoreDiaries {
    NoteDetail *model = [self.data lastObject];
    
    NSDate *date = model.date;
    
    if (self.isFromCalendar) {
        [[WLLDailyNoteDataManager sharedInstance] loadMoreDiariesOfDateString:self.dateString dateFromloadedDiary:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.notesTableView reloadData];
            } else {
                
            }
            self.isLoading = NO;
        }];
    } else {
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfTheCurrentUserByDate:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.notesTableView reloadData];
            } else {
                            
            }
            self.isLoading = NO;
        } error:^{
            //添加网络错误代码
            self.isLoading = NO;
        }];
    }
}

// 加载 barButton Item
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.notesTableView reloadData];
    
    self.parentViewController.navigationItem.title = @"Time Line";
    
    self.EditVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController"
                                                           bundle:[NSBundle mainBundle]];

    
    // 左侧barbutton
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendarNotes"]
                                                                 style:(UIBarButtonItemStylePlain)
                                                                target:self
                                                                action:@selector(checkPastNotes:)];
    self.parentViewController.navigationItem.leftBarButtonItem = leftItem;
    self.parentViewController.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
    
    // 右侧barbutton
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNote"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(newDaily:)];
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
    
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.parentViewController.navigationItem.leftBarButtonItem = nil;
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
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
    
//    //从viewDidLoad第一次进入页面时，不刷新，后面每次进入页面都刷新
//    if ([AVUser currentUser] && self.isLoadedFromViewDidLoad == NO) {
//        [self refreshAction:nil];
//    }
    
    //进入日记，从viewDidLoad进入时，加载一次日记
    if ([AVUser currentUser] && self.isFromCalendar == NO && self.isLoadedFromViewDidLoad == YES) {
        [self loadTenDiaries];
        self.isLoadedFromViewDidLoad = NO;
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
    } else if ([colorString isEqualToString:@"blue"]) {
        [tabbar setTintColor:[UIColor blueColor]];
        [bar setBarTintColor:[UIColor blueColor]];
    } else if ([colorString isEqualToString:@"black"]) {
        [tabbar setTintColor:[UIColor darkTextColor]];
        [bar setBarTintColor:[UIColor darkTextColor]];
    } else if ([colorString isEqualToString:@"gray"]) {
        [tabbar setTintColor:[UIColor lightGrayColor]];
        [bar setBarTintColor:[UIColor lightGrayColor]];
    } else if ([colorString isEqualToString:@"red"]) {
        [tabbar setTintColor:[UIColor redColor]];
        [bar setBarTintColor:[UIColor redColor]];
    }
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


// 查看以前日志
- (void)checkPastNotes:(UIBarButtonItem *)button {
    WLLCalendarViewController *calendarVC = [[WLLCalendarViewController alloc] init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

// 写新日记
- (void)newDaily:(UIBarButtonItem *)button {
    [self.navigationController pushViewController:self.EditVC animated:YES];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DailyNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                          forIndexPath:indexPath];
   
    cell.model = self.data[indexPath.row];

    return cell;
}

#pragma mark - cell 点击事件响应
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.NoteDetailVC.passedObject = self.data[indexPath.row];
    self.NoteDetailVC.indexPath = indexPath;
    [self.navigationController pushViewController:self.NoteDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteDetail *model = self.data[indexPath.row];

    CGFloat height = [DailyNoteCell heightForCell:model.content model:model];

    return height;
}

@end
