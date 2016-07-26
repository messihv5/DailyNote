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
/* 存储分类按钮 */
//@property (nonatomic, weak) UIButton *button;

@property (strong, nonatomic) NoteDetail *model;
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
@property (strong, nonatomic) NoteDetail *passedObject;
@property (assign, nonatomic) BOOL backFromEditNoteVC;

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
    
    // 注册 NoteCell
    [self.notesTableView registerNib:[UINib nibWithNibName:@"DailyNoteCell" bundle:nil]
              forCellReuseIdentifier:reuseIdentifier];
    
    
    //添加下拉刷新控件
    [self addRefreshToTableView];
    
    //给tableFooterView添加标签
    [self addViewToFooterView];
    
    //添加提示框
    [self addAlertView];
    
    //加载calendar页面的日记
    [self loadDirayFromCalendarPage];
    
    //加载recycle的5篇日记
    [self loadFiveDiariesOfRecycle];
    
    //注册恢复日记的通知
    [self addNotificationObserver];
}

/**
 *  添加观察日记恢复的通知
 */
- (void)addNotificationObserver {
    if (self.isFromCalendar == NO && [WLLDailyNoteDataManager sharedInstance].isBackFromRecycle == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeDiary:) name:@"resumeDiary" object:nil];
    }
}

/**
 *  恢复日记，并在主页面添加恢复的日记，然后刷新主页面
 *
 *  @param notification 接收到的通知信息
 */
- (void)resumeDiary:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    
    NoteDetail *model = dic[@"diary"];
    
    [self.data addObject:model];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    [self.data sortUsingDescriptors:@[descriptor]];
    
    [self.notesTableView reloadData];
}

/**
 *  加载回收站的5篇日记
 */
- (void)loadFiveDiariesOfRecycle {
    if ([WLLDailyNoteDataManager sharedInstance].isBackFromRecycle) {
        self.navigationItem.title = @"回收站";
        
        NSDate *date = [NSDate date];
        
        [[WLLDailyNoteDataManager sharedInstance] loadFiveDiariesOfRecycleByDate:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            
            NSMutableArray *mutableArray = [WLLDailyNoteDataManager sharedInstance].noteData.mutableCopy;
            
            if (array.count != 0) {
                for (NoteDetail *model in array) {
                    NSTimeInterval timeInterval = 10 * 60;
                    
                    NSDate *nowDate = [NSDate date];
                    
                    NSDate *deletedDate = model.updatedDate;
                    
                    NSTimeInterval deletedTimeInterval = [nowDate timeIntervalSinceDate:deletedDate];
                    
                    if (deletedTimeInterval > timeInterval) {
                        [mutableArray removeObject:model];
                        
                        //删除数据库里的日记
                        AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:model.diaryId];
                        [object deleteInBackground];
                    }
                }
            }
            
            if (mutableArray.count != 0) {
                [self.data addObjectsFromArray:mutableArray];
                [self.notesTableView reloadData];
            } else {
                return;
            }
        }];
    }
}

//删除回收站里已经30天的日记
- (void)deleteDiary:(NSNotification *)notification {
    
}

//添加刷新控件
- (void)addRefreshToTableView {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力刷新中"];
    [self.notesTableView addSubview:refreshControl];
    refreshControl.userInteractionEnabled = NO;
}

//更新最新添加的日记方法
- (void)backFromEditNoteVC:(NSNotification *)notification {
    self.backFromEditNoteVC = YES;
}
//数据数组懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}

//加载calendar页面的5篇日记
- (void)loadDirayFromCalendarPage {
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

}

//加载5篇日记
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
    }
    /*
//        if (self.isFromCalendar) {
//            
//            //从calender点击过来的刷新
//            //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
//            
//            if (self.data.count != 0) {
//                //先从数组中获取日期
//                NoteDetail *firstObject = self.data[0];
//                
//                NSDate *firstDate = firstObject.date;
//                
//                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiriesOfTheCurrentUserByDateString:self.dateString dateFromLoadDiary:firstDate finished:^{
//                    
//                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
//                    
//                    if (array.count != 0) {
//                        NSInteger number = array.count;
//                        
//                        NSRange range = NSMakeRange(0, number);
//                        
//                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
//                        
//                        [self.data insertObjects:array atIndexes:set];
//                        [self.notesTableView reloadData];
//                    } else {
//                   
//                    }
//                    [refreshControl endRefreshing];
//                    self.isLoading = NO;
//                }];
//                
//            } else {
//                //数据数组中没有数据时，数据数组直接添加数据
//                NSDate *date = [NSDate date];
//                [[WLLDailyNoteDataManager sharedInstance]  loadTenDiariesOfTheCurrentUserByDate:date finished:^{
//                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
//                    if (array.count != 0) {
//                        [self.data addObjectsFromArray:array];
//                        [self.notesTableView reloadData];
//                        [refreshControl endRefreshing];
//                    } else {
//                        [refreshControl endRefreshing];
//                        self.isLoading = NO;
//                    }
//                } error:^{
//                    [refreshControl endRefreshing];
//                    self.isLoading = NO;
//                }];
//            }
//        } else {
//            //不是从calendar过来的数据,加载当前用户的所有数据
//            
//            //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
//            
//            if (self.data.count != 0) {
//                
//                //先从数组中获取日期
//                NoteDetail *firstObject = self.data[0];
//                
//                NSDate *firstDate = firstObject.date;
//                
//                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiariesOfTheCurrentUserByDate:firstDate finished:^{
//                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
//                    if (array.count != 0) {
//                        NSInteger number = array.count;
//                        
//                        NSRange range = NSMakeRange(0, number);
//                        
//                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
//                        
//                        [self.data insertObjects:array atIndexes:set];
//                        [self.notesTableView reloadData];
//                    } else {
//                    }
//                    [refreshControl endRefreshing];
//                    self.isLoading = NO;
//                }];
//            } else {
//                //数据数组中没有数据时，数据数组直接添加数据
//                
//                NSDate *date = [NSDate date];
//                
//                [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfTheCurrentUserByDate:date finished:^{
//                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
//                    if (array.count != 0) {
//                        [self.data addObjectsFromArray:array];
//                        [self.notesTableView reloadData];
//                    } else {
//                    }
//                    [refreshControl endRefreshing];
//                    self.isLoading = NO;
//                } error:^{
//                    [refreshControl endRefreshing];
//                    self.isLoading = NO;
//                }];
//            }
//        }
//    } */
    [refreshControl endRefreshing];
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
    
    if (self.data.count < 5) {

        if (networkAvailable == NO) {
            if (offset > -64 && offset <= 200) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"网络出错";
            } else {
                self.upLabel.hidden = YES;
            }
            self.isLoading = NO;
            return;
        } else {
            if (offset > -64 && offset <= 200) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"日记已加载完";
            } else {
                self.upLabel.hidden = YES;
            }
            self.isLoading = NO;
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
        //加载calendar的日记
        [[WLLDailyNoteDataManager sharedInstance] loadMoreDiariesOfDateString:self.dateString dateFromloadedDiary:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.notesTableView reloadData];
            } else {
                
            }
            self.isLoading = NO;
        }];
    } else if ([WLLDailyNoteDataManager sharedInstance].isBackFromRecycle) {
        //加载回收站的日记
        [[WLLDailyNoteDataManager sharedInstance] loadFiveDiariesOfRecycleByDate:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.notesTableView reloadData];
            } else {
                
            }
            self.isLoading = NO;
        }];
    }else {
        //加载主页面的日记
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
    
//    [self.notesTableView reloadData];
    
    self.parentViewController.navigationItem.title = @"Time Line";
    
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
    
    //页面将消失时，将标记来自日历的标记设置为NO
    if (self.isFromCalendar) {
        self.isFromCalendar = NO;
    }
    
    //页面将消失时， 将标记来自回收站的标记设置为NO
    if ([WLLDailyNoteDataManager sharedInstance].isBackFromRecycle) {
        [WLLDailyNoteDataManager sharedInstance].isBackFromRecycle = NO;
    }
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
    
    //进入日记，从viewDidLoad进入时，加载一次日记
    BOOL isFromRecycle = [[WLLDailyNoteDataManager sharedInstance] isBackFromRecycle];
    if ([AVUser currentUser] && self.isFromCalendar == NO && isFromRecycle ==NO && self.isLoadedFromViewDidLoad == YES) {
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
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable == NO) {
        self.upLabel.hidden = NO;
        self.upLabel.text = @"网络故障，不能编辑";
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissAlertVC:) userInfo:self.upLabel repeats:NO];
    } else {
        EditNoteViewController *editVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:[NSBundle mainBundle]];
        editVC.numberOfModelInArray = self.data.count;
        __weak WLLDailyNoteViewController *weakSelf = self;
        editVC.block = ^ (NoteDetail *passedObject) {
            weakSelf.passedObject = passedObject;
            [weakSelf.data insertObject:passedObject atIndex:0];
            [weakSelf.notesTableView reloadData];
        };
        
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

#pragma mark - UITableView 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DailyNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                          forIndexPath:indexPath];
   
    cell.model = self.data[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([WLLDailyNoteDataManager sharedInstance].isBackFromRecycle == NO) {
        WLLNoteDetailViewController *noteDetailVC;
        noteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController"
        
                                                                     bundle:[NSBundle mainBundle]];
        //正向传model
        noteDetailVC.passedObject = self.data[indexPath.row];
        noteDetailVC.indexPath = indexPath;
        noteDetailVC.numberOfDiary = self.data.count;
        
        //上下篇日记翻页block
        __weak WLLNoteDetailViewController *weakNoteDetailVC = noteDetailVC;
        noteDetailVC.lastDiaryBlock = ^ (NSInteger lastDiary) {
            weakNoteDetailVC.passedObject = self.data[lastDiary];
        };
        
        noteDetailVC.nextDiaryBlock = ^ (NSInteger nextDiaty) {
            weakNoteDetailVC.passedObject = self.data[nextDiaty];
        };
        
        //notedetail页面删除日记
        noteDetailVC.deleteDiary = ^ {
            [self.data removeObjectAtIndex:indexPath.row];
            [self.notesTableView reloadData];
        };
           
        [self.navigationController pushViewController:noteDetailVC animated:YES];
    } else {
        //回收站日记的处理
        NoteDetail *model = self.data[indexPath.row];
        
        AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:model.diaryId];

        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *resumeAction = [UIAlertAction actionWithTitle:@"恢复日记" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //处理数据库
            [object setObject:@"NO" forKey:@"wasDeleted"];
            [object saveInBackground];
            
            //处理UI
            [self.data removeObject:model];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObject:model forKey:@"diary"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"resumeDiary" object:nil userInfo:dic];
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"彻底删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [object deleteInBackground];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:resumeAction];
        [alertVC addAction:deleteAction];
        [alertVC addAction:cancelAction];
        
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteDetail *model = self.data[indexPath.row];

    CGFloat height = [DailyNoteCell heightForCell:model.content model:model];

    return height;
}

//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"readyToUpdateNewNote" object:nil];
}
@end
