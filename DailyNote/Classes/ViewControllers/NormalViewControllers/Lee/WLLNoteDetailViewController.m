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
#import "WLLPictureViewController.h"

@interface WLLNoteDetailViewController ()
/* 日记-年月标签 */
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
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
/**
 *  用于计算回到上篇日记
 */
@property (assign, nonatomic) NSInteger lastDiary;
/**
 *  用于计算到下一篇日记
 */
@property (assign, nonatomic) NSInteger nextDiary;
/**
 *  天气图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
/**
 *  位置图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
/**
 *  位置label
 */
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation WLLNoteDetailViewController

@dynamic title;

#pragma mark - View Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastDiary = self.indexPath.row;
    
    self.nextDiary = self.indexPath.row;
    
    // 标题
    self.navigationItem.title = @"日记详情";
    
    // 将日志页面cell下标赋给控制详情页面翻页
    self.indexs = self.indexPath.row;
    
    //添加导航栏按钮
    [self addNavigationButtons];
}

//删除日记方法
- (void)deleteDiary:(UIBarButtonItem *)sender {
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable == NO) {
        [self addTipNoteToButton:sender];
    } else {
        if (self.passedObject.diaryId != nil) {
            AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
            
            [object setObject:@"YES" forKey:@"wasDeleted"];
            [object saveInBackground];
            
            //share页面,及dailyNote页面执行删除日记操作
            NSDictionary *dic = [NSDictionary dictionaryWithObject:self.passedObject.diaryId forKey:@"objectId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dailyNoteAndSharePageDeleteDiary" object:nil userInfo:dic];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self addTipNoteToButton:sender];
        }
    }
}

/**
 *  当日记还没有保存好及网络错误时，弹出提示框
 */
- (void)addTipNoteToButton:(UIBarButtonItem *)button {
    UIAlertController *alertVC;
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable ) {
         alertVC = [UIAlertController alertControllerWithTitle:@"网络忙，请稍后尝试谢谢!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:@"网络错误，不能删除、编辑" message:nil preferredStyle:UIAlertControllerStyleAlert];
    }
    
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
    left.tintColor = [UIColor whiteColor];
    
    // 右边
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNote"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(editDaily:)];
    rightItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *deleteDiary = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"deleteImage30X30"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteDiary:)];
    deleteDiary.tintColor = [UIColor whiteColor];
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
    
    //照片数组
    self.photoArray = self.passedObject.photoArray;
    self.photoUrlArray = self.passedObject.photoUrlArray;
    
    NSString *fontNumberString = self.passedObject.fontNumber;
    
    float fontNumber = 0.0;
    
    if (fontNumberString == nil) {
        fontNumber = 17.0;
    } else {
        fontNumber = [fontNumberString floatValue];
    }
    
    CGRect rect = [self heightForContentLabelWithFontNumber:fontNumber];
    CGRect frame = self.contentLabel.frame;
    frame.size.height = rect.size.height;
    self.contentLabel.frame = frame;
    
    float y = CGRectGetMaxY(self.contentLabel.frame) + 10;
    
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
            if (index < self.photoArray.count) {
                UIImageView *imageV = [[UIImageView alloc] init];
                imageV.frame = CGRectMake(10 + (kWidth - 30) / 2 * j + 10 * j, y + 0.2 * kHeight * i + 10 * i, (kWidth - 30) / 2, 0.2 * kHeight);
                imageV.backgroundColor = [UIColor cyanColor];
                imageV.tag = index;
                
                //给imageView添加点击事件
                imageV.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentPictureAction:)];
                [imageV addGestureRecognizer:tapGesture];
                
                imageV.layer.masksToBounds = YES;
                imageV.layer.cornerRadius = 5.0f;
                [self.contentView addSubview:imageV];
   //********考虑考虑考虑
//                if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable) {
//                    //有网络的时候，网络加载图片
//                    if (self.photoArray != nil && self.photoArray.count != 0) {
//                        if ([self.photoArray[index] isKindOfClass:[AVFile class]]) {
//                            AVFile *file = self.photoArray[index];
//                            [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
//                                [imageV sd_setImageWithURL:[NSURL URLWithString:file.url]];
//                            }];
//                        } else {
//                            NSString *path = self.photoArray[index];
//                            imageV.image = [UIImage imageWithContentsOfFile:path];
//                        }
//                    }
//                } else {
//                    //没有网络的时候，如果有缓存，加载缓存，没有缓存，为空
//                    if (self.photoUrlArray != nil && self.photoUrlArray.count != 0) {
//                        NSURL *url = [NSURL URLWithString:self.photoUrlArray[index]];
//                        [imageV sd_setImageWithURL:url];
//                    }
//                }
//
                if (self.photoUrlArray != nil && self.photoUrlArray.count == self.photoArray.count) {
                    NSString *urlString = self.photoUrlArray[index];
                    [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
                } else {
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
                index++;
            }
        }
    }
    if (numberOfRow <= 4) {
        self.contentViewHeight.constant = rect.size.height;
    } else {
        self.contentViewHeight.constant = (numberOfRow - 4) * (0.2 * kHeight + 20) + rect.size.height;
    }
}

/**
 *  点击图片手势，执行的方法
 *
 *  @param tap 轻击手势
 */
- (void)presentPictureAction:(UITapGestureRecognizer *)tap {
    WLLPictureViewController *pictureVC = [[WLLPictureViewController alloc] initWithNibName:@"WLLPictureViewController"
                                                                                     bundle:[NSBundle mainBundle]];
    pictureVC.tagOfImageView = tap.view.tag;
    pictureVC.passedObject = self.passedObject;
    
    [WLLDailyNoteDataManager sharedInstance].isFromDetailViewController = YES;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pictureVC];
    
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (CGRect)heightForContentLabelWithFontNumber:(float)fontNumber {
    
    // 计算：1 获取要计算的字符串
    NSString *temp = self.contentLabel.text;
    // 计算：2 准备工作
    // 宽度和label的宽度一样，高度给一个巨大的值
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 2000);
    // 这里要和上面label指定的字体一样
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontNumber]};
    
    // 计算：3 调用方法，获得rect
    CGRect rect = [temp boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    // 计算：4 获取当前的label的frame，并将新的frame重新设置上去
    return rect;
}


// view将要出现时加载左右按键
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];

    //本页数据加载自日志页面，每次将要出现时，从新加载一次，相当于tableview的reload
    [self dataFromNoteDailyModel:self.passedObject];
    
    //添加照片
    [self addNoteImages];

    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //视图消失时，移除所有的图片imageView
    [self removeAllImageView];
}

//移除图片imageView
- (void)removeAllImageView {
    NSArray *views = [self.contentView subviews];
    
    for (UIView *view in views) {
        if ([view isKindOfClass:[UIImageView class]] && view.tag < 100) {
            [view removeFromSuperview];
        }
    }
}

/**
 *  从dailyNote页面获取model，并加载detail页面的内容
 *
 *  @param model 日记model
 */
- (void)dataFromNoteDailyModel:(NoteDetail *)model {
    //日记内容赋值
    self.contentLabel.text = model.content;
    
    //日记日期赋值
    NSDate *createdAt = model.date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日 H:mm"];
    
    NSString *dateString = [formatter stringFromDate:createdAt];
    
    self.monthAndYearLabel.text = dateString;
    
    //背景颜色
    self.contentView.backgroundColor = self.passedObject.backColor;
    
    //字体颜色
    UIColor *fontColor = self.passedObject.fontColor;
    
    //字体大小
    NSString *fontNumberString = self.passedObject.fontNumber;
    
    UIFont *font = [UIFont systemFontOfSize:[fontNumberString floatValue]];
        
    self.contentLabel.textColor = fontColor;
    self.contentLabel.font = font;
    
    //天气图标
    self.weatherImageView.image = model.weatherImage;
    
    //是否显示地理位置
    NSString *locationString = [[AVUser currentUser] objectForKey:@"displayAddress"];
    if ([locationString isEqualToString:@"NO"] || model.locationString == nil) {
        self.locationLabel.hidden = YES;
        self.locationImageView.image = nil;
    } else {
        self.locationLabel.hidden = NO;
        
        //地理位置信息
        self.locationLabel.text = model.locationString;
    }
}

#pragma mark - 导航栏左右键响应
- (void)backToFront {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editDaily:(UIBarButtonItem *)button {
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable == NO) {
        [self addTipNoteToButton:button];
    } else {
        EditNoteViewController *editVC = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:[NSBundle mainBundle]];
        editVC.indexPath = self.indexPath;
        editVC.passedObject = self.passedObject;
        editVC.isFromeCalendar = self.isFromCalendar;
        
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

- (IBAction)lastDiaryAction:(UIButton *)sender {
    if (self.lastDiary > 0) {
        [self removeAllImageView];
        self.lastDiary--;
        self.nextDiary--;
        self.lastDiaryBlock(self.lastDiary);
        self.photoArray = self.passedObject.photoArray;
        self.photoUrlArray = self.passedObject.photoUrlArray;
        [self dataFromNoteDailyModel:self.passedObject];
        [self addNoteImages];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"没有上篇日记" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

- (IBAction)nextDiaryAction:(UIButton *)sender {
    
    if (self.nextDiary < self.numberOfDiary - 1) {
        [self removeAllImageView];
        self.nextDiary++;
        self.lastDiary++;
        self.nextDiaryBlock(self.nextDiary);
        self.photoArray = self.passedObject.photoArray;
        self.photoUrlArray = self.passedObject.photoUrlArray;
        [self dataFromNoteDailyModel:self.passedObject];
        [self addNoteImages];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"没有下篇日记" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

@end
