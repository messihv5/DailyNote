//
//  EditNoteViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "EditNoteViewController.h"
#import "WLLCategoryButton.h"
#import "WLLDailyNoteDataManager.h"
#import "WLLToolView.h"
#import "WLLNoteDetailViewController.h"
#import "WLLFontView.h"
#import "WLLNoteBackgroundColorView.h"
#import "WLLMoodView.h"
#import "WLLNoteBackgroundChoice.h"
#import <CoreLocation/CoreLocation.h>
#import "SDImageCache.h"
#import "WLLPictureViewController.h"

#import "WLLAssetPickerController.h"
#import "WLLAssetPickerState.h"

@interface EditNoteViewController ()<UITextViewDelegate, ToolViewDelegate, ChangeFontDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChangeNoteBackgroundColorDelegate, CancelChoiceDelegate, CLLocationManagerDelegate>
/* 判断日记分类页面隐藏与否 */
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
/* 控制键盘显示/隐藏 */
@property (nonatomic, assign) BOOL is;
/* 编辑框 */
@property (weak, nonatomic) IBOutlet UITextView *contentText;
/* 计数标签 */
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
/* 键盘上方工具条 */
@property (nonatomic, weak) WLLToolView *toolView;
/* 字体视图 */
@property (nonatomic, strong) WLLFontView *fontView;
/* 存储分类按钮 */
@property (nonatomic, weak) UIButton *button;
/* 更换日记背景色View */
@property (nonatomic, strong) WLLNoteBackgroundColorView *noteBackgroundColor;
@property (nonatomic, weak) WLLNoteBackgroundChoice *choiceView;
/* 心情视图 */
@property (nonatomic, strong) WLLMoodView *mood;
/* model */
@property (nonatomic, strong) NoteDetail *model;
/* 存储背景色 取消时赋给Model */
@property (nonatomic, weak) UIColor *backColor;
@property (nonatomic, weak) UIColor *fontColor;
@property (nonatomic, weak) UIFont *contentFont;
/* 遮盖view */
@property (strong, nonatomic) UIView *coverView;

//Wangchao
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) NSString *theString;
@property (assign, nonatomic) NSString *fontNumber;
/*传给网络存放图片的数组*/
@property (strong, nonatomic) NSMutableArray *photoArrayInternet;
/*传给第一页面存放图片数组*/
@property (strong, nonatomic) NSMutableArray *photoArrayLocal;
@property (assign, nonatomic) BOOL backFromEditNoteVC;
@property (strong, nonatomic) UIImage *choosedImage;
/**
 *  显示图片的scrollView
 */
@property (strong, nonatomic) UIScrollView *pictureScrollView;
/**
 *  编辑页面图片总数
 */
@property (assign, nonatomic) NSInteger numberOfPictures;
/**
 *  从编辑图片页面传过来的，被删除图片的偏移量
 */
@property (assign, nonatomic) NSInteger OffsetByInteger;
@property (strong, nonatomic) NSMutableArray *localCopyArrayOfModelPhotoArray;
@property (strong, nonatomic) NSMutableArray *internetCopyArrayOfModelPhotoArray;
/**
 *  存放photoUrl的数组
 */
@property (strong, nonatomic) NSMutableArray *photoUrlArray;
/**
 *  获取当前模型对应的AVObject对象
 */
@property (strong, nonatomic) AVObject *object;
/**
 * 分享日期
 */
@property (strong, nonatomic) NSDate *sharedDate;
/**
 *  标记日记是否分享
 */
@property (assign, nonatomic) BOOL isDiaryShared;
/**
 *  位置信息
 */
@property (strong, nonatomic) NSString *locationString;
/**
 *  上传日记的指示
 */
@property (strong, nonatomic) UIActivityIndicatorView *uploadingDiaryIndicatorView;
@property (strong, nonatomic) UIView *tipView;
@property (strong, nonatomic) UILabel *tipLabel;
/**
 *  遮盖所有的响应事件视图
 */
@property (strong, nonatomic) UIView *ignoreAllEventView;

@end

@implementation EditNoteViewController

#pragma mark - Load View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加pictureScroll
    [self addPictureScrollView];
    
    //创建一个本地图片数组
    [self.localCopyArrayOfModelPhotoArray addObjectsFromArray:self.passedObject.photoArray];
    
    //创建一个保存网络图片的数组
    self.object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
    
    [self.object fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        NSArray *photoArray = [object objectForKey:@"photoArray"];
        
        [self.internetCopyArrayOfModelPhotoArray addObjectsFromArray:photoArray];
    }];
    
    //创建一个保存photoUrl的数组
    [self.photoUrlArray addObjectsFromArray:self.passedObject.photoUrlArray];
    
    // 设置代理
    self.contentText.delegate = self;
    
    // 设置键盘上部工具栏
    self.toolView = [WLLToolView viewFromXib];
    self.toolView.toolViewDelegate = self;
    [self setToolView];
    
    // 设置字体视图
    self.fontView = [WLLFontView viewFromXib];
    self.fontView.fontDelegate = self;
    
    // 更换日记背景色View
    self.noteBackgroundColor = [WLLNoteBackgroundColorView viewFromXib];
    self.noteBackgroundColor.colorDelegate = self;
    
    // 心情视图
    self.mood = [WLLMoodView viewFromXib];
    [self.mood.shareSwitch addTarget:self action:@selector(shareDiary:) forControlEvents:UIControlEventValueChanged];
    if (self.passedObject.sharedDate != nil) {
        self.mood.shareSwitch.on = YES;
    } else {
        self.mood.shareSwitch.on = NO;
    }
    
    // 键盘初始为隐藏
    self.is = YES;
    // 键盘显示或隐藏通知
    [self showOrHideNotification];
    
    self.countLabel.text = [NSString stringWithFormat:@"%d", 0];
    
    //开启定位功能
    [CLLocationManager locationServicesEnabled];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestWhenInUseAuthorization];
    CLAuthorizationStatus status  = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    // 加载来自详情页面数据
    [self dataFromDetail];
    
    //添加上传日记的指示
    [self addUploadingDiaryIndicatorView];
    
    //注册监听保存日记成功的通知
    [self registerSaveNoteNotification];
    
    //初始化一个全遮盖View
    [self initIgnoreAllEventView];
}

/**
 *  初始化一个遮盖所有事件的view
 */
- (void)initIgnoreAllEventView {
    CGRect ignoreAllEventViewRect = CGRectMake(0, -64, kWidth, kHeight);
    self.ignoreAllEventView = [[UIView alloc] initWithFrame:ignoreAllEventViewRect];
    self.ignoreAllEventView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
}

/**
 *  登记保存日记成功的通知
 */
- (void)registerSaveNoteNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissTipView:)
                                                 name:@"dismissTipView"
                                               object:nil];
}

/**
 *  日记保存成功执行的方法
 *
 *  @param nitification 日记保存成功的通知
 */
- (void)dismissTipView:(NSNotification *)nitification {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  添加上传日记提示
 */
- (void)addUploadingDiaryIndicatorView {
    CGRect tipViewRect = CGRectMake(0, 0, 200, 200);
    self.tipView = [[UIView alloc] initWithFrame:tipViewRect];
    self.tipView.hidden = NO;
    [self.view addSubview:self.tipView];
    self.tipView.center = self.view.center;
    self.tipView.hidden = YES;
    
    CGRect tipLabelRect = CGRectMake(0, 50 - 30, 200, 60);
    self.tipLabel = [[UILabel alloc] initWithFrame:tipLabelRect];
    self.tipLabel.text = @"正在上传图片，请稍后";
    [self.tipView addSubview:self.tipLabel];
    
    CGRect indicatorViewRect = CGRectMake(100 - 30, 100 + 50 - 30, 60, 60);
    self.uploadingDiaryIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.uploadingDiaryIndicatorView.frame = indicatorViewRect;
    [self.tipView addSubview:self.uploadingDiaryIndicatorView];
    
    self.uploadingDiaryIndicatorView.color = [UIColor redColor];
    self.uploadingDiaryIndicatorView.hidesWhenStopped = YES;
    [self.uploadingDiaryIndicatorView startAnimating];
}

/**
 *  设置是否分享日记
 *
 *  @param shareSwitch switch按钮
 */
- (void)shareDiary:(UISwitch *)shareSwitch {
    self.isDiaryShared = YES;
    if (shareSwitch.on) {
        self.sharedDate = [NSDate date];
    } else {
        self.sharedDate = nil;
    }
}

- (void)addPictureScrollView {
    CGRect pictureScrollViewRect = CGRectMake(0, kHeight - 144, kWidth, 80);
    self.pictureScrollView = [[UIScrollView alloc] initWithFrame:pictureScrollViewRect];
    [self.view addSubview:self.pictureScrollView];
    self.pictureScrollView.alwaysBounceHorizontal = YES;
}

- (NSMutableArray *)localCopyArrayOfModelPhotoArray {
    if (_localCopyArrayOfModelPhotoArray == nil) {
        _localCopyArrayOfModelPhotoArray = [NSMutableArray array];
    }
    return _localCopyArrayOfModelPhotoArray;
}

- (NSMutableArray *)internetCopyArrayOfModelPhotoArray {
    if (_internetCopyArrayOfModelPhotoArray == nil) {
        _internetCopyArrayOfModelPhotoArray = [NSMutableArray array];
    }
    return _internetCopyArrayOfModelPhotoArray;
}
- (NSMutableArray *)photoUrlArray {
    if (_photoUrlArray == nil) {
        _photoUrlArray = [NSMutableArray array];
    }
    return _photoUrlArray;
}


//网络存放图片数组懒加载
- (NSMutableArray *)photoArrayInternet {
    if (_photoArrayInternet == nil) {
        _photoArrayInternet = [NSMutableArray array];
    }
    return _photoArrayInternet;
}

//本地存放图片数组
- (NSMutableArray *)photoArrayLocal {
    if (_photoArrayLocal == nil) {
        _photoArrayLocal = [NSMutableArray array];
    }
    return _photoArrayLocal;
}

// view将要出现时加载左右键及加载来自详情页面数据
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确认"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(saveNote:)];
    self.navigationItem.rightBarButtonItem = right;
   
}

// 数据加载自上一页面
- (void)dataFromDetail {
    if (_indexPath) {   // 如果传过来NSIdexPath不为空, 即从详情页面打开, 为编辑页面，加载数据
        
        //内容
        self.contentText.text = self.passedObject.content;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", self.contentText.text.length];
        
        //字体
        NSString *fontNumberString = self.passedObject.fontNumber;
        if (fontNumberString == nil) {
            UIFont *font = [UIFont systemFontOfSize:15];
            self.contentText.font = font;
        } else {
            float fontNumber = [fontNumberString floatValue];
            self.contentText.font = [UIFont systemFontOfSize:fontNumber];
        }
        
        //背景颜色
        UIColor *backColor = self.passedObject.backColor;
        
        if (backColor == nil) {
            self.contentText.backgroundColor = [UIColor whiteColor];
        } else {
            self.contentText.backgroundColor = backColor;
        }
        
        //字体颜色
        UIColor *fontColor = self.fontColor;
        
        if (fontColor == nil) {
            self.contentText.textColor = [UIColor darkTextColor];
        } else {
            self.contentText.textColor = fontColor;
        }
        
        //添加图片
        self.numberOfPictures = self.localCopyArrayOfModelPhotoArray.count;
        
        NSMutableArray *photoArray = self.localCopyArrayOfModelPhotoArray;
        
        self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPictures * 60, 80);
        
        if (photoArray != nil && photoArray.count != 0) {
            for (NSInteger i = 0; i < self.numberOfPictures; i++) {
                CGRect imageVRect = CGRectMake(60 * i, 0, 60, 80);
                
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:imageVRect];
                
                imageV.tag = i;
                [self.pictureScrollView addSubview:imageV];
                
                //添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
                
                [imageV addGestureRecognizer:tap];
                
                imageV.userInteractionEnabled = YES;
                
                if ([photoArray[i] isKindOfClass:[AVFile class]]) {
                    AVFile *file = photoArray[i];
                    
                    [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                        NSString *urlString = file.url;
                        
                        [imageV sd_setImageWithURL:[NSURL URLWithString:urlString]];
                    }];
                } else {
                    NSString *urlString = photoArray[i];
                    
                    imageV.image = [UIImage imageWithContentsOfFile:urlString];
                }
            }
        }
        
    } else {    // 否则为创建新日记, 弹出键盘
        
        // 加载toolView, 键盘隐藏
        [self setToolView];
        self.is = YES;
        [self.contentText becomeFirstResponder];
    }
}

/**
 *  轻击图片响应方法
 *
 *  @param tap 图片tap事件
 */
- (void)tapAction:(UITapGestureRecognizer *)tap {
    WLLPictureViewController *pictureVC = [[WLLPictureViewController alloc] initWithNibName:@"WLLPictureViewController"
                                                                                     bundle:[NSBundle mainBundle]];
    //把点击的图片的tag传给pictureVC
    pictureVC.tagOfImageView = tap.view.tag;
    
    //传递两个图片数组，一个本地，一个网络存放的
    pictureVC.localPictureArray = self.localCopyArrayOfModelPhotoArray;
    pictureVC.internetPictureArray = self.internetCopyArrayOfModelPhotoArray;
    pictureVC.photoUrlArray = self.photoUrlArray;
    
    NSArray *imageViewS = self.pictureScrollView.subviews;
    
    pictureVC.contentOffsetBlock = ^ (NSInteger offsetByInteger){
        self.OffsetByInteger = offsetByInteger;
        
        if (offsetByInteger < self.localCopyArrayOfModelPhotoArray.count - 1) {
            for (UIImageView *imageV in imageViewS) {
                if (imageV.tag == offsetByInteger) {
                    [imageV removeFromSuperview];
                    self.numberOfPictures--;
                    self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPictures * 60, 80);
                }
                
                if (imageV.tag > offsetByInteger) {
                    imageV.tag--;
                    CGRect frame = imageV.frame;
                    frame.origin.x = frame.origin.x - 60;
                    imageV.frame = frame;
                }
            }
        } else {
            for (UIImageView *imageV in imageViewS) {
                if (imageV.tag == self.localCopyArrayOfModelPhotoArray.count - 1) {
                    [imageV removeFromSuperview];
                }
            }
            self.numberOfPictures--;
            self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPictures * 60, 80);
        }
    };
    
    [WLLDailyNoteDataManager sharedInstance].isFromDetailViewController = NO;
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:pictureVC];
    
    [self.navigationController presentViewController:naviController animated:YES completion:nil];
}

// view出现后 加载分类页面初始位置
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    self.hidden = YES;
    
    // 初始化遮盖view
    self.coverView = [UIView cs_viewCoverMainSreen];
}

#pragma mark - UITextView Delegate
// textView开始编辑时 将判断键盘隐藏置为NO
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.is = NO;
    
    // 当开始编辑时移除遮盖view
    [self.coverView removeFromSuperview];
    
    // 调出键盘后隐藏字体视图 更改背景色视图
    [UIView animateWithDuration:0.5 animations:^{
        self.fontView.frame = CGRectMake(0, kHeight, kWidth, 0.4*kHeight);

        self.noteBackgroundColor.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.3);
        self.choiceView.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.05);
        
        self.mood.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);
    }];
    
    return 1;
}

// textview内容改变时计数 赋给counLabel
- (void)textViewDidChange:(UITextView *)textView {
    self.countLabel.text = [NSString stringWithFormat:@"%ld", self.contentText.text.length];
}

#pragma mark - 键盘上部工具条设置
// 设置工具条
- (void)setToolView {
    
    self.toolView.y = kHeight - self.toolView.height;
    [self.view addSubview:self.toolView];
    
    // 监听键盘收放
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

// 键盘收放通知方法
- (void)keyboardWillChangeFrameNotification:(NSNotification *)note {
    
    // 获取键盘frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    // 获取键盘收放动画时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 工具条跟随键盘收放
    [UIView animateWithDuration:duration animations:^{
        self.toolView.transform = CGAffineTransformMakeTranslation(0, frame.origin.y - kHeight);
    }];
}

// 接收通知: 来自WLLToolView键盘弹出收回
- (void)showOrHideNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(change)
                                                 name:@"change"
                                               object:nil];
}

// 通知方法
- (void)change {
    if (self.is == YES) {
        [self.contentText becomeFirstResponder];
        self.is = NO;
    } else {
        [self.contentText resignFirstResponder];
        self.is = YES;
    }
}

#pragma mark - 导航栏左右键响应
// 保存
- (void)saveNote:(UIBarButtonItem *)button {
    //没有网络的时候，不能编辑，弹出提示框
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable == NO) {
        [self tipOfNoneDairyContent];
    } else {
        
        //显示上传日记提示，遮盖视图出现
        [self.view addSubview:self.ignoreAllEventView];
        [self.view bringSubviewToFront:self.tipView];
        self.tipView.hidden = NO;
        
        //归档背景颜色
        NSMutableData *backColorData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiverBackColor = [[NSKeyedArchiver alloc] initForWritingWithMutableData:backColorData];
        [archiverBackColor encodeObject:self.contentText.backgroundColor forKey:@"backColor"];
        [archiverBackColor finishEncoding];
        
        //归档字体颜色
        NSMutableData *fontColor = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiverFontColor = [[NSKeyedArchiver alloc] initForWritingWithMutableData:fontColor];
        [archiverFontColor encodeObject:self.contentText.textColor forKey:@"fontColor"];
        [archiverFontColor finishEncoding];

        if (_indexPath) {
            
            // 如果是由点击DailyNote页面cell 进入，就是编辑
            // 移除遮盖view
            [self.coverView removeFromSuperview];
            
            // 注销第一响应
            [self.contentText resignFirstResponder];
            
            // 收回font view
            self.fontView.frame = CGRectMake(0, kHeight, kWidth, 0.4*kHeight);
            
            // 收回选择背景色视图
            self.noteBackgroundColor.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.3);
            self.choiceView.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.05);
            
            // 收回心情视图
            self.mood.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);
            
            //修改传过来的日记，并保存在网络
            //通过model获取日记
            
            NSString *objectId = self.passedObject.diaryId;
            
            if (objectId != nil) {
                AVObject *object = [AVObject objectWithClassName:@"Diary" objectId:self.passedObject.diaryId];
                
                //保存日记内容,确保作者的内容不为空
                NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                
                NSString *string = [self.contentText.text stringByTrimmingCharactersInSet:set];
                
                if (self.contentText.text == nil || string.length == 0) {
                    
                    //日记内容为空，弹出提示框
                    [self tipOfNoneDairyContent];
                    
                } else {
                    
                    //model保存数据
                    [self saveDataInModel:self.passedObject];
                    
                    if (self.isFromeCalendar == YES) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.passedObject forKey:@"editedNote"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarPageChangeNote" object:nil userInfo:dic];
                    }
                    
                    //数据库保存
                    [object fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        
                        //图片保存
                        [object removeObjectForKey:@"photoArray"];
                        
                        [self saveDataInAVObject:object backColorData:backColorData fontColorData:fontColor];
                        
                        object.fetchWhenSave = YES;
                        
                        //保存日记的作者为当前用户
                        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                //保存成功发送通知，去掉上传日记的提示框
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissTipView"
                                                                                    object:nil
                                                                                  userInfo:nil];
                                
                                //保存成功之后，获取图片数组里面图片的url
                                NSArray *photoArray = [object objectForKey:@"photoArray"];
                                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:10];
                                
                                for (AVFile *file in photoArray) {
                                    [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                                        NSString *urlString = file.url;
                                        [tempArray addObject:urlString];
                                        if (tempArray.count == photoArray.count) {
                                            self.passedObject.photoUrlArray = tempArray;
                                            [object removeObjectForKey:@"photoUrlArray"];
                                            [object addObjectsFromArray:tempArray forKey:@"photoUrlArray"];
                                            [object saveInBackground];
                                        }
                                    }];
                                }
                            }
                        }];
                    }];
                }
            }
        } else {
            
            // 如果是由DailyNote页面直接点击添加进入，就是添加
            // 移除遮盖view
            [self.coverView removeFromSuperview];
            
            // 收回选择背景色视图
            self.noteBackgroundColor.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.3);
            self.choiceView.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.05);
            
            // 收回心情视图
            self.mood.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);
            
            // 收回font view
            self.fontView.frame = CGRectMake(0, kHeight, kWidth, 0.4*kHeight);
            
            //创建日记对象，保存日记到网络
            AVObject *object = [AVObject objectWithClassName:@"Diary"];
            
            //创建model，传给第一页面
            NoteDetail *model = [[NoteDetail alloc] init];
            
            //保存日记内容,确保作者的内容不为空
            NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            
            NSString *string = [self.contentText.text stringByTrimmingCharactersInSet:set];
            
            if (self.contentText.text == nil || string.length == 0) {
                
                //日记内容为空，弹出提示框
                [self tipOfNoneDairyContent];
                
            } else {
                
                //model保存数据
                [self saveDataInModel:model];
                
                //给model日期赋值
                model.date = [NSDate date];
                
                //AVObject对象存储数据
                [self saveDataInAVObject:object backColorData:backColorData fontColorData:fontColor];
               
                self.block(model);
                
                //保存日记的作者为当前用户
                [object setObject:[AVUser currentUser] forKey:@"belong"];
                
                object.fetchWhenSave = YES;
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //保存成功发送通知，去掉上传日记的提示框
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissTipView"
                                                                            object:nil
                                                                          userInfo:nil];
                        //保存成功把objectId传给model
                        model.diaryId = object.objectId;
                        
                        NSArray *photoArray = [object objectForKey:@"photoArray"];
                        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:10];
                        
                        for (AVFile *file in photoArray) {
                            [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                                NSString *urlString = file.url;
                                [tempArray addObject:urlString];
                                if (tempArray.count == photoArray.count) {
                                    self.passedObject.photoUrlArray = tempArray;
                                    [object removeObjectForKey:@"photoUrlArray"];
                                    [object addObjectsFromArray:tempArray forKey:@"photoUrlArray"];
                                    [object saveInBackground];
                                }
                            }];
                        }
                    }
                }];
            }
        }
    }
}

/**
 *  model保存数据
 *
 *  @param model NoteDetail的实例
 */
- (void)saveDataInModel:(NoteDetail *)model {
    //日记内容
    model.content = self.contentText.text;
    
    //背景颜色
    model.backColor = self.contentText.backgroundColor;
    if (model.backColor == nil) {
        model.backColor = [UIColor whiteColor];
    }
    
    //保存字体大小
    //从详情页面传过来的object中解析的字体
    NSString *passedFontNumber = self.passedObject.fontNumber;
    if (self.fontNumber != nil) {
        model.fontNumber = self.fontNumber;
    } else if (passedFontNumber != nil){
        model.fontNumber = passedFontNumber;
    } else {
        model.fontNumber = @"17";
    }
    
    //字体颜色
    model.fontColor = self.contentText.textColor;
    if (model.fontColor == nil) {
        model.fontColor = [UIColor blackColor];
    }
    
    //保存模型图片数组
    model.photoArray = self.localCopyArrayOfModelPhotoArray;
    
    //保存分享日期
    if (self.isDiaryShared == YES) {
        model.sharedDate = self.sharedDate;
    }
    
    //保存天气image
    if (self.mood.isSelected == YES) {
        NSInteger numberOfImage = self.mood.numberOfImage;
        NSArray *weatherImageArray = self.mood.weatherView.subviews;
        for (UIImageView *imageV in weatherImageArray) {
            if (imageV.tag == numberOfImage) {
                model.weatherImage = imageV.image;
            }
        }
    }
    
    //保存photoUrArray
    if (self.indexPath) {
        model.photoUrlArray = self.photoUrlArray;
    }
    
    //位置信息,如果是编辑，就不用重新添加地理位置信息，如果是新建日记,则添加地理位置
    if (self.indexPath) {
    } else {
        model.locationString = self.locationString;
    }
}

/**
 *  object对象保存数据
 *
 *  @param object        AVObject实例
 *  @param backColorData 背景颜色数据
 *  @param fontColorData 字体颜色数据
 */
- (void)saveDataInAVObject:(AVObject *)object backColorData:(NSData *)backColorData fontColorData:(NSData *)fontColorData{
    //日记内容
    [object setObject:self.contentText.text forKey:@"content"];
    
    //照片
    [object addObjectsFromArray:self.internetCopyArrayOfModelPhotoArray forKey:@"photoArray"];
    
    //背景颜色
    [object setObject:backColorData forKey:@"backColor"];
    
    //字体大小
    if (self.fontNumber != nil) {
        [object setObject:self.fontNumber forKey:@"fontNumber"];
    } else {
        [object setObject:self.passedObject.fontNumber forKey:@"fontNumber"];
    }
    
    //字体颜色
    [object setObject:fontColorData forKey:@"fontColor"];
    
    //保存分享日期
    if (self.isDiaryShared == YES) {
        [object setObject:self.sharedDate forKey:@"sharedDate"];
    }
    
    //保存天气image
    if (self.mood.isSelected == YES) {
        NSInteger numberOfImage = self.mood.numberOfImage;
        NSArray *weatherImageArray = self.mood.weatherView.subviews;
        for (UIImageView *imageV in weatherImageArray) {
            if (imageV.tag == numberOfImage) {
                NSData *imageData = nil;
                if (UIImagePNGRepresentation(imageV.image)) {
                    imageData = UIImagePNGRepresentation(imageV.image);
                } else if (UIImageJPEGRepresentation(imageV.image, 1)) {
                    imageData = UIImageJPEGRepresentation(imageV.image, 1);
                }
                [object setObject:imageData forKey:@"weatherImage"];
                break;
            }
        }
    } else {
        [object setObject:nil forKey:@"weatherImage"];;
    }
    
    //保存photoUrlArray
    if (self.indexPath) {
        [object removeObjectForKey:@"photoUrlArray"];
        [object addObjectsFromArray:self.photoUrlArray forKey:@"photoUrlArray"];
    }
    
    //位置信息
    if (self.indexPath) {
    } else {
        [object setObject:self.locationString forKey:@"location"];
    }
}

// 如果日记内容为空, 弹出提示框
- (void)tipOfNoneDairyContent {
    UIAlertController *alertController;
    
    if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable == NO) {
        alertController = [UIAlertController alertControllerWithTitle:@"网络故障，保存失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:@"日记内容不能为空" message:nil preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *executeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:executeAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

// 取消
- (void)cancel {
    
    // 移除遮盖view
    [self.coverView removeFromSuperview];

    // 收回font view
    self.fontView.frame = CGRectMake(0, kHeight, kWidth, 0.4*kHeight);
    // 收回选择背景色视图
    self.noteBackgroundColor.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.3);
    self.choiceView.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.05);
    // 收回心情视图
    self.mood.frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ToolViewSubViewsDelegate
// 隐藏or显示字体视图
- (void)showOrHideFontView {
    // 注销第一响应
    [self.contentText resignFirstResponder];

    // 初始fontView
    self.fontView.frame = CGRectMake(0, kHeight, kWidth, 0.4*kHeight);
    
    [self.view addSubview:self.fontView];
    
    [self.view addSubview:self.coverView];
    [self.view bringSubviewToFront:self.fontView];
    // 弹出fontView
    [UIView animateWithDuration:0.5 animations:^{
        self.fontView.frame = CGRectMake(0, kHeight-self.fontView.height, kWidth, 0.4*kHeight);
    }];
}

// 更改当前页面字体大小
- (void)changeFontWithSlider:(UISlider *)slider {
    
    //获取slider的大小
    self.fontNumber = [NSString stringWithFormat:@"%f", slider.value];

    // 将滑条变化值赋给model
    self.contentText.font = [UIFont systemFontOfSize:slider.value];
}
// 改变字体颜色
- (void)changeFontColor:(UIColor *)fontColor {

    self.contentText.textColor = fontColor;
}

// 显示/隐藏更换日记背景色视图
- (void)showOrHideNoteBackgroundColorView {
    // 注销第一响应
    [self.contentText resignFirstResponder];

    // 初始化选择背景色View
    CGRect frame = CGRectMake(0, kHeight+self.choiceView.height, kWidth, kHeight*0.3);
    self.noteBackgroundColor.frame = frame;
    [self.view addSubview:self.noteBackgroundColor];
    
    // 初始化背景选择视图上方视图
    self.choiceView = [WLLNoteBackgroundChoice viewFromXib];
    CGRect choiceFrame = CGRectMake(0, kHeight, kWidth, kHeight*0.05);
    self.choiceView.frame = choiceFrame;
    [self.view addSubview:self.choiceView];
    self.choiceView.cancelDelegate = self;
    
    // 添加
    [self.view addSubview:self.coverView];
    [self.view bringSubviewToFront:self.noteBackgroundColor];
    [self.view bringSubviewToFront:self.choiceView];
    
    [UIView animateWithDuration:0.5 animations:^{
        // 显示选择背景色View
        CGRect frame = CGRectMake(0, kHeight-self.noteBackgroundColor.height, kWidth, kHeight*0.3);
        self.noteBackgroundColor.frame = frame;
        // 背景颜色选择视图上方视图
        CGRect choiceFrame = CGRectMake(0, kHeight-self.choiceView.height-self.noteBackgroundColor.height, kWidth, kHeight*0.05);
        self.choiceView.frame = choiceFrame;
    }];
}

// 取消选择背景色
- (void)cancelChoice {
    self.contentText.backgroundColor = [UIColor whiteColor];
}

// 选择心情视图
- (void)choiceMoodForNote {
    // 注销第一响应
    [self.contentText resignFirstResponder];
    
    [self.view addSubview:self.mood];
    // 添加遮盖view
    [self.view addSubview:self.coverView];
    [self.view bringSubviewToFront:self.mood];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.mood.frame = CGRectMake(0, kHeight-self.mood.height, kWidth, kHeight*0.4);
    }];
}

// 更改日记背景色协议方法
- (void)changeNoteBackgroundColor:(UIColor *)color {

    self.contentText.backgroundColor = color;
}

#pragma mark - 日志中图片来源方法
// 图片来源
- (void)notePicturesSource {

    // 添加图片来源提示
    UIAlertController *pictureSource = [UIAlertController alertControllerWithTitle:@"图片来自:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 图片来自相册
    UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pictureFromLibrary];
    }];
    // 图片来自拍照
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pictureFromCamera];
        
    }];
    // 取消
    UIAlertAction *abortion = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [pictureSource addAction:camera];
    [pictureSource addAction:photoLibrary];
    [pictureSource addAction:abortion];
    
    [self presentViewController:pictureSource animated:YES completion:nil];
}

// 图片来自拍照
- (void)pictureFromCamera {
    UIImagePickerController *pictureController = [[UIImagePickerController alloc] init];
    
    pictureController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pictureController.delegate = self;
    pictureController.allowsEditing = YES;
    
    [self presentViewController:pictureController animated:YES completion:nil];
}

//已选图片代理方法
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    
    CGFloat scaleBetweenWidthAndHeight = pickedImage.size.width / pickedImage.size.height;
    
    CGSize newSize = CGSizeMake(kWidth * 1.5, kWidth / scaleBetweenWidthAndHeight * 1.5);
    
    UIImage *compressedImage = [[self class] imageWithImageSimple:pickedImage scaledToSize:newSize];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    
    NSData *imageData = nil;
    
    NSString *imagePath = nil;
    
    if (UIImageJPEGRepresentation(compressedImage, 1)) {
        imageData = UIImageJPEGRepresentation(compressedImage, 1);
    } else if (UIImagePNGRepresentation(compressedImage)) {
        imageData = UIImagePNGRepresentation(compressedImage);
    }
    
    imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ldimage%ld", self.numberOfModelInArray, self.numberOfPictures]];
    
    self.numberOfPictures++;
    
    self.pictureScrollView.contentSize = CGSizeMake(self.numberOfPictures * 60, 80);
    
    CGRect imageVRect = CGRectMake((self.numberOfPictures - 1) * 60, 0, 60, 80);
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:imageVRect];
    
    [self.pictureScrollView addSubview:imageV];
    
    imageV.tag = self.numberOfPictures - 1;
    
    imageV.image = compressedImage;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    
    [imageV addGestureRecognizer:tap];
    
    imageV.userInteractionEnabled = YES;
    
    [imageData writeToFile:imagePath atomically:YES];
    
    AVFile *imageFile = [AVFile fileWithData:imageData];
    
    [self.photoArrayInternet addObject:imageFile];
    
    [self.photoArrayLocal addObject:imagePath];

    [self.localCopyArrayOfModelPhotoArray addObjectsFromArray:self.photoArrayLocal];
    [self.photoArrayLocal removeAllObjects];
    [self.internetCopyArrayOfModelPhotoArray addObjectsFromArray:self.photoArrayInternet];
    [self.photoArrayInternet removeAllObjects];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 图片来自相册
- (void)pictureFromLibrary {
    __weak typeof(self) weakSelf = self;
    WLLAssetPickerController *assetPicker = [WLLAssetPickerController pickerWithCompletion:^(NSDictionary *info) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            
            NSArray *assets = [info objectForKey:WLLAssetPickerSelectedAssets];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *path = [paths objectAtIndex:0];
            
            NSInteger numberOFModelInArray = weakSelf.numberOfModelInArray;
            
            [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *imagePath;
                
                weakSelf.choosedImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage] ;
                
                //对从相册拿到的图片进行等比例缩小处理
                CGFloat scaleBetweenWidthAndHeight = weakSelf.choosedImage.size.width / weakSelf.choosedImage.size.height;
                
                CGSize size = CGSizeMake(1.5 * kWidth,  1.5 * kWidth / scaleBetweenWidthAndHeight);
                
                UIImage *compressedImage = [[self class] imageWithImageSimple:weakSelf.choosedImage scaledToSize:size];
                
                //将图片转化为NSData格式
                NSData *imageData = nil;
                if (UIImageJPEGRepresentation(compressedImage, 1)) {
                    imageData = UIImageJPEGRepresentation(compressedImage, 1);
                } else if (UIImagePNGRepresentation(compressedImage)) {
                    imageData = UIImagePNGRepresentation(compressedImage);
                }
                 imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ldimage%ld.png", numberOFModelInArray, self.numberOfPictures]];
                
                //重新设定contentsize，以便把从相册添加的照片放在scrollView上
                weakSelf.numberOfPictures = weakSelf.numberOfPictures + 1;
                
                weakSelf.pictureScrollView.contentSize = CGSizeMake(weakSelf.numberOfPictures * 60, 80);
                
                CGRect imageVRect = CGRectMake((weakSelf.numberOfPictures - 1) * 60, 0, 60, 80);
                
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:imageVRect];
                
                [weakSelf.pictureScrollView addSubview:imageV];
                
                imageV.tag = weakSelf.numberOfPictures - 1;
                
                imageV.image = compressedImage;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
                
                [imageV addGestureRecognizer:tap];
                
                imageV.userInteractionEnabled = YES;
                
                [imageData writeToFile:imagePath atomically:YES];
                
                AVFile *imageFile = [AVFile fileWithData:imageData];
                
                [weakSelf.photoArrayInternet addObject:imageFile];
                
                [weakSelf.photoArrayLocal addObject:imagePath];
            }];
            
            [self.localCopyArrayOfModelPhotoArray addObjectsFromArray:self.photoArrayLocal];
            [self.photoArrayLocal removeAllObjects];
            [self.internetCopyArrayOfModelPhotoArray addObjectsFromArray:self.photoArrayInternet];
            [self.photoArrayInternet removeAllObjects];
        }];
        
    } canceled:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    assetPicker.selectionLimit = 10;
    
    [weakSelf presentViewController:assetPicker animated:YES completion:nil];
}

/**
 *  压缩图片
 *
 *  @param image   被压缩的image
 *  @param newSize 压缩后的尺寸
 *
 *  @return 压缩后得到的image
 */
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark - 定位代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    
    CLLocation *meLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    [self.geoCoder reverseGeocodeLocation:meLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil && placemarks.count > 0) {
            NSDictionary *dic = [[placemarks objectAtIndex:0] addressDictionary];
            
            NSString *city = dic[@"City"];
            
            NSString *state = dic[@"State"];
            
            NSString *sublocality = dic[@"SubLocality"];
            
            self.locationString = [state stringByAppendingString:city];
            
            self.locationString = [self.locationString stringByAppendingString:sublocality];
            
            [self.locationManager stopUpdatingLocation];
            
        } else {
            [self.locationManager stopUpdatingLocation];
        }
    }];
}

//移除观察着
#pragma mark - 辅助工具栏按钮响应
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"change" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
