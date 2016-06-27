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

#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define ScreenWidth  CGRectGetWidth([UIScreen mainScreen].bounds)

@interface WLLNoteDetailViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *aScrollView;
@property (weak, nonatomic) IBOutlet UIView *theContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewTopConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameLabelTopConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UILabel *starNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *secondStarImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondStarNumbelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *readedImageView;
@property (weak, nonatomic) IBOutlet UILabel *readNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation WLLNoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.aScrollView.delegate = self;

    self.navigationItem.title = @"全部";
    
    [self autoLayout];
    
    [self addToolBarButtons];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self parsePersonnalInfo];
}

#pragma mark - scrollViewDelegate方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffset = scrollView.contentOffset.y;
    if (contentOffset < 0) {
        CGFloat heightAfterScroll = ScreenHeight / 3 - contentOffset;
        CGFloat kScale = heightAfterScroll / ScreenHeight * 3;
        self.backgroundImageView.frame = CGRectMake(- ScreenWidth * (kScale - 1) / 2, contentOffset, ScreenWidth * kScale, heightAfterScroll);
    }
}

//解析签名等数据
- (void)parsePersonnalInfo {
    //获取leancloud的Pointer类型的“一”的一方的方法
    NSArray *keys = [NSArray arrayWithObjects:@"belong", nil];
    [self.passedObject fetchInBackgroundWithKeys:keys block:^(AVObject *object, NSError *error) {
        AVUser *user = [object objectForKey:@"belong"];
        self.nickNameLabel.text = [user objectForKey:@"nickName"];
        self.signatureLabel.text = [user objectForKey:@"signature"];
        self.starNumberLabel.text = [user objectForKey:@"starNumber"];
        self.contentLabel.text = [object objectForKey:@"content"];
        
        //获取日期
        NSDate *createdDate = [object objectForKey:@"createdAt"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日EEEE"];
        self.dateLabel.text = [dateFormatter stringFromDate:createdDate];
        
        self.secondStarImageView.image = [UIImage imageNamed:@"star"];
        self.readedImageView.image = [UIImage imageNamed:@"eye2"];
        
        AVFile *backgroundImageFile = [user objectForKey:@"theBackgroundImage"];
        [backgroundImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundImageView.image = [UIImage imageWithData:data];
            });
        }];
        
        AVFile *headImageFile = [user objectForKey:@"headImage"];
        [headImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headImageView.image = [UIImage imageWithData:data];
            });
        }];
        
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

//代码约束
- (void)autoLayout {
    
    self.headImageView.layer.cornerRadius = ScreenHeight / 18;
    self.headImageView.layer.masksToBounds = YES;
    
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nickNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.theContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.headImageViewTopConstrain = [NSLayoutConstraint constraintWithItem:self.headImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:self.headImageView.frame.size.height / 2];
    
    self.nickNameLabelTopConstrain = [NSLayoutConstraint constraintWithItem:self.nickNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:ScreenHeight / 36];
}

//添加底部栏按钮
- (void)addToolBarButtons {
    CGRect backButtonRect = CGRectMake(ScreenWidth / 10 - 20, 10, 40, 40);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = backButtonRect;
    [backButton setImage:[UIImage imageNamed:@"backImage2"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect starButtonRect = CGRectMake(ScreenWidth / 10 - 20  + ScreenWidth / 5, 10, 40, 40);
    UIButton *starButton = [UIButton buttonWithType:UIButtonTypeSystem];
    starButton.frame = starButtonRect;
    [starButton setImage:[UIImage imageNamed:@"starImage2"] forState:UIControlStateNormal];
    [starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect collectionButtoonRect = CGRectMake(ScreenWidth / 10 - 20 + 2 * ScreenWidth / 5, 10, 40, 40);
    UIButton *collectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    collectionButton.frame = collectionButtoonRect;
    [collectionButton setImage:[UIImage imageNamed:@"collectionImage2"] forState:UIControlStateNormal];
    
    CGRect shareButtonRect = CGRectMake(ScreenWidth / 10 - 20 + 3 * ScreenWidth / 5, 10, 40, 40);
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    shareButton.frame = shareButtonRect;
    [shareButton setImage:[UIImage imageNamed:@"shareImage2"] forState:UIControlStateNormal];
    
    CGRect reportButtonRect = CGRectMake(ScreenWidth / 10 - 20 + 4 * ScreenWidth / 5, 10, 40, 40);
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    reportButton.frame = reportButtonRect;
    [reportButton setImage:[UIImage imageNamed:@"reportImage2"] forState:UIControlStateNormal];
    
    [self.toolBarView addSubview:backButton];
    [self.toolBarView addSubview:starButton];
    [self.toolBarView addSubview:collectionButton];
    [self.toolBarView addSubview:shareButton];
    [self.toolBarView addSubview:reportButton];
}

//返回操作
- (void)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//点赞操作
- (void)starAction:(UIButton *)sender {
    
}

@end
