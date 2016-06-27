//
//  EditNoteViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "EditNoteViewController.h"
#import "WLLCategoryButton.h"
#import "WLLNotesCategoryView.h"
#import "WLLDailyNoteDataManager.h"
#import "NoteDetail.h"
#import <CoreLocation/CoreLocation.h>

#define kWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface EditNoteViewController ()<UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, assign, getter=isHidden) BOOL hidden;
@property (nonatomic, strong) UITableView *notesCategoryView;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) NSString *theString;

@end

@implementation EditNoteViewController{
    
    NSInteger count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNaviButton];
    
    [self dataFromDetail];
    
    self.contentText.delegate = self;
    
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
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    
    
    self.countLabel.text = [NSString stringWithFormat:@"%ld", count];
    
}


- (void)dataFromDetail {
    
    if (_index) {
        NoteDetail *model = [[WLLDailyNoteDataManager sharedInstance] returnModelWithIndex:self.index.row];
        
        self.contentText.text = model.content;
    
        self.countLabel.text = [NSString stringWithFormat:@"%ld", self.contentText.text.length];
    } else {
        
        //点击编辑按钮后，保存日记
        
        //获取用户的位置信息,并进行定位
        
    }
}

// view完成加载后 加载分类页面初始位置
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    // 分类页面初始为隐藏
    self.hidden = YES;
    // 分类页面初始位置在屏幕以外, 将其高度设置为0
    self.notesCategoryView = [[WLLNotesCategoryView alloc] initWithFrame:CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0) style:UITableViewStylePlain];
    
    self.notesCategoryView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.notesCategoryView];
}


// 初始化分类页面按钮
- (void)initNaviButton {
    WLLCategoryButton *titleButton = [WLLCategoryButton buttonWithType:UIButtonTypeSystem];
    titleButton.frame = CGRectMake(0, 0, kWidth*0.2, kWidth*0.0725);
    [titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [titleButton setTitle:@"全部" forState:UIControlStateNormal];
    
    [titleButton addTarget:self action:@selector(notesCategory:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleButton;
}

- (void)notesCategory:(UIButton *)button {
    
    // 如果分类页面隐藏, 则显示
    if (self.isHidden == YES) {
        // 为其高度赋值即可
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, kWidth*1.2077);
            [button setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }];
        // 将分类页面置为显示
        self.hidden = NO;
    }
    // 如果分类页面显示, 则隐藏
    else if (self.isHidden == NO) {
        // 将其高度更改为0
        [UIView animateWithDuration:0.25 animations:^{
            self.notesCategoryView.frame = CGRectMake((kWidth-kWidth*0.4831)/2, kWidth*0.1546, kWidth*0.4831, 0);
            [button setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }];
        // 分类页面隐藏
        self.hidden = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)saveNote:(UIBarButtonItem *)button {
    
    NSLog(@"%s", __func__);
    
}

- (void)cancel {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    
    CLLocation *meLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    [self.geoCoder reverseGeocodeLocation:meLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil && placemarks.count > 0) {
            NSDictionary *dic = [[placemarks objectAtIndex:0] addressDictionary];
            
            NSString *city = dic[@"City"];
            
            NSString *state = dic[@"State"];
            
            NSString *sublocality = dic[@"SubLocality"];
            
            NSString *string1 = [state stringByAppendingString:city];
            
            string1 = [string1 stringByAppendingString:sublocality];

            AVUser *currentUser = [AVUser currentUser];//不加这句，日记就没有关联到指定的用户，相当于分享的日记
            AVObject *dairy = [AVObject objectWithClassName:@"Dairy"];
            NSString *contentOfDaily = @"今天是2016.5.29，星日，我还得继续努力啊man";
            
            [dairy setObject:contentOfDaily forKey:@"content"];
            [dairy setObject:@"第一类" forKey:@"Category"];
            [dairy setObject:@"public" forKey:@"isPrivate"];
            [dairy setObject:currentUser forKey:@"belong"];//日记没有指定用户，分享的日记
            [dairy setObject:[NSMutableArray array] forKey:@"staredUser"];//存储点赞的用户
            [dairy setObject:@"0" forKey:@"starNumber"];//存储点赞数
            [dairy setObject:string1 forKey:@"myLocation"];
            [dairy setObject:@"0" forKey:@"readTime"];
            
            UIImage *theImage = [UIImage imageNamed:@"star.png"];
            NSData *data = UIImagePNGRepresentation(theImage);
            AVFile *file = [AVFile fileWithName:@"head.png" data:data];
            
            UIImage *secondImage = [UIImage imageNamed:@"share.png"];
            NSData *secondData = UIImagePNGRepresentation(secondImage);
            AVFile *secondFile = [AVFile fileWithData:secondData];
            
            NSArray *array = [NSArray arrayWithObjects:file, secondFile, nil];
            [dairy addUniqueObjectsFromArray:array forKey:@"picture"];
            
            //保持网络和本地的日记同步
            dairy.fetchWhenSave = YES;
            [dairy saveInBackground];

            [self.locationManager stopUpdatingLocation];

        } else {
            [self.locationManager stopUpdatingLocation];
        }
    }];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}


@end
