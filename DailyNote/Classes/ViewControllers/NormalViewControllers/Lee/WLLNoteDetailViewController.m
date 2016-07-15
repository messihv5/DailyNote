//
//  WLLNoteDetailViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLNoteDetailViewController.h"
#import "EditNoteViewController.h"
#import "WLLDailyNoteDataManager.h"
#import "WLLSharedView.h"

@interface WLLNoteDetailViewController ()
/* 日记-年月标签 */
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
/* 日记-礼拜标签 */
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;
/* 日记-时间标签 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/* 日记-内容标签 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
/* 日记-控制翻页 */
@property (nonatomic, assign) NSInteger indexs;
/* 编辑页面 */
@property (nonatomic, strong) EditNoteViewController *EditVC;
/* 背景 */
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *noteImage;

@property (nonatomic, strong) NoteDetail *model;

@end

@implementation WLLNoteDetailViewController

@dynamic title;

#pragma mark - View Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 从Xib获取编辑页面
    self.EditVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController"
                                                           bundle:[NSBundle mainBundle]];
    // 标题
    self.navigationItem.title = @"Time Line";
}


// view将要出现时加载左右按键
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];

    // 左边按钮
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(backToFront)];
    
    self.navigationItem.leftBarButtonItem = left;
    
    // 右边
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNote"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(editDaily:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
    
    // 将日志页面cell下标赋给控制详情页面翻页
    self.indexs = self.indexPath.row;
    // 本页数据加载自日志页面
    [self dataFromNoteDaily];
    
}

// 将日志页面的值赋给详情页面
- (void)dataFromNoteDaily {
    
    //日记内容赋值
    self.contentLabel.text = self.passedObject.content;
    
    //日记日期赋值
    NSDate *createdAt = self.passedObject.date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日 H:mm"];
    
    NSString *dateString = [formatter stringFromDate:createdAt];
    
    self.monthAndYearLabel.text = dateString;
    
//    self.weekDayLabel.text = self.model.weekLabel;
//    self.timeLabel.text = self.model.time;
    
    //背景颜色赋值
    
    self.contentView.backgroundColor = self.passedObject.backColor;
    
    //字体颜色解析
    
    UIColor *fontColor = self.passedObject.fontColor;
    
    //字体解析
    NSString *fontNumberString = self.passedObject.fontNumber;
    float fontNumber = [fontNumberString floatValue];
    UIFont *font = [UIFont systemFontOfSize:fontNumber];
    
    if (fontColor == nil) {
        fontColor = [UIColor blackColor];
    }
    
    if (fontNumber ==  0) {
        font = [UIFont systemFontOfSize:15];
    }
    // 富文本
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.contentLabel.text];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:fontColor
                    range:NSMakeRange(0, self.contentLabel.text.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:NSMakeRange(0, self.contentLabel.text.length)];
    
    self.contentLabel.attributedText = attrStr;
}

#pragma mark - 导航栏左右键响应
- (void)backToFront {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editDaily:(UIBarButtonItem *)button {
    self.EditVC.indexPath = self.indexPath;
    self.EditVC.passedObject = self.passedObject;
    
//    __weak WLLNoteDetailViewController *weakSelf = self;
//    self.EditVC.block = ^ (NoteDetail *passedObject){
//        weakSelf.passedObject = passedObject;
//    };
    [self.navigationController pushViewController:self.EditVC animated:YES];
}


#pragma mark - 分享到三方
- (IBAction)sharedToThirdParty:(UIButton *)sender {

}


@end
