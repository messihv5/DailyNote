//
//  WLLShareDetailViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/21.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLShareDetailViewController.h"
#import "WLLDailyNoteDataManager.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>

#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface WLLShareDetailViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *aScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UILabel *starNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentDiaryStarImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDiaryStarNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *readImageView;
@property (weak, nonatomic) IBOutlet UILabel *readNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) AVUser *currentUser;
/**
 *  点赞按钮
 */
@property (strong, nonatomic) UIButton *starButton;
/**
 *  收藏按钮
 */
@property (strong, nonatomic) UIButton *collectionButton;
@property (strong, nonatomic) UILabel *reminderLabel;
/**
 *  contentView的高度约束，用于计算需要的高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (strong, nonatomic) NSMutableArray *collectionDiaries;

@end

@implementation WLLShareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addToolBarButtons];
    
    [self addStarAlertView];
    
    self.currentUser = [AVUser currentUser];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.aScrollView.delegate = self;
    
    self.headImageView.layer.cornerRadius = ScreenHeight / 18;
    self.headImageView.layer.masksToBounds = YES;
    
    [self layoutHeadImageViewAndNickNameLabel];
    
    [self loadPersonnalInfo];
    
    [WLLDailyNoteDataManager sharedInstance].isReport = YES;
}

- (NSMutableArray *)collectionDiaries {
    if (_collectionDiaries == nil) {
        _collectionDiaries = [NSMutableArray arrayWithCapacity:5];
    }
    return _collectionDiaries;
}

//加载一个显示已经点赞的弹框，加载一个已经收藏的弹框
- (void)addStarAlertView {
    CGRect alertViewRect = CGRectMake(ScreenWidth / 2 - 90, ScreenHeight / 2 - 20, 180, 40);
    UIView *alertView = [[UIView alloc] initWithFrame:alertViewRect];
    
    [self.view addSubview:alertView];
    
    CGRect alertLabelRect = CGRectMake(0, 0, 180, 40);
    self.reminderLabel = [[UILabel alloc] initWithFrame:alertLabelRect];
    self.reminderLabel.text = @"你已经点赞";
    self.reminderLabel.textAlignment = NSTextAlignmentCenter;
    self.reminderLabel.textColor = [UIColor whiteColor];
    self.reminderLabel.backgroundColor = [UIColor darkTextColor];
    self.reminderLabel.alpha = 0.6;
    self.reminderLabel.hidden = YES;
    self.reminderLabel.layer.masksToBounds = YES;
    self.reminderLabel.layer.cornerRadius = 5;
    
    [alertView addSubview:self.reminderLabel];
}

//scrollView滑动方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat verticalOffSet = scrollView.contentOffset.y;
    if (verticalOffSet < 0) {
        CGFloat originalHeight = ScreenHeight / 3;
        CGFloat heightAfterMove = originalHeight - verticalOffSet;
        CGFloat zoomingScale = heightAfterMove / originalHeight;
        
        self.backgroundImageView.frame = CGRectMake(ScreenWidth * (1- zoomingScale)/ 2, verticalOffSet, ScreenWidth * zoomingScale, heightAfterMove);
    }
}

//加载传过来的信息
- (void)loadPersonnalInfo {
    AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    self.nickNameLabel.text = self.passedObject.nickName;
    self.signatureLabel.text = self.passedObject.signature;
    self.starNumberLabel.text = [self.currentUser objectForKey:@"starNumber"];
    self.contentLabel.text = self.passedObject.content;
    self.currentDiaryStarNumberLabel.text = self.passedObject.starNumber;
    
    NSString *readTime = self.passedObject.readTime;
    
    self.readNumberLabel.text = [NSString stringWithFormat:@"%ld", [readTime integerValue] + 1];
    self.passedObject.readTime = self.readNumberLabel.text;
    [object setObject:self.readNumberLabel.text forKey:@"readTime"];
    object.fetchWhenSave = YES;
    [object saveInBackground];
    
    if (self.passedObject.backgroundImageUrl == nil) {
        self.backgroundImageView.image = [UIImage imageNamed:@"appIconBackgroundImage"];
    } else {
        [self.backgroundImageView sd_setImageWithURL:self.passedObject.backgroundImageUrl];
    }
    
    if (self.passedObject.headImageUrl == nil) {
        self.headImageView.image = [UIImage imageNamed:@"appIconHeadImage"];
    } else {
        [self.headImageView sd_setImageWithURL:self.passedObject.headImageUrl];
    }
    
    NSDate *createdDate = self.passedObject.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 EE"];
    self.dateLabel.text = [dateFormatter stringFromDate:createdDate];

    //如果用户已点赞，图片设置为已点赞
    NSArray *staredUserArray = self.passedObject.staredUserArray;
    
    if ([staredUserArray containsObject:self.currentUser]) {
        [self.starButton setImage:[UIImage imageNamed:@"heartSelectedImage"] forState:UIControlStateNormal];
    } else {
        [self.starButton setImage:[UIImage imageNamed:@"heartImage"] forState:UIControlStateNormal];
    }
    
    //如果用户已收藏，图片设置为已收藏
    self.collectionDiaries = self.passedObject.collectionDiaries;
    
    if ([self.collectionDiaries containsObject:object]) {
        [self.collectionButton setImage:[UIImage imageNamed:@"fiveStarImageSelected"] forState:UIControlStateNormal];
    } else {
        [self.collectionButton setImage:[UIImage imageNamed:@"fiveStarImage"] forState:UIControlStateNormal];
    }
}

//代码布局
- (void)layoutHeadImageViewAndNickNameLabel {
    
    //设置图片
    self.starImageView.image = [UIImage imageNamed:@"heartImage"];
    self.currentDiaryStarImageView.image = [UIImage imageNamed:@"heartSelected15X15"];
    self.readImageView.image = [UIImage imageNamed:@"eye15X15"];
    
    self.headImageViewTopConstraint.constant = ScreenHeight / 18;
    self.headImageViewTopConstraint.active = YES;
    
    self.nickNameLabelTopConstraint.constant = ScreenHeight / 36;
    self.nickNameLabelTopConstraint.active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self calculateScrollViewContentViewHeight];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

//添加底部栏按钮
- (void)addToolBarButtons {
    CGRect backButtonRect = CGRectMake(ScreenWidth / 8 - 15, 15, 30, 30);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = backButtonRect;
    [backButton setImage:[UIImage imageNamed:@"backImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect starButtonRect = CGRectMake(ScreenWidth / 8 - 15  + ScreenWidth / 4, 15, 30, 30);
    self.starButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.starButton.frame = starButtonRect;
    [self.starButton setImage:[UIImage imageNamed:@"heartImage"] forState:UIControlStateNormal];
    [self.starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect collectionButtoonRect = CGRectMake(ScreenWidth / 8 - 15 + 2 * ScreenWidth / 4, 15, 30, 30);
    self.collectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.collectionButton.frame = collectionButtoonRect;
    [self.collectionButton setImage:[UIImage imageNamed:@"fiveStarImage"] forState:UIControlStateNormal];
    [self.collectionButton addTarget:self action:@selector(collectionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect reportButtonRect = CGRectMake(ScreenWidth / 8 - 15 + 3 * ScreenWidth / 4, 15, 30, 30);
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    reportButton.frame = reportButtonRect;
    [reportButton setImage:[UIImage imageNamed:@"reportImage"] forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBarView addSubview:backButton];
    [self.toolBarView addSubview:self.starButton];
    [self.toolBarView addSubview:self.collectionButton];
    [self.toolBarView addSubview:reportButton];
}

//返回操作
- (void)backAction:(UIButton *)sender {
    if (self.passedIndexPath) {
        NSDictionary *dic = @{@"passedObject":self.passedObject};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sharePageToUpdateThreeInfo" object:nil userInfo:dic];
    }
   
    [self.navigationController popViewControllerAnimated:YES];
}

//点赞操作
- (void)starAction:(UIButton *)sender {
    AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    NoteDetail *diary = self.passedObject;
    
    NSMutableArray *staredUserArray = self.passedObject.staredUserArray;
    
    if (staredUserArray == nil) {
        
        //第一次查询时点赞用户数组为空
        NSMutableArray *staredUserArray = [NSMutableArray arrayWithCapacity:10];
        
        //日记里面保存的点赞数字显示1
        NSString *num = @"1";
        diary.starNumber = num;
        [object setObject:num forKey:@"starNumber"];
        
        //把点赞的用户添加到数组中，以便下次点赞时进行判断
        AVUser *user = [AVUser currentUser];
        
        //把点赞的用户添加到diary的数组中保存
        [staredUserArray addObject:user];
        [object setObject:staredUserArray forKey:@"staredUser"];
        diary.staredUserArray = staredUserArray;
        
        object.fetchWhenSave = YES;
        [object saveInBackground];
    } else {
        
        //如果该用户已经点赞
        if ([staredUserArray containsObject:[AVUser currentUser]]) {
            self.reminderLabel.hidden = NO;
            self.reminderLabel.text = @"已经点赞";
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
            return;
        } else {
            
            //该用户没有点赞
            //日记里面保存的点赞数字也加1
            NSString *num = diary.currentDiaryStarNumber;
            num = [NSString stringWithFormat:@"%ld", [num integerValue] + 1];
            diary.starNumber = num;
            [object setObject:num forKey:@"starNumber"];
            
            //把点赞的用户添加到数组中，以便下次点赞时进行判断
            AVUser *user = [AVUser currentUser];
            
            //把点赞的用户添加到diary的数组中保存
            [staredUserArray addObject:user];
            
            object.fetchWhenSave = YES;
            [object setObject:staredUserArray forKey:@"staredUser"];
            [object saveInBackground];
        }
    }
    
    [self.starButton setImage:[UIImage imageNamed:@"heartSelectedImage"] forState:UIControlStateNormal];
    
    //如果该用户没有点赞，UI上的点赞数加1
    NSInteger numberOfStar = [self.currentDiaryStarNumberLabel.text integerValue];
    self.currentDiaryStarNumberLabel.text = [NSString stringWithFormat:@"%ld", numberOfStar + 1];
        
    self.reminderLabel.hidden = NO;
    self.reminderLabel.hidden = @"谢谢点赞";
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
}

//收藏操作
- (void)collectionAction:(UIButton *)sender {
    NSMutableArray *collectionDiaries = self.passedObject.collectionDiaries;
    
    AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    if ([collectionDiaries containsObject:object]) {
        //已经收藏了该日记，点击取消收藏,删除model里的数据及数据库里的数据
        [collectionDiaries removeObject:object];
        
        AVRelation *collectionRelation = [[AVUser currentUser] relationForKey:@"collectionDiaries"];
        
        AVQuery *collectionQuery = [collectionRelation query];
        
        [collectionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [collectionRelation removeObject:object];
            [self.currentUser saveInBackground];
        }];
        
        //提示信息处理
        self.reminderLabel.hidden = NO;
        self.reminderLabel.text = @"已取消收藏";
        [sender setImage:[UIImage imageNamed:@"fiveStarImage"] forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
        
        //如果是从收藏页面进来的，点击取消收藏，给收藏页面发送通知，删除该篇日记
        if (self.passedIndexPath) {
            NSDictionary *userInfo = @{@"passedObject":self.passedObject};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteThisDiaryCollection" object:nil userInfo:userInfo];
        }
    } else {
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //添加数据
                [collectionDiaries addObject:object];
                
                AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
                
                [collectionRelation addObject:object];
                [self.currentUser saveInBackground];
                
                self.reminderLabel.hidden = NO;
                self.reminderLabel.text = @"已收藏";
                [sender setImage:[UIImage imageNamed:@"fiveStarImageSelected"] forState:UIControlStateNormal];
                [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(hidesAlertLabel)
                                               userInfo:nil
                                                repeats:NO];
                
            } else {
                
            }
        }];
    }
    
}

//举报操作
- (void)reportAction:(UIButton *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"举报" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *salacityAction = [UIAlertAction actionWithTitle:@"色情" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.reminderLabel.hidden = NO;
        self.reminderLabel.text = @"举报成功";
        [self reportActionOfTitle:@"色情"];
    }];
    
    UIAlertAction *violenceAction = [UIAlertAction actionWithTitle:@"暴力" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.reminderLabel.hidden = NO;
        self.reminderLabel.text = @"举报成功";
        [self reportActionOfTitle:@"暴力"];
    }];
    
    UIAlertAction *illegalAction = [UIAlertAction actionWithTitle:@"违法" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.reminderLabel.hidden = NO;
        self.reminderLabel.text = @"举报成功";
        [self reportActionOfTitle:@"违法"];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.reminderLabel.hidden = NO;
        self.reminderLabel.text = @"举报成功";
        [self reportActionOfTitle:@"其他"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertVC addAction:salacityAction];
    [alertVC addAction:violenceAction];
    [alertVC addAction:illegalAction];
    [alertVC addAction:otherAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)reportActionOfTitle:(NSString *)title {
    NSString *reportTitle = [NSString stringWithFormat:@"%@%@", title, self.passedObject.diaryId];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
    [LCUserFeedbackThread feedbackWithContent:reportTitle contact:self.currentUser.username withBlock:^(id object, NSError *error) {
    }];
}

//隐藏alertLabel
- (void)hidesAlertLabel {
    self.reminderLabel.hidden = YES;
}

/**
 *  计算contentView的高度
 */
- (void)calculateScrollViewContentViewHeight {
    float yCoordinateOfContentLabel = CGRectGetMinY(self.contentLabel.frame);
    
    float yCoordinateOfToolBarView = CGRectGetMinY(self.toolBarView.frame);
    
    float contentLabelToToolBarView = yCoordinateOfToolBarView - yCoordinateOfContentLabel;
    
    float height = [self heightForText:self.passedObject.content];
    
    self.contentViewHeight.constant = height - contentLabelToToolBarView + 20;
}

/**
 *  计算label的高度
 *
 *  @param text label的text
 *
 *  @return label的高度
 */
- (float)heightForText:(NSString *)text {
    CGSize largeSize = CGSizeMake(kWidth - 40, 2000);
    
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0]};
    
    CGRect contentLabelRect = [text boundingRectWithSize:largeSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    return contentLabelRect.size.height;
}

-(void)dealloc {
    [WLLDailyNoteDataManager sharedInstance].isReport = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sharePageToUpdateThreeInfo" object:nil];
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
