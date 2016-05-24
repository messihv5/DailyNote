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

#define kWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface WLLDailyNoteViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *notesTableView;

@property (nonatomic, strong) UITableView *notesCategoryView;

@property (nonatomic, assign, getter=isHidden) BOOL hidden;

@end

static NSString  *const reuseIdentifier = @"note_cell";

@implementation WLLDailyNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidden = YES;
    // notesTableView 设置
    self.notesTableView.delegate = self;
    self.notesTableView.dataSource = self;
    
    // 注册 NoteCell
    [self.notesTableView registerNib:[UINib nibWithNibName:@"DailyNoteCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    // 设置分类button
    WLLCategoryButton *titleButton = [WLLCategoryButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, kWidth*0.2, kWidth*0.0725);
    [titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [titleButton setTitle:@"全部的地球有多大" forState:UIControlStateNormal];
    
    [titleButton addTarget:self action:@selector(notesCategory:) forControlEvents:UIControlEventTouchUpInside];
        
    self.parentViewController.navigationItem.titleView = titleButton;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    self.notesCategoryView = [[WLLNotesCategoryView alloc] initWithFrame:CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0) style:UITableViewStylePlain];
    
    self.notesCategoryView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.notesCategoryView];
}

// 分类
- (void)notesCategory:(UIButton *)button {

    if (self.isHidden == YES) {
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, kWidth*1.2077);
            [button setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }];
        self.hidden = NO;
    }
    else if (self.isHidden == NO) {
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0);
            [button setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }];
        self.hidden = YES;
    }
}

// 加载 barButton Item
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
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
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DailyNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kHeight * 0.15;
}

#pragma mark - cell 点击事件响应
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLLNoteDetailViewController *NoteDetailVC = [[WLLNoteDetailViewController alloc] initWithNibName:@"WLLNoteDetailViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:NoteDetailVC animated:YES];
    
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
