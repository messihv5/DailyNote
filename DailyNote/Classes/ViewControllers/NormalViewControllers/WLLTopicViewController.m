//
//  WLLTopicViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/10.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLTopicViewController.h"
#import "WLLDailyNoteDataManager.h"

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface WLLTopicViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *navigationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topicImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tabbarImageView;
@property (weak, nonatomic) IBOutlet UIView *changeTopicView;
@property (strong, nonatomic) UIButton *blueButton;
@property (strong, nonatomic) UIButton *darkButton;
@property (strong, nonatomic) UIButton *redButton;
@property (strong, nonatomic) UIButton *grayButton;
@property (strong, nonatomic) UIColor *theBarTintColor;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) UIImage *navigationImage1;
@property (strong, nonatomic) UIImage *tabbarImage1;
@property (strong, nonatomic) UIImage *navigationImage2;
@property (strong, nonatomic) UIImage *tabbarImage2;
@property (strong, nonatomic) UIImage *navigationImage3;
@property (strong, nonatomic) UIImage *tabbarImage3;
@property (strong, nonatomic) UIImage *navigationImage4;
@property (strong, nonatomic) UIImage *tabbarImage4;
@property (strong, nonatomic) AVUser *theCurrentUser;



@end

@implementation WLLTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        //添加按钮
    self.theCurrentUser = [AVUser currentUser];
    
    [self addFourButton];
    
    //从userDefault获取image
//    self.topicImageView.image = [WLLDailyNoteDataManager sharedInstance].topicImage;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *navigationImageData = [self.theCurrentUser objectForKey:@"navigationImage"];
    NSData *tabbarImageData = [self.theCurrentUser objectForKey:@"tabbarImage"];
    
    NSData *imageData = [self.userDefaults objectForKey:@"navigationImagesAndTabbarImages"];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:imageData];
    self.tabbarImage1 = [unarchiver decodeObjectForKey:@"tabbarImage1"];
    self.navigationImage1 = [unarchiver decodeObjectForKey:@"navigationImage1"];
    self.tabbarImage2 = [unarchiver decodeObjectForKey:@"tabbarImage2"];
    self.navigationImage2 = [unarchiver decodeObjectForKey:@"navigationImage2"];
    self.tabbarImage3 = [unarchiver decodeObjectForKey:@"tabbarImage3"];
    self.navigationImage3 = [unarchiver decodeObjectForKey:@"navigationImage3"];
    self.tabbarImage4 = [unarchiver decodeObjectForKey:@"tabbarImage4"];
    self.navigationImage4 = [unarchiver decodeObjectForKey:@"navigationImage4"];
    
    
    
    if (navigationImageData == nil && tabbarImageData == nil) {
        self.navigationImageView.image = self.navigationImage1;
        self.tabbarImageView.image = self.tabbarImage1;
    } else {
        self.navigationImageView.image = [UIImage imageWithData:navigationImageData];
        self.tabbarImageView.image = [UIImage imageWithData:tabbarImageData];
    }
}



//配置4个改变导航栏颜色的按钮
- (void)addFourButton {
    self.blueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.blueButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.blueButton setImage:[UIImage imageNamed:@"blueButton"]
                     forState:UIControlStateNormal];
    //设置button的highlighted效果为NO
    self.blueButton.adjustsImageWhenHighlighted = NO;
    [self.blueButton addTarget:self action:@selector(changeTopicToBlueAction:)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.darkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.darkButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.darkButton setImage:[UIImage imageNamed:@"darkButton"] forState:UIControlStateNormal];
    self.darkButton.adjustsImageWhenHighlighted = NO;
    [self.darkButton addTarget:self action:@selector(changeTopicToDarkAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + 2 * ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.redButton setImage:[UIImage imageNamed:@"redButton"] forState:UIControlStateNormal];
    self.redButton.adjustsImageWhenHighlighted = NO;
    [self.redButton addTarget:self action:@selector(changeTopicToRedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.grayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.grayButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + 3 * ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.grayButton setImage:[UIImage imageNamed:@"grayButton"] forState:UIControlStateNormal];
    self.grayButton.adjustsImageWhenHighlighted = NO;
    [self.grayButton addTarget:self action:@selector(changeTopicToGrayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *colorString = [self.theCurrentUser objectForKey:@"navigationColor"];
    if ([colorString isEqualToString:@"blue"]) {
        [self.blueButton setImage:[UIImage imageNamed:@"blue_selectedButton"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"black"]) {
        [self.darkButton setImage:[UIImage imageNamed:@"dark_selectedButton"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"red"]) {
        [self.redButton setImage:[UIImage imageNamed:@"red_selectedButton"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"gray"]) {
        [self.grayButton setImage:[UIImage imageNamed:@"gray_selectedButton"] forState:UIControlStateNormal];
    }
    
    [self.changeTopicView addSubview:self.blueButton];
    [self.changeTopicView addSubview:self.darkButton];
    [self.changeTopicView addSubview:self.redButton];
    [self.changeTopicView addSubview:self.grayButton];
    
}

//改变主题颜色为蓝色的操作
- (void)changeTopicToBlueAction:(UIButton *)sender {
    //把button的图片改为已选择
    [sender setImage:[UIImage imageNamed:@"blue_selectedButton"] forState:UIControlStateNormal];
    [self.darkButton setImage:[UIImage imageNamed:@"darkButton"] forState:UIControlStateNormal];
    [self.redButton setImage:[UIImage imageNamed:@"redButton"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayButton"] forState:UIControlStateNormal];

    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage1;
    self.tabbarImageView.image = self.tabbarImage1;
    
    //把image格式转换为NSData格式
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"blue" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];
}

//改变主体颜色为黑色
- (void)changeTopicToDarkAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"dark_selectedButton"] forState:UIControlStateNormal];
    [self.blueButton setImage:[UIImage imageNamed:@"blueButton"] forState:UIControlStateNormal];
    [self.redButton setImage:[UIImage imageNamed:@"redButton"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayButton"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor darkTextColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage2;
    self.tabbarImageView.image = self.tabbarImage2;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    NSMutableData *colorData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:colorData];
    [archiver encodeObject:[UIColor darkTextColor] forKey:@"navigationColor"];
    [archiver finishEncoding];
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"black" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];

}

//改变主题颜色为红色
- (void)changeTopicToRedAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"red_selectedButton"] forState:UIControlStateNormal];
    [self.blueButton setImage:[UIImage imageNamed:@"blueButton"] forState:UIControlStateNormal];
    [self.darkButton setImage:[UIImage imageNamed:@"darkButton"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayButton"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage3;
    self.tabbarImageView.image = self.tabbarImage3;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    NSMutableData *colorData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:colorData];
    [archiver encodeObject:[UIColor redColor] forKey:@"navigationColor"];
    [archiver finishEncoding];
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"red" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];

}

//更改主题颜色为灰色
- (void)changeTopicToGrayAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"gray_selectedButton"] forState:UIControlStateNormal];
    [self.blueButton setImage:[UIImage imageNamed:@"blueButton"] forState:UIControlStateNormal];
    [self.darkButton setImage:[UIImage imageNamed:@"darkButton"] forState:UIControlStateNormal];
    [self.redButton setImage:[UIImage imageNamed:@"redButton"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    
    //获取保存在单例中的image
    self.navigationImageView.image = self.navigationImage4;
    self.tabbarImageView.image = self.tabbarImage4;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    NSMutableData *colorData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:colorData];
    [archiver encodeObject:[UIColor lightGrayColor] forKey:@"navigationColor"];
    [archiver finishEncoding];
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"gray" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];


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
