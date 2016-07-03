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

@interface WLLDailyNoteViewController ()<UITableViewDelegate, UITableViewDataSource>

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


@end

static NSString  *const reuseIdentifier = @"note_cell";

@implementation WLLDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // notesTableView 代理设置
    self.notesTableView.delegate = self;
    self.notesTableView.dataSource = self;
    
    // 日志页面初始化
    self.NoteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController"
                                                                      bundle:[NSBundle mainBundle]];
    
    // 注册 NoteCell
    [self.notesTableView registerNib:[UINib nibWithNibName:@"DailyNoteCell" bundle:nil]
              forCellReuseIdentifier:reuseIdentifier];
    
//    // 请求数据
//    [[WLLDailyNoteDataManager sharedInstance] requestDataAndFinished:^{
//        [self.notesTableView reloadData];
//    }];
    
    self.parentViewController.navigationItem.title = @"Time Line";

    [self loadTenDiaries];

    
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
            
            //添加到数组里面
            [self.data addObject:model];
        }
        [self.notesTableView reloadData];
    }];
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
//    
//    NoteDetail *model = [[WLLDailyNoteDataManager sharedInstance] getModelWithIndex:indexPath.row];
//    
//    DailyNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    
//    CGFloat h = [cell heightForCell:model.content];
    
    
    return 80;
}



@end
