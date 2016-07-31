//
//  WLLPictureViewController.m
//  DailyNote
//
//  Created by Messi on 16/7/23.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLPictureViewController.h"
#import "WLLDailyNoteDataManager.h"

@interface WLLPictureViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *pictureScrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (assign, nonatomic) BOOL isStatusBarHidden;
/**
 *  照片的张数
 */
@property (assign, nonatomic) NSInteger numberOfPicture;
/**
 *  删除按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *deletePictureButton;
/**
 *  删除提示标签
 */
@property (strong, nonatomic) UILabel *reminderLabel;
/**
 *  scrollView的contentView
 */
@property (strong ,nonatomic) UIView *contentView;

@end

@implementation WLLPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([WLLDailyNoteDataManager sharedInstance].isFromDetailViewController) {
        self.numberOfPicture = self.passedObject.photoArray.count;
    } else {
        self.numberOfPicture = self.localPictureArray.count;
    }

    self.pictureScrollView.contentOffset = CGPointMake(self.tagOfImageView * kWidth, 0);
    
    self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)", self.tagOfImageView + 1, self.numberOfPicture];
    
    //scrollView添加content
    [self addContentToPictureScrollView];
    
    //设置scrollView的代理
    self.pictureScrollView.delegate = self;
    
    //显示及隐藏删除按钮
    [self hideOrResumeDeletePictureButton];
    
    //添加删除提示标签
    [self addDeleteReminderLabel];
    
}

/**
 *  添加删除照片的提示标签
 */
- (void)addDeleteReminderLabel {
    CGRect reminderLabelRect = CGRectMake(kWidth / 2 - 40, kHeight / 2 - 20, 80, 40);
    
    self.reminderLabel = [[UILabel alloc] initWithFrame:reminderLabelRect];
    self.reminderLabel.text = @"删除成功";
    self.reminderLabel.hidden = YES;
    self.reminderLabel.layer.masksToBounds = YES;
    self.reminderLabel.layer.cornerRadius = 5;
    self.reminderLabel.backgroundColor = [UIColor darkTextColor];
    
    [self.view addSubview:self.reminderLabel];
}

/**
 *  显示或隐藏删除标签
 */
- (void)hideOrResumeDeletePictureButton {
    if ([WLLDailyNoteDataManager sharedInstance].isFromDetailViewController) {
        self.deletePictureButton.hidden = YES;
    } else {
        self.deletePictureButton.hidden = NO;
    }
}

- (void)addContentToPictureScrollView {
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(backAction:)];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    CGFloat width = kWidth * self.numberOfPicture;
    
    CGFloat height = self.pictureScrollView.frame.size.height;
    
    CGRect contentViewRect = CGRectMake(0, 0, width, height);

    self.contentView = [[UIView alloc] initWithFrame:contentViewRect];

    self.contentView.backgroundColor = [UIColor greenColor];
    
    self.pictureScrollView.contentSize = CGSizeMake(width, height);
    
    [self.pictureScrollView addSubview:self.contentView];
    
    NSArray *photoArray = nil;
    NSArray *photoUrlArray = self.passedObject.photoUrlArray;
    
    if ([WLLDailyNoteDataManager sharedInstance].isFromDetailViewController) {
        photoArray = self.passedObject.photoArray;
    } else {
        photoArray = self.localPictureArray;
    }
    
    for (NSInteger i = 1; i <= self.numberOfPicture; i++) {
        CGRect scrollViewRect = CGRectMake(kWidth * (i - 1), 0, kWidth, height);
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
        
        scrollView.contentSize = CGSizeMake(kWidth, height);
        
        CGRect imageViewRect = CGRectMake(0, 0, kWidth, height);
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:imageViewRect];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:scrollView];
        [scrollView addSubview:imageV];
        scrollView.tag = i - 1;
        scrollView.bounces = NO;
        
        if (photoUrlArray != nil && photoUrlArray.count == photoArray.count) {
            NSString *urlString = photoUrlArray[i - 1];
            
            [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
        } else {
            if ([photoArray[i - 1] isKindOfClass:[AVFile class]]) {
                AVFile *file = photoArray[i - 1];
                [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                    NSString *urlString = file.url;
                    [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
                }];
            } else {
                NSString *urlString = photoArray[i - 1];
                imageV.image = [UIImage imageWithContentsOfFile:urlString];
            }
        }
        
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOrResumeNavigationBar:)];
        [imageV addGestureRecognizer:oneTap];
        imageV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
        [imageV addGestureRecognizer:twoTap];
        twoTap.numberOfTapsRequired = 2;
    }
}

/**
 *  scrollView代理方法
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSArray *scrollViews = [self.contentView subviews];
    
    float offset = scrollView.contentOffset.x;
    
    float height = scrollView.frame.size.height;
    
    NSInteger offsetByInteger = offset / kWidth;
    
    for (UIScrollView *scrollView in scrollViews) {
        if (scrollView.tag == offsetByInteger) {
            scrollView.contentSize = CGSizeMake(kWidth, height);
            
            UIImageView *imageV = [scrollView.subviews objectAtIndex:0];
            
            imageV.frame = CGRectMake(0, 0, kWidth, height);
        }
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)", offsetByInteger + 1, self.numberOfPicture];
    
}

/**
 *  轻击一下图片隐藏或显示导航栏
 *
 *  @param tap 轻击手势
 */
- (void)hiddenOrResumeNavigationBar:(UIGestureRecognizer *)tap {
    if (self.navigationController.navigationBar.hidden == NO) {
        self.navigationController.navigationBar.hidden = YES;
        self.bottomView.hidden = YES;
        self.isStatusBarHidden = YES;
    } else {
        self.navigationController.navigationBar.hidden = NO;
        self.bottomView.hidden = NO;
        self.isStatusBarHidden = NO;
    }
}

/**
 *  轻击两下图片执行的放大图片操作
 *
 *  @param tap 轻击图片
 */
- (void)zoomImage:(UIGestureRecognizer *)tap {
    UIImageView *imageV = (UIImageView *)tap.view;
    
    float height = imageV.frame.size.height;
    
    float width = imageV.frame.size.width;
    
    UIScrollView *scrollView = (UIScrollView *)[imageV superview];
    
    if (width == kWidth) {
        scrollView.contentSize = CGSizeMake(2 * kWidth , 2 * height);
        
        imageV.frame = CGRectMake(0, 0, 2 * kWidth, 2 * height);
        
        scrollView.contentOffset = CGPointMake(kWidth / 2, height / 2);
    } else {
        scrollView.contentSize = CGSizeMake(kWidth, height / 2);
        
        imageV.frame = CGRectMake(0, 0, kWidth, height / 2);
    }
}

/**
 *  返回到上一页面
 *
 *  @param item 点击的UIBarButtonItem
 */
- (void)backAction:(UIBarButtonItem *)item {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  保存图片到手机
 *
 *  @param sender 保存按钮
 */
- (IBAction)savePictureAction:(UIButton *)sender {
    self.reminderLabel.hidden = NO;
    self.reminderLabel.text = @"保存成功";
    self.reminderLabel.textColor = [UIColor whiteColor];
    
    float offset = self.pictureScrollView.contentOffset.x;
    
    NSInteger offsetByInteger = offset / kWidth;
    
    NSArray *scrollViews = self.contentView.subviews;
    
    for (UIScrollView *scrollView in scrollViews) {
        if (scrollView.tag == offsetByInteger) {
            UIImageView *imageV = [scrollView.subviews firstObject];
            
            UIImageWriteToSavedPhotosAlbum(imageV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [self hideReminderLabel:nil];
    } else {        
    }
}
/**
 *  删除图片
 *
 *  @param sender 删除按钮
 */
- (IBAction)deletePictureAction:(UIButton *)sender {
    float offSet = self.pictureScrollView.contentOffset.x;
    
    NSInteger offSetByInteger = offSet / kWidth;
    
    self.contentOffsetBlock(offSetByInteger);
    
    float height = self.pictureScrollView.frame.size.height;
    
    UIView *contentView = [self.pictureScrollView.subviews objectAtIndex:0];
    
    NSArray *scrollViews = contentView.subviews;
    
    if (scrollViews.count == 1) {
        [scrollViews[0] removeFromSuperview];
        self.reminderLabel.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideReminderLabel:) userInfo:nil repeats:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (offSetByInteger < scrollViews.count -1) {
            for (UIScrollView *scrollView in scrollViews) {
                if (scrollView.tag == offSetByInteger) {
                    [scrollView removeFromSuperview];
                    self.numberOfPicture--;
                    self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPicture *kWidth, height);
                }
                
                if (scrollView.tag > offSetByInteger) {
                    CGRect frame = scrollView.frame;
                    frame.origin.x = frame.origin.x - kWidth;
                    scrollView.frame = frame;
                    scrollView.tag--;
                }
                self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)", offSetByInteger +1, self.numberOfPicture];
            }
        } else {
            [[scrollViews lastObject] removeFromSuperview];
            self.numberOfPicture--;
            self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPicture * kWidth, height);
            self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)", self.numberOfPicture, self.numberOfPicture];
        }
    }
    
    [self.localPictureArray removeObjectAtIndex:offSetByInteger];
    [self.internetPictureArray removeObjectAtIndex:offSetByInteger];
}

/**
 *  隐藏删除照片标签
 *
 *  @param timer 计时器
 */
- (void)hideReminderLabel:(NSTimer *)timer {
    self.reminderLabel.hidden = YES;
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
