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
#import "WLLDailyNoteDataManager.h"
#import "WLLLogInViewController.h"

@interface WLLDailyNoteViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

/* 日记页面 */
@property (weak, nonatomic) IBOutlet UITableView *notesTableView;
/* 日记分类页面 */
@property (nonatomic, strong) WLLNotesCategoryView *notesCategoryView;
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

@end

static NSString  *const reuseIdentifier = @"note_cell";

@implementation WLLDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    self.parentViewController.navigationItem.title = @"Time Line";
    
    //添加下拉刷新
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"努力刷新中"];
    [self.notesTableView addSubview:refreshControl];
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
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (AVObject *object in objects) {
            NoteDetail *model = [[NoteDetail alloc] init];
            
            //解析日记内容
            model.content = [object objectForKey:@"content"];
            
            //解析日记写作时间
            NSDate *createdAt = [object objectForKey:@"createdAt"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM月dd日 H:mm"];
            
            NSString *dateString = [formatter stringFromDate:createdAt];
            
            model.weekLabel = dateString;
            
            //解析日记背景颜色
            NSData *colorData = [object objectForKey:@"backColor"];
            
            NSKeyedUnarchiver *unarchiverBackColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:colorData];
            
            UIColor *backColor = [unarchiverBackColor decodeObjectForKey:@"backColor"];
            
            model.backColor = backColor;
            
            //解析日记的字体大小
            NSString *fontNumberString = [object objectForKey:@"fontNumber"];
            float fontNumber = [fontNumberString floatValue];
            model.contentFont = [UIFont systemFontOfSize:fontNumber];
            
            //解析日记的字体颜色
            NSData *fontColorData = [object objectForKey:@"fontColor"];
            NSKeyedUnarchiver *unarchiverFontColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:fontColorData];
            UIColor *fontColor = [unarchiverFontColor decodeObjectForKey:@"fontColor"];
            
            model.fontColor = fontColor;
            
            //解析日记日期
            model.date = object.createdAt;
            
            //添加到数组里面
            [self.data addObject:model];
        }
        [self.notesTableView reloadData];
    }];
}

//下拉刷新方法，加载最新的日记
- (void)refreshAction:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    //刷新数据，加载最新的数据，当数组存储了数据，查询的新数据插到数组的最前面
    if (self.data.count != 0) {
        NoteDetail *firstObject = self.data[0];
        
        NSDate *firstDate = firstObject.date;
        
            AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
            [query whereKey:@"createdAt" greaterThan:firstDate];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    if (objects.count != 0) {
                        
                        NSMutableArray *array = [NSMutableArray array];
                        for (AVObject *object in objects) {
                            NoteDetail *model = [[NoteDetail alloc] init];
                            
                            //解析日记内容
                            model.content = [object objectForKey:@"content"];
                            
                            //解析日记写作时间
                            NSDate *createdAt = [object objectForKey:@"createdAt"];
                            
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"MM月dd日 H:mm"];
                            
                            NSString *dateString = [formatter stringFromDate:createdAt];
                            
                            model.weekLabel = dateString;
                            
                            //解析日记背景颜色
                            NSData *colorData = [object objectForKey:@"backColor"];
                            
                            NSKeyedUnarchiver *unarchiverBackColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:colorData];
                            
                            UIColor *backColor = [unarchiverBackColor decodeObjectForKey:@"backColor"];
                            
                            model.backColor = backColor;
                            
                            //解析日记的字体大小
                            NSString *fontNumberString = [object objectForKey:@"fontNumber"];
                            float fontNumber = [fontNumberString floatValue];
                            model.contentFont = [UIFont systemFontOfSize:fontNumber];
                            
                            //解析日记的字体颜色
                            NSData *fontColorData = [object objectForKey:@"fontColor"];
                            NSKeyedUnarchiver *unarchiverFontColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:fontColorData];
                            UIColor *fontColor = [unarchiverFontColor decodeObjectForKey:@"fontColor"];
                            
                            model.fontColor = fontColor;
                            
                            //解析日记日期
                            model.date = object.createdAt;
                            
                            [array addObject:model];
                        }
                        NSInteger number = objects.count;
                        NSRange range = NSMakeRange(0, number);
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                        [self.data insertObjects:array atIndexes:set];
                        [self.notesTableView reloadData];
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
                        NSMutableArray *array = [NSMutableArray array];
                        
                        for (AVObject *object in objects) {
                            NoteDetail *model = [[NoteDetail alloc] init];
                            
                            //解析日记内容
                            model.content = [object objectForKey:@"content"];
                            
                            //解析日记写作时间
                            NSDate *createdAt = [object objectForKey:@"createdAt"];
                            
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"MM月dd日 H:mm"];
                            
                            NSString *dateString = [formatter stringFromDate:createdAt];
                            
                            model.weekLabel = dateString;
                            
                            //解析日记背景颜色
                            NSData *colorData = [object objectForKey:@"backColor"];
                            
                            NSKeyedUnarchiver *unarchiverBackColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:colorData];
                            
                            UIColor *backColor = [unarchiverBackColor decodeObjectForKey:@"backColor"];
                            
                            model.backColor = backColor;
                            
                            //解析日记的字体大小
                            NSString *fontNumberString = [object objectForKey:@"fontNumber"];
                            float fontNumber = [fontNumberString floatValue];
                            model.contentFont = [UIFont systemFontOfSize:fontNumber];
                            
                            //解析日记的字体颜色
                            NSData *fontColorData = [object objectForKey:@"fontColor"];
                            NSKeyedUnarchiver *unarchiverFontColor = [[NSKeyedUnarchiver alloc] initForReadingWithData:fontColorData];
                            UIColor *fontColor = [unarchiverFontColor decodeObjectForKey:@"fontColor"];
                            
                            model.fontColor = fontColor;
                            
                            //解析日记日期
                            model.date = object.createdAt;
                            
                            [array addObject:model];
                        }
                        
                        [self.data addObjectsFromArray:array];
                        [self.notesTableView reloadData];
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



// 加载 barButton Item
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.EditVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController"
                                                           bundle:[NSBundle mainBundle]];
//    self.EditVC.modelDelegate = self;
    
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
    
    //如果用户登录，加载一次日记（后面视图再次出现不重复执行，而是进行刷星操作）
    if ([AVUser currentUser]) {
        if (self.data.count == 0) {
            [self loadTenDiaries];
        }
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
    
    if (cell.noteImage.image == nil) {
        cell.noteImage = nil;
    }
    cell.model = self.data[indexPath.row];

    return cell;
}

#pragma mark - cell 点击事件响应
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    self.NoteDetailVC.noteDetail = self.data[indexPath.row];
    [self.navigationController pushViewController:self.NoteDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}



@end
