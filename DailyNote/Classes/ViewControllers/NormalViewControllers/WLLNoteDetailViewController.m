//
//  WLLNoteDetailViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLNoteDetailViewController.h"
#import "EditNoteViewController.h"
#import "NoteDetail.h"
#import "WLLDailyNoteDataManager.h"
#import "WLLSharedView.h"

@interface WLLNoteDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) UIView *views;
@property (nonatomic, assign) NSInteger indexs;

@end

@implementation WLLNoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"全部";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToFront)];
    
    self.navigationItem.leftBarButtonItem = left;

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNote"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(editDaily:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
    
    self.indexs = self.index.row;
    [self dataFromNoteDaily];
}

// 传值
- (void)dataFromNoteDaily {
    NoteDetail *model = [[WLLDailyNoteDataManager sharedInstance] returnModelWithIndex:self.indexs];
    
    self.contentLabel.text = model.content;
    self.monthAndYearLabel.text = [NSString stringWithFormat:@"%@.%@", model.monthAndYear, model.dates];
    self.weekDayLabel.text = model.weekLabel;
    self.timeLabel.text = model.time;
}

- (void)backToFront {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editDaily:(UIBarButtonItem *)button {
    
    EditNoteViewController *EditVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:[NSBundle mainBundle]];
    
    EditVC.index = self.index;
    
    [self.navigationController pushViewController:EditVC animated:YES];
}

#pragma mark - 翻页响应
- (IBAction)clickToForward:(UIButton *)sender {
    
    self.indexs++;
    NSInteger count = [[WLLDailyNoteDataManager sharedInstance] countOfNoteArray];
    if (self.indexs > count - 1) {
        
        UIAlertController *tip = [UIAlertController alertControllerWithTitle:@"" message:@"已经是最后一篇日记了~~~" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:tip animated:YES completion:^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
    
        }];
        self.indexs--;
        
    } else [self dataFromNoteDaily];
}

- (IBAction)clickToBackward:(UIButton *)sender {
    
    self.indexs--;

    if (self.indexs < 0) {
        
        UIAlertController *tip = [UIAlertController alertControllerWithTitle:@"" message:@"没有上篇日记了~~~" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:tip animated:YES completion:^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
    self.indexs++;
        
    } else [self dataFromNoteDaily];
}

#pragma mark - 分享到三方
- (IBAction)sharedToThirdParty:(UIButton *)sender {
    
//    [UIView animateWithDuration:0.5 animations:^{
//        self.views.center = CGPointMake(414/2, 736/2);
//    }];
    
}



@end
