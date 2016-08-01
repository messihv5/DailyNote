//
//  WLLShareViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLShareViewController.h"
#import "WChaoShareCellTableViewCell.h"
#import "WLLNoteDetailViewController.h"
#import "WLLShareDetailViewController.h"
#import "NoteDetail.h"
#import "WLLDailyNoteDataManager.h"

@interface WLLShareViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *shareTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSIndexPath *parameterIndexPath;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) UILabel *downLoadLabel;
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) UIRefreshControl *upRefreshControl;
@property (strong, nonatomic) UITableView *footerTableView;
@property (strong, nonatomic) AVUser *currentUser;
@property (strong, nonatomic) UIView *alertView;
@property (strong, nonatomic) UILabel *upLabel;
@property (strong, nonatomic) NSMutableArray *staredUserArray;
@property (assign, nonatomic) BOOL isNetworkAvailable;

@end

@implementation WLLShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //获取网络状态
    self.isNetworkAvailable = [WLLDailyNoteDataManager sharedInstance].isNetworkAvailable;
    
    //从收藏界面，push过来的controller
    [self controllerFromCollectionView];
    
    //获取当前登录用户
    self.currentUser = [AVUser currentUser];
    
    //设置代理
    self.shareTableView.delegate = self;
    self.shareTableView.dataSource = self;
    
    //注册cell
    [self.shareTableView registerNib:[UINib nibWithNibName:@"WChaoShareCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW_Cell"];
    
    //加载10篇分享的日记
    [self loadTenDairies];
    
    //添加下拉刷新
    [self addRefreshControl];
    
    //下拉加载，给tableViewfooterView添加view
    [self addViewToFooterView];
    
    [self addAlertView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharePageDeleteDiary:) name:@"sharePageDeleteDiary" object:nil];
}

//加载从收藏界面push过来的controller
- (void)controllerFromCollectionView {
    if (self.passedIndexPath) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeDiaryAndReloadTableView:) name:@"deleteThisDiariyCollection"
                                                   object:nil];
    }
}

//添加刷新控件
- (void)addRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力刷新中"];
    [self.shareTableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.shareTableView reloadData];
    
    if (self.passedIndexPath) {
        
        //从用户界面，收藏cell，push过来的controller
        self.navigationItem.title = @"我的收藏";
    } else {
        
        //嵌套在tabbarController里面的controller
        self.parentViewController.navigationItem.title = @"日记分享";
    }
}

//懒加载
- (NSMutableArray *)data {
    if (_data == nil) {
        _data = [NSMutableArray arrayWithCapacity:10];
    }
    return _data;
}


//下拉刷新方法，加载最新的日记
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    self.isLoading = YES;
    
    //得到数据中的第一个数据
    if (self.isNetworkAvailable == NO) {
        self.upLabel.hidden = NO;
        self.upLabel.text = @"网络错误";
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissView:) userInfo:self.upLabel repeats:NO];
        [refreshControl endRefreshing];
    } else {
        
        //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
        if (self.data.count != 0) {
            NoteDetail *firstObject = self.data[0];
            
            NSDate *firstDate = firstObject.sharedDate;
            
            if (self.passedIndexPath) {
                //点击收藏加载数据
                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiariesOfCollectionByDate:firstDate finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        NSInteger number = array.count;
                        NSRange range = NSMakeRange(0, number);
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.data insertObjects:array atIndexes:set];
                        [self.shareTableView reloadData];
                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            } else {
                
                //嵌套在tabbar中的Viewcontroller加载数据
                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiariesOfSharingByDate:firstDate finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        NSInteger number = array.count;
                        NSRange range = NSMakeRange(0, number);
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.data insertObjects:array atIndexes:set];
                        [self.shareTableView reloadData];
                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            }
        } else {
            
            //数组没有数据时，直接数组添加数据
            NSDate *date = [NSDate date];
            //点击收藏按钮加载的数据
            if (self.passedIndexPath) {
                [[WLLDailyNoteDataManager sharedInstance] refreshTenDiariesOfCollectionByDate:date finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array != 0) {
                        [self.data addObjectsFromArray:array];
                        [self.shareTableView reloadData];

                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                }];
            } else {
                //嵌套在tabbar中的Viewcontroller加载数据
                [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfSharingByDate:date finished:^{
                    NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                    if (array.count != 0) {
                        [self.data addObjectsFromArray:array];
                        [self.shareTableView reloadData];
                    } else {
                    }
                    [refreshControl endRefreshing];
                    self.isLoading = NO;
                } error:^{
                    NSLog(@"网络错误，刷新分享日记失败");
                }];
            }
        }
        self.upLabel.hidden = NO;
        self.upLabel.text = @"日记已加载完";
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissView:) userInfo:self.upLabel repeats:NO];
    }
}

//给tableView添加一个alertView
- (void)addAlertView {
    
    CGRect alertViewRect = CGRectMake(kWidth / 2 - 100, kHeight / 2 - 20, 200, 40);
    self.alertView = [[UIView alloc] initWithFrame:alertViewRect];
    
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


//给tableViewFooterView添加刷新的view
- (void)addViewToFooterView {
    CGRect footerViewRect = CGRectMake(0, 0, kWidth, 100);
    UIView *footerView = [[UIView alloc] initWithFrame:footerViewRect];
    
    CGRect downLoadLabelRect = CGRectMake(0, 0, kWidth, 40);
    self.downLoadLabel = [[UILabel alloc] initWithFrame:downLoadLabelRect];
    self.downLoadLabel.text = @"上拉加载更多";
    self.downLoadLabel.textAlignment = NSTextAlignmentCenter;
    self.downLoadLabel.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:self.downLoadLabel];
    
    self.shareTableView.tableFooterView = footerView;
}

//scrollView滑动的代理方法，上拉刷新
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.y;
    
    //contentsize减去scrollView的height + 富余量10
    CGFloat loadDataContentOffset = scrollView.contentSize.height - self.shareTableView.frame.size.height + 10;

    if (self.isLoading == YES) {
        return;
    }
    
    if (self.data.count < 5 ) {
        if (self.isNetworkAvailable == NO) {
            if (offset > loadDataContentOffset) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"网络故障";
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissView:) userInfo:self.upLabel repeats:NO];
                self.isLoading = NO;
                return;
            }
        } else {
            if (offset > loadDataContentOffset) {
                self.upLabel.hidden = NO;
                self.upLabel.text = @"日记已加载完";
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissView:) userInfo:self.upLabel repeats:NO];
                self.isLoading = NO;
                return;
            }
        }
    }
    
    if (offset > loadDataContentOffset) {
        if (self.isNetworkAvailable == NO) {
            self.isLoading = YES;
            self.upLabel.hidden = NO;
            self.upLabel.text = @"网络出错";
            self.isLoading = NO;
        } else {
            self.isLoading = YES;
            self.upLabel.hidden = NO;
            self.upLabel.text = @"已加载完日记";
            //调用加载方法
            [self loadTenMorediaries];
        }
    }else {
        self.upLabel.hidden = YES;
    }
}

//每次上拉最多加载10篇日记
- (void)loadTenMorediaries {
    
    NoteDetail *object = [self.data lastObject];
    
    NSDate *date = object.date;
    
    if (self.passedIndexPath) {
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfCollectionByDate:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array != 0) {
                [self.data removeAllObjects];
                [self.data addObjectsFromArray:array];
                [self.shareTableView reloadData];
            }
            self.isLoading = NO;
        }];
    } else {
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfSharingByDate:date finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.shareTableView reloadData];
            }
            self.isLoading = NO;
        } error:^{
            //加载网络错误代码
            self.isLoading = NO;
        }];
    }
}

//进入页面加载10篇日记
- (void)loadTenDairies {
    
    //查询数据库中的日记，并保存在数组中，然后刷新tableView
    
    //获取缓存时间
    NSDate *shareCacheDate = [[AVUser currentUser] objectForKey:@"shareCacheDate"];
    
    //获取当前时间
    NSDate *todayDate = [NSDate date];
    
    if (self.passedIndexPath) {
        
        //从收藏页面过来的
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfCollectionByDate:todayDate finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.shareTableView reloadData];
            }
        }];
    } else {
        [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfSharingByDate:todayDate finished:^{
            NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
            if (array.count != 0) {
                [self.data addObjectsFromArray:array];
                [self.shareTableView reloadData];

                [[AVUser currentUser] setObject:todayDate forKey:@"shareCacheDate"];
                [[AVUser currentUser]  saveInBackground];
            } else {
            }
        } error:^{
            [[WLLDailyNoteDataManager sharedInstance] loadTenDiariesOfSharingByDate:shareCacheDate finished:^{
                NSArray *array = [WLLDailyNoteDataManager sharedInstance].noteData;
                if (array.count != 0) {
                    [self.data addObjectsFromArray:array];
                    [self.shareTableView reloadData];
                } else {
                }
            } error:^{
                //添加网络错误代码
            }];
        }];

    }
}

#pragma mark - tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WChaoShareCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW_Cell"
                                                            forIndexPath:indexPath];
    NoteDetail *model = self.data[indexPath.row];
    
    cell.theTextLable.text = model.content;
    cell.timeLabel.text = model.timeString;
    cell.nickNameLabel.text = model.nickName;
    [cell.headImageView sd_setImageWithURL:model.headImageUrl];
    cell.starNumberLabel.text = model.starNumber;
    cell.backgroundColor = [UIColor colorWithRed:0.3 green:0.5 blue:0.7 alpha:0.5];
    
    //判断当前用户是否已经点赞
    if ([model.staredUserArray containsObject:self.currentUser]) {
        [cell.starButton setImage:[UIImage imageNamed:@"heartSelected15X15"] forState:UIControlStateNormal];
    } else {
        [cell.starButton setImage:[UIImage imageNamed:@"heart15X15"] forState:UIControlStateNormal];
    }
    
    [cell.starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLLShareDetailViewController *detailController;
    detailController = [[WLLShareDetailViewController alloc] initWithNibName:@"WLLShareDetailViewController"
                                                                      bundle:[NSBundle mainBundle]];
    
    detailController.passedObject = self.data[indexPath.row];
    
    //如果是从收藏页面过去的,传个indexpath作为标记
    if (self.passedIndexPath) {
        detailController.passedIndexPath = indexPath;
    }
    
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - 点赞

- (void)starAction:(UIButton *)sender {
    
    //点击之后让button换个image
    [sender setImage:[UIImage imageNamed:@"heartSelected15X15"] forState:UIControlStateNormal];
    
    //通过cell上的按钮获取点击的cell的indexPath
    NSIndexPath *indexPath = [self.shareTableView indexPathForCell:(WChaoShareCellTableViewCell *)[[sender superview] superview]];
    
    //检查diary数组，如果含有该用户，就return，不能进行点赞
    
    NoteDetail *diary = self.data[indexPath.row];

    NSMutableArray *array = diary.staredUserArray;
    
    //获取到日记对象
    AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:diary.diaryId];
    if (array == nil) {

        //第一次查询时点赞用户数组为空
        self.staredUserArray = [NSMutableArray arrayWithCapacity:10];
        
        //日记里面保存的点赞数字显示1
        NSString *num = @"1";
        diary.starNumber = num;
        [object setObject:num forKey:@"starNumber"];
        
        //把点赞的用户添加到数组中，以便下次点赞时进行判断
        AVUser *user = [AVUser currentUser];
        
        //把点赞的用户添加到diary的数组中保存
        [self.staredUserArray addObject:user];
        [object setObject:self.staredUserArray forKey:@"staredUser"];
        diary.staredUserArray = self.staredUserArray;
        
        object.fetchWhenSave = YES;
        [object saveInBackground];
    } else {
        
        //如果该用户已经点赞
        if ([array containsObject:[AVUser currentUser]]) {
            return;
        } else {
            
            //该用户没有点赞
            
            //日记里面保存的点赞数字也加1
            NSString *num = diary.diaryId;
            num = [NSString stringWithFormat:@"%ld", [num integerValue] + 1];
            diary.starNumber = num;
            [object setObject:num forKey:@"starNumber"];
            
            //把点赞的用户添加到数组中，以便下次点赞时进行判断
            AVUser *user = [AVUser currentUser];
            
            //把点赞的用户添加到diary的数组中保存
            [array addObject:user];
            
            object.fetchWhenSave = YES;
            [object setObject:array forKey:@"staredUser"];
            [object saveInBackground];
        }
    }
    
    //点赞后点赞数字加1
    UIView *contentView = sender.superview;
    NSArray *viewArray =  contentView.subviews;
    for (UIView *view in viewArray) {
        if (view.tag == 1) {
            UILabel *label = (UILabel *)view;
            label.text = [NSString stringWithFormat:@"%ld", [label.text integerValue] + 1];
        }
    }
}


//移除取消收藏的日记
- (void)removeDiaryAndReloadTableView:(NSNotification *)notification {
    AVObject *object = notification.userInfo[@"passedObject"];
    [self.data removeObject:object];
    [self.shareTableView reloadData];

}

//使uplabel消失
- (void)dismissView:(NSTimer *)timer {
    if ([timer.userInfo isKindOfClass:[UILabel class]]) {
        UILabel *label = timer.userInfo;
        label.hidden = YES;
        self.isLoading = NO;
    }
}

- (void)sharePageDeleteDiary:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    
    NSString *objectId = dic[@"objectId"];
    
    for (NoteDetail *model in self.data) {
        if ([model.diaryId isEqualToString:objectId]) {
            [self.data removeObject:model];
            [self.shareTableView reloadData];
        }
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
