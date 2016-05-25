//
//  EditNoteViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "EditNoteViewController.h"
#import "WLLCategoryButton.h"
#import "WLLNotesCategoryView.h"
#import "WLLDailyNoteDataManager.h"
#import "NoteDetail.h"

#define kWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface EditNoteViewController ()
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

@property (nonatomic, strong) UITableView *notesCategoryView;
@property (weak, nonatomic) IBOutlet UITextField *contentText;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation EditNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNaviButton];
    
    [self dataFromDetail];
    
}

- (void)dataFromDetail {
    
    if (_index) {
        NoteDetail *model = [[WLLDailyNoteDataManager sharedInstance] returnModelWithIndex:self.index.row];
        
        self.contentText.text = model.content;
        
        self.countLabel.text = [NSString stringWithFormat:@"%ld", self.contentText.text.length];
    }
}

// view完成加载后 加载分类页面初始位置
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    // 分类页面初始为隐藏
    self.hidden = YES;
    // 分类页面初始位置在屏幕以外, 将其高度设置为0
    self.notesCategoryView = [[WLLNotesCategoryView alloc] initWithFrame:CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0) style:UITableViewStylePlain];
    
    self.notesCategoryView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.notesCategoryView];
}


// 初始化分类页面按钮
- (void)initNaviButton {
    WLLCategoryButton *titleButton = [WLLCategoryButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, kWidth*0.2, kWidth*0.0725);
    [titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [titleButton setTitle:@"全部" forState:UIControlStateNormal];
    
    [titleButton addTarget:self action:@selector(notesCategory:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleButton;
}

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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)saveNote:(UIBarButtonItem *)button {
    
    NSLog(@"%s", __func__);
}

- (void)cancel {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
