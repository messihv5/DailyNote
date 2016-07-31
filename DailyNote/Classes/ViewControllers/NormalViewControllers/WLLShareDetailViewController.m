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
@property (strong, nonatomic) UILabel *alreadyStaredLabel;
@property (strong ,nonatomic) UILabel *alreadyCollectionLabel;

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

//加载一个显示已经点赞的弹框，加载一个已经收藏的弹框
- (void)addStarAlertView {
    CGRect alertViewRect = CGRectMake(ScreenWidth / 2 - 90, ScreenHeight / 2 - 20, 180, 40);
    UIView *alertView = [[UIView alloc] initWithFrame:alertViewRect];
    
    [self.view addSubview:alertView];
    
    CGRect alertLabelRect = CGRectMake(0, 0, 180, 40);
    self.alreadyStaredLabel = [[UILabel alloc] initWithFrame:alertLabelRect];
    self.alreadyStaredLabel.text = @"你已经点赞";
    self.alreadyStaredLabel.textAlignment = NSTextAlignmentCenter;
    self.alreadyStaredLabel.textColor = [UIColor whiteColor];
    self.alreadyStaredLabel.backgroundColor = [UIColor darkTextColor];
    self.alreadyStaredLabel.alpha = 0.6;
    self.alreadyStaredLabel.hidden = YES;
    self.alreadyStaredLabel.layer.masksToBounds = YES;
    self.alreadyStaredLabel.layer.cornerRadius = 5;
    
    self.alreadyCollectionLabel = [[UILabel alloc] initWithFrame:alertLabelRect];
    self.alreadyCollectionLabel.textAlignment = NSTextAlignmentCenter;
    self.alreadyCollectionLabel.textColor = [UIColor whiteColor];
    self.alreadyCollectionLabel.backgroundColor = [UIColor darkTextColor];
    self.alreadyCollectionLabel.alpha = 0.7;
    self.alreadyCollectionLabel.hidden = YES;
    self.alreadyCollectionLabel.layer.masksToBounds = YES;
    self.alreadyCollectionLabel.layer.cornerRadius = 5;
    
    [alertView addSubview:self.alreadyStaredLabel];
    [alertView addSubview:self.alreadyCollectionLabel];

    
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
    self.starNumberLabel.text = self.passedObject.totalStarNumber;
    self.contentLabel.text = self.passedObject.content;
    self.currentDiaryStarNumberLabel.text = self.passedObject.starNumber;
    
    NSString *readTime = self.passedObject.readTime;
    
    self.readNumberLabel.text = [NSString stringWithFormat:@"%ld", [readTime integerValue] + 1];
    self.passedObject.readTime = self.readNumberLabel.text;
    [object setObject:self.readNumberLabel.text forKey:@"readTime"];
    object.fetchWhenSave = YES;
    [object saveInBackground];
    
    [self.backgroundImageView sd_setImageWithURL:self.passedObject.backgroundImageUrl];
    [self.headImageView sd_setImageWithURL:self.passedObject.headImageUrl];
    
    NSDate *createdDate = self.passedObject.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日EEEE"];
    self.dateLabel.text = [dateFormatter stringFromDate:createdDate];

    //如果用户已点赞，图片设置为已点赞
    NSArray *staredUserArray = self.passedObject.staredUserArray;
    
    if ([staredUserArray containsObject:self.currentUser]) {
        [self.starButton setImage:[UIImage imageNamed:@"heartSelected40X40"] forState:UIControlStateNormal];
    } else {
        [self.starButton setImage:[UIImage imageNamed:@"heart40X40"] forState:UIControlStateNormal];
    }
    
    //如果用户已收藏，图片设置为已收藏
    AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
    
    AVQuery *relationQuery = [collectionRelation query];
    
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects containsObject:object]) {
            [self.collectionButton setImage:[UIImage imageNamed:@"collectionSelected"] forState:UIControlStateNormal];
        } else {
            [self.collectionButton setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
        }
    }];
}

//代码布局
- (void)layoutHeadImageViewAndNickNameLabel {
    
    //设置图片
    self.starImageView.image = [UIImage imageNamed:@"heart40X40"];
    self.currentDiaryStarImageView.image = [UIImage imageNamed:@"heartSelected15X15"];
    self.readImageView.image = [UIImage imageNamed:@"eye15X15"];
    
    self.headImageViewTopConstraint.constant = ScreenHeight / 18;
    self.headImageViewTopConstraint.active = YES;
    
    self.nickNameLabelTopConstraint.constant = ScreenHeight / 36;
    self.nickNameLabelTopConstraint.active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

//添加底部栏按钮
- (void)addToolBarButtons {
    CGRect backButtonRect = CGRectMake(ScreenWidth / 10 - 15, 15, 30, 30);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = backButtonRect;
    [backButton setImage:[UIImage imageNamed:@"backImage2"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect starButtonRect = CGRectMake(ScreenWidth / 10 - 15  + ScreenWidth / 5, 15, 30, 30);
    self.starButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.starButton.frame = starButtonRect;
    [self.starButton setImage:[UIImage imageNamed:@"heart40X40"] forState:UIControlStateNormal];
    [self.starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect collectionButtoonRect = CGRectMake(ScreenWidth / 10 - 15 + 2 * ScreenWidth / 5, 15, 30, 30);
    self.collectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.collectionButton.frame = collectionButtoonRect;
    [self.collectionButton setImage:[UIImage imageNamed:@"collectionImage2"] forState:UIControlStateNormal];
    [self.collectionButton addTarget:self action:@selector(collectionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect shareButtonRect = CGRectMake(ScreenWidth / 10 - 15 + 3 * ScreenWidth / 5, 15, 30, 30);
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    shareButton.frame = shareButtonRect;
    [shareButton setImage:[UIImage imageNamed:@"shareImage2"] forState:UIControlStateNormal];
    
    CGRect reportButtonRect = CGRectMake(ScreenWidth / 10 - 15 + 4 * ScreenWidth / 5, 15, 30, 30);
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    reportButton.frame = reportButtonRect;
    [reportButton setImage:[UIImage imageNamed:@"reportImage2"] forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBarView addSubview:backButton];
    [self.toolBarView addSubview:self.starButton];
    [self.toolBarView addSubview:self.collectionButton];
    [self.toolBarView addSubview:shareButton];
    [self.toolBarView addSubview:reportButton];
}

//返回操作
- (void)backAction:(UIButton *)sender {
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
            self.alreadyStaredLabel.hidden = NO;
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
    
    [self.starButton setImage:[UIImage imageNamed:@"heartSelected40X40"] forState:UIControlStateNormal];
    
    //如果该用户没有点赞，UI上的点赞数加1
    NSInteger numberOfStar = [self.currentDiaryStarNumberLabel.text integerValue];
    self.currentDiaryStarNumberLabel.text = [NSString stringWithFormat:@"%ld", numberOfStar + 1];
        
    self.alreadyStaredLabel.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
}

//收藏操作
- (void)collectionAction:(UIButton *)sender {
    AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
    
    AVQuery *collectionQuery = [collectionRelation query];
    
    AVObject *diary = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    [collectionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects containsObject:diary]) {
            
            //已经收藏，点击之后取消收藏
            [collectionRelation removeObject:diary];
            [self.currentUser saveInBackground];
            
            self.alreadyCollectionLabel.hidden = NO;
            self.alreadyCollectionLabel.text = @"已取消收藏";
            [sender setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
            [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(hidesAlertLabel)
                                           userInfo:nil
                                            repeats:NO];
            
            //如果是从收藏页面进来的，点取消收藏时，给收藏主页面发通知，让其删除已经取消收藏的日记
            if (self.passedIndexPath) {
                NSDictionary *usrInfo = @{@"passedObject":self.passedObject};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteThisDiariyCollection"
                                                                    object:nil
                                                                  userInfo:usrInfo];
            }
        } else {
            
            //没有收藏
            [diary saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                } else {
                    AVRelation *collectionRelation = [self.currentUser relationForKey:@"collectionDiaries"];
                    [collectionRelation addObject:diary];
                    [self.currentUser saveInBackground];
                    
                    self.alreadyCollectionLabel.hidden = NO;
                    self.alreadyCollectionLabel.text = @"已收藏";
                    [self.collectionButton setImage:[UIImage imageNamed:@"collectionSelected"] forState:UIControlStateNormal];
                    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidesAlertLabel) userInfo:nil repeats:NO];
                }
            }];
        }
    }];
}

//举报操作
- (void)reportAction:(UIButton *)sender {
    LCUserFeedbackViewController *feedBackVC = [[LCUserFeedbackViewController alloc] init];
    
    feedBackVC.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
    feedBackVC.contactHeaderHidden = NO;
    feedBackVC.feedbackTitle = [NSString stringWithFormat:@"举报日记%@", self.passedObject.diaryId];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedBackVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

//隐藏alertLabel
- (void)hidesAlertLabel {
    self.alreadyStaredLabel.hidden = YES;
    self.alreadyCollectionLabel.hidden = YES;
}

-(void)dealloc {
    [WLLDailyNoteDataManager sharedInstance].isReport = NO;
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
