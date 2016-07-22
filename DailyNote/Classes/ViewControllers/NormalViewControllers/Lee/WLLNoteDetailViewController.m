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
/* 背景 */
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIImageView *noteImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NoteDetail *model;
/*图片数组*/
@property (strong, nonatomic) NSMutableArray *photoArray;
/*图片url数组*/
@property (strong, nonatomic) NSMutableArray *photoUrlArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@end

@implementation WLLNoteDetailViewController

@dynamic title;

#pragma mark - View Load
- (void)viewDidLoad {
    [super viewDidLoad];
    // 标题
    self.navigationItem.title = @"日记详情";
    
    self.photoArray = self.passedObject.photoArray;
    
    self.photoUrlArray = self.passedObject.photoUrlArray;
    
    // 将日志页面cell下标赋给控制详情页面翻页
    self.indexs = self.indexPath.row;
    
    //添加导航栏按钮
    [self addNavigationButtons];
}

//删除日记方法
- (void)deleteDiary:(UIBarButtonItem *)sender {
    if (self.passedObject.diaryId != nil) {
        AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
        
        [object setObject:@"YES" forKey:@"wasDeleted"];
        [object saveInBackground];
        
        //让dailyNote页面执行删除日记操作
        self.deleteDiary();
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self addTipNote];
    }
}

/**
 *  当日记还没有保存好时，弹出提示框
 */
- (void)addTipNote {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"网络忙，请稍后尝试谢谢!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:alertAction];
    [self.navigationController presentViewController:alertVC animated:YES completion:nil];
}

//添加导航栏按钮
- (void)addNavigationButtons {
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
    
    UIBarButtonItem *deleteDiary = [[UIBarButtonItem alloc] initWithTitle:@"删除日记" style:UIBarButtonItemStylePlain target:self action:@selector(deleteDiary:)];
    
    self.navigationItem.rightBarButtonItems = @[rightItem, deleteDiary];
}

//图片数组懒加载
- (NSMutableArray *)photoArray {
    if (_photoArray == nil) {
        _photoArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _photoArray;
}

- (void)addNoteImages {
    
    CGRect rect = [self heightForContentLabel];
    CGRect frame = self.contentLabel.frame;
    frame.size.height = rect.size.height;
    self.contentLabel.frame = frame;
    
    float y = CGRectGetMaxY(self.contentLabel.frame) + 20;
    
    NSInteger index = 0;
    
    NSInteger numberOfRow = 0;
    
    NSInteger countOfarray = self.photoArray.count;
    
    if (countOfarray % 2 == 0) {
        numberOfRow = countOfarray / 2;
    } else {
        numberOfRow = countOfarray / 2 + 1;
    }
    
    for (int i = 0; i < numberOfRow; i++) {
        for (int j = 0; j < 2; j++) {
            UIImageView *imageV = [[UIImageView alloc] init];
            imageV.frame = CGRectMake(10+(kWidth-30)/2*j+10*j, y+0.2*kHeight*i+10*i, (kWidth-30)/2, 0.2*kHeight);
            imageV.backgroundColor = [UIColor whiteColor];
            
            imageV.layer.masksToBounds = YES;
            imageV.layer.cornerRadius = 5.0f;
            [self.contentView addSubview:imageV];
            
            if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable) {
                if (self.photoArray != nil && index < countOfarray &&self.photoArray.count != 0) {
                    if ([self.photoArray[index] isKindOfClass:[AVFile class]]) {
                        AVFile *file = self.photoArray[index];
                        [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                            [imageV sd_setImageWithURL:[NSURL URLWithString:file.url]];
                                                    }];
                    } else {
                        NSString *path = self.photoArray[index];
                        imageV.image = [UIImage imageWithContentsOfFile:path];
                    }
                }

            } else {
                if (self.photoUrlArray != nil && index < self.photoUrlArray.count && self.photoUrlArray.count != 0) {
                    NSURL *url = [NSURL URLWithString:self.photoUrlArray[index]];
                    [imageV sd_setImageWithURL:url];
                }
            }
            index++;
        }
    }
    self.contentViewHeight.constant = y+5*0.2*kHeight+50-kHeight;
}


- (CGRect)heightForContentLabel {
    
    // 计算：1 获取要计算的字符串
    NSString *temp = self.contentLabel.text;
    // 计算：2 准备工作
    // 宽度和label的宽度一样，高度给一个巨大的值
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 2000);
    // 这里要和上面label指定的字体一样
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    // 计算：3 调用方法，获得rect
    CGRect rect = [temp boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    // 计算：4 获取当前的label的frame，并将新的frame重新设置上去
    return rect;
}


// view将要出现时加载左右按键
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];

    // 本页数据加载自日志页面
    [self dataFromNoteDaily];
    
    [self addNoteImages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *views = [self.contentView subviews];
    
    for (UIView *view in views) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
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
    
    //通过传过来的model查询AVObject、
    AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    [object fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        //背景颜色赋值
        NSData *backColorData = [object objectForKey:@"backColor"];
        NSKeyedUnarchiver *backColorUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:backColorData];
        self.contentView.backgroundColor = [backColorUnarchiver decodeObjectForKey:@"backColor"];
        
        //字体颜色解析
        NSData *fontColorData = [object objectForKey:@"fontColor"];
        NSKeyedUnarchiver *fontColorUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:fontColorData];
        UIColor *fontColor = [fontColorUnarchiver decodeObjectForKey:@"fontColor"];
        
        //字体解析
        NSString *fontNumberString = [object objectForKey:@"fontNumber"];
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
    }];
}

#pragma mark - 导航栏左右键响应
- (void)backToFront {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editDaily:(UIBarButtonItem *)button {
    EditNoteViewController *editVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:[NSBundle mainBundle]];
    editVC.indexPath = self.indexPath;
    editVC.passedObject = self.passedObject;
    
    [self.navigationController pushViewController:editVC animated:YES];
}


#pragma mark - 分享到三方
- (IBAction)sharedToThirdParty:(UIButton *)sender {

}


@end
