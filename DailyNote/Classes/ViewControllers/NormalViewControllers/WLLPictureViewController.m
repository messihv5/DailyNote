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
@end

@implementation WLLPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pictureScrollView.contentOffset = CGPointMake(self.tagOfImageView * kWidth, 0);
    self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)",self.tagOfImageView + 1, self.numberOfPicture];
    
    //scrollView添加content
    [self addContentToPictureScrollView];
    
    //设置scrollView的代理
    self.pictureScrollView.delegate = self;
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
    
    UIView *contentView = [[UIView alloc] initWithFrame:contentViewRect];
    contentView.backgroundColor = [UIColor greenColor];
    
    self.pictureScrollView.contentSize = CGSizeMake(width, height);
    [self.pictureScrollView addSubview:contentView];
    
    NSArray *photoUrlArray = self.passedObject.photoUrlArray;
    
    NSArray *photoArray = self.passedObject.photoArray;
    
    for (NSInteger i = 1; i <= self.numberOfPicture; i++) {
        CGRect scrollViewRect = CGRectMake(kWidth * (i - 1), 0, kWidth, height);
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
        scrollView.contentSize = CGSizeMake(kWidth, height);
        
        CGRect imageViewRect = CGRectMake(0, 0, kWidth, height);
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:imageViewRect];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:scrollView];
        [scrollView addSubview:imageV];
        scrollView.tag = i;
        
        //此处是否不用判断？？？？？？
        if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable) {
            AVFile *file = photoArray[i - 1];
            [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                NSString *urlString = file.url;
                [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
            }];
        } else {
            NSString *urlString = photoUrlArray[i - 1];
            [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
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
    UIView *contentView = [scrollView.subviews objectAtIndex:0];
    
    NSArray *scrollViews = [contentView subviews];
    
    float offset = scrollView.contentOffset.x;
    
    float height = scrollView.frame.size.height;
    
    NSInteger offsetByInteger = offset / kWidth;
    
    for (UIScrollView *scrollView in scrollViews) {
        if (scrollView.tag == offsetByInteger + 1) {
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

- (void)backAction:(UIBarButtonItem *)item {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
