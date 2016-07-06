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

@end

@implementation WLLShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.passedIndexPath) {
        
        //从用户界面，收藏cell，push过来的controller
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeDiaryAndReloadTableView:) name:@"deleteThisDiariyCollection"
                                                   object:nil];
    }
    self.currentUser = [AVUser currentUser];
    
    self.shareTableView.delegate = self;
    self.shareTableView.dataSource = self;
    
    [self.shareTableView registerNib:[UINib nibWithNibName:@"WChaoShareCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW_Cell"];
    
    [self loadTenDairies];
    
    //添加下拉刷新
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力刷新中"];
    [self.shareTableView addSubview:refreshControl];
    
    //下拉加载，给tableViewfooterView添加view
    [self addViewToFooterView];
    
    [self addAlertView];
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
    if (self.data.count != 0) {
        AVObject *firstObject = self.data[0];
        
        NSDate *firstDate = firstObject.createdAt;
        
        if (self.passedIndexPath) {
            
            //点击收藏加载数据
            AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
            
            AVQuery *collectionQuery = [collectionRelation query];
            [collectionQuery whereKey:@"createdAt" greaterThan:firstDate];
            
            [collectionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    if (objects.count != 0) {
                        NSInteger number = objects.count;
                        NSRange range = NSMakeRange(0, number);
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.data insertObjects:objects atIndexes:set];
                        [self.shareTableView reloadData];
                        [refreshControl endRefreshing];
                    } else {
                        [refreshControl endRefreshing];
                        return;
                    }
                } else {
                    [refreshControl endRefreshing];
                    return;
                }
            }];
        } else {
            
            //嵌套在tabbar中的Viewcontroller加载数据
            AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
            [query whereKey:@"createdAt" greaterThan:firstDate];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    if (objects.count != 0) {
                        NSInteger number = objects.count;
                        NSRange range = NSMakeRange(0, number);
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.data insertObjects:objects atIndexes:set];
                        [self.shareTableView reloadData];
                        [refreshControl endRefreshing];
                    } else {
                        [refreshControl endRefreshing];
                        return;
                    }
                    
                } else {
                    [refreshControl endRefreshing];
                    return;
                }
            }];
        }
    } else {
        
        //数组没有数据时，直接数组添加数据
        
        //点击收藏按钮加载的数据
        if (self.passedIndexPath) {
            AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
            
            AVQuery *collectionQuery = [collectionRelation query];
            [collectionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    if (objects.count != 0) {
                        [self.data addObjectsFromArray:objects];
                        [self.shareTableView reloadData];
                        [refreshControl endRefreshing];
                    } else {
                        [refreshControl endRefreshing];
                        return;
                    }
                } else {
                    [refreshControl endRefreshing];
                    return;
                }
            }];
        } else {
            
            //嵌套在tabbar中的Viewcontroller加载数据
            AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    if (objects.count != 0) {
                        [self.data addObjectsFromArray:objects];
                        [self.shareTableView reloadData];
                        [refreshControl endRefreshing];
                    } else {
                        [refreshControl endRefreshing];
                        return;
                    }
                } else {
                    [refreshControl endRefreshing];
                    return;
                }
            }];
        }
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
    if (self.data.count < 10 ) {
        CGFloat offset = scrollView.contentOffset.y;
        if (offset > -50 ) {
            self.upLabel.hidden = NO;
        } else if (offset <= -64) {
            self.upLabel.hidden = YES;
        }
        return;
    }
    
    if (self.isLoading == YES) {
        return;
    }
    
    CGFloat contentOffset = scrollView.contentOffset.y;
    
    //contentsize减去scrollView的height + 富余量10
    CGFloat loadDataContentOffset = scrollView.contentSize.height - self.shareTableView.frame.size.height + 10;
    
    if (contentOffset > loadDataContentOffset) {
        self.isLoading = YES;
        self.upLabel.hidden = NO;
        
        //调用加载方法
        [self loadTenMorediary];
    }else {
        self.upLabel.hidden = YES;
    }
}

//每次上拉最多加载10篇日记
- (void)loadTenMorediary {
    
    AVObject *object = [self.data lastObject];
    
    NSDate *date = object.createdAt;
    
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    [query whereKey:@"createdAt" lessThan:date];
    [query orderByDescending:@"createdAt"];
     query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            if (objects.count != 0) {
                [self.data addObjectsFromArray:objects];
                [self.shareTableView reloadData];
                self.downLoadLabel.hidden = NO;
            } else {
            }
        } else {
            self.downLoadLabel.text = @"网络错误";
            self.downLoadLabel.hidden = NO;
        }
        self.isLoading = NO;
    }];
}

//消失alertController
- (void)dismissAlertController:(NSTimer *)timer {
    UIAlertController *alertController = timer.userInfo;
    [alertController dismissViewControllerAnimated:YES completion:nil];
    alertController = nil;
    self.isLoading = NO;
    self.downLoadLabel.hidden = NO;
}

//进入页面加载10篇日记
- (void)loadTenDairies {
    
    //查询数据库中的日记，并保存在数组中，然后刷新tableView
    
    //获取当前时间
    NSDate *todayDate = [NSDate date];
    NSDate *myDate = [NSDate dateWithTimeInterval:8 * 60 * 60 sinceDate:todayDate];
    
    if (self.passedIndexPath) {
        
        //从收藏页面过来的
        AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
        
        AVQuery *collectionQuery = [collectionRelation query];
        
        collectionQuery.limit = 10;
        [collectionQuery orderByDescending:@"createdAt"];
        [collectionQuery whereKey:@"createdAt" lessThan:myDate];
        
        [collectionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.data addObjectsFromArray:objects];
            [self.shareTableView reloadData];
        }];
    } else {
        
        //嵌套在tabbar中的viewController加载数据
        AVQuery *categoryQuery = [AVQuery queryWithClassName:@"Diary"];
    
        [categoryQuery orderByDescending:@"createdAt"];
        [categoryQuery whereKey:@"createdAt" lessThan:myDate];
        categoryQuery.limit = 10;
        
        [categoryQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //这里可以先把objects数据解析到model里面，再把model存到数组里面
            [self.data addObjectsFromArray:objects];
            [self.shareTableView reloadData];
        }];;
    }
}

#pragma mark - tableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //指向时间
    NSString *string = nil;
    
    WChaoShareCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW_Cell"
                                                            forIndexPath:indexPath];
    AVObject *object = self.data[indexPath.row];
    
    //获取点赞用户数组，判断用户是否点赞
    NSArray *staredUserArray = [object objectForKey:@"staredUser"];
    
    //获取日记的创建时间
    NSDate *createdDate = [object objectForKey:@"createdAt"];
    
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:createdDate];
    
    if (timeInterval / (24 * 60 * 60) >= 1) {
        string = [NSString stringWithFormat:@"%ld天前", (NSInteger)timeInterval / (24 * 60 * 60) ];
    } else if (timeInterval / (60 * 60) >= 1) {
        string = [NSString stringWithFormat:@"%ld小时前", (NSInteger)timeInterval / (60 * 60)];
    } else if (timeInterval / 60 >= 1) {
        string = [NSString stringWithFormat:@"%ld分钟以前", (NSInteger)timeInterval / 60];
    } else {
        string = [NSString stringWithFormat:@"%ld秒前", (NSInteger)timeInterval];
    }
    
    //获取用户的图像,这种方法比较好，然后把所有的数据一起给cell赋值
    AVFile *file = [[AVUser currentUser] objectForKey:@"headImage"];
    
    [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
        NSData *data = [file getData];
        
        UIImage *image = [UIImage imageWithData:data];
        
            cell.headImageView.image = image;
            cell.theTextLable.text = [object objectForKey:@"content"];

            NSArray *keys = [NSArray arrayWithObjects:@"belong", nil];
            [object fetchInBackgroundWithKeys:keys block:^(AVObject *object, NSError *error) {
                AVUser *relatedUser = [object objectForKey:@"belong"];
                cell.nickNameLabel.text = [relatedUser objectForKey:@"nickName"];
            }];
        
        cell.starNumberLabel.text = [object objectForKey:@"starNumber"];
        if (cell.starNumberLabel.text == nil) {
            cell.starNumberLabel.text = @"0";
        }
        
        cell.timeLabel.text = string;
            
            //判断当前用户是否已经点赞
            if ([staredUserArray containsObject:self.currentUser]) {
                [cell.starButton setImage:[UIImage imageNamed:@"heartSelected15X15"] forState:UIControlStateNormal];
            } else {
                [cell.starButton setImage:[UIImage imageNamed:@"heart15X15"] forState:UIControlStateNormal];
            }
            
            [cell.starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLLShareDetailViewController *detailController = [[WLLShareDetailViewController alloc] initWithNibName:@"WLLShareDetailViewController" bundle:[NSBundle mainBundle]];
    
    detailController.passedObject = self.data[indexPath.row];
    
    detailController.block = ^ (NSString *string) {
        WChaoShareCellTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.starNumberLabel.text = string;
    };
    
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
    
    AVObject *diary = self.data[indexPath.row];

    NSMutableArray *array = [diary objectForKey:@"staredUser"];
    
    if (array == nil) {
        
        //第一次查询时点赞用户数组为空
        self.staredUserArray = [NSMutableArray arrayWithCapacity:10];
        
        //日记里面保存的点赞数字也加1
        NSString *num = [diary objectForKey:@"starNumber"];
        num = [NSString stringWithFormat:@"%ld", [num integerValue] + 1];
        [diary setObject:num forKey:@"starNumber"];
        
        //把点赞的用户添加到数组中，以便下次点赞时进行判断
        AVUser *user = [AVUser currentUser];
        
        //把点赞的用户添加到diary的数组中保存
        [self.staredUserArray addObject:user];
        
        diary.fetchWhenSave = YES;
        [diary setObject:self.staredUserArray forKey:@"staredUser"];
        [diary saveInBackground];

    } else {
        
        //如果该用户已经点赞
        if ([array containsObject:[AVUser currentUser]]) {
            return;
        } else {
            
            //该用户没有点赞
            
            //日记里面保存的点赞数字也加1
            NSString *num = [diary objectForKey:@"starNumber"];
            num = [NSString stringWithFormat:@"%ld", [num integerValue] + 1];
            [diary setObject:num forKey:@"starNumber"];
            
            //把点赞的用户添加到数组中，以便下次点赞时进行判断
            AVUser *user = [AVUser currentUser];
            
            //把点赞的用户添加到diary的数组中保存
            [array addObject:user];
            
            diary.fetchWhenSave = YES;
            [diary setObject:array forKey:@"staredUser"];
            [diary saveInBackground];
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
