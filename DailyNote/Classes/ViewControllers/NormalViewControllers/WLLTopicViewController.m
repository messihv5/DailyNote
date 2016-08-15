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
@property (strong, nonatomic) UIButton *grayButton;
@property (strong, nonatomic) UIButton *orangeButton;
@property (strong, nonatomic) UIButton *brownButton;
@property (strong, nonatomic) UIButton *magentaButton;
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
    
    self.theCurrentUser = [AVUser currentUser];
    
    [self addFourButton];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *navigationImageData = [self.theCurrentUser objectForKey:@"navigationImage"];
    NSData *tabbarImageData = [self.theCurrentUser objectForKey:@"tabbarImage"];
    
    //根据dailyNote页面保存的四种风格的导航栏，解档
    NSData *imageData = [self.userDefaults objectForKey:@"navigationImagesAndTabbarImages"];
    if (imageData == nil) {
        return;
    } else {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:imageData];
        self.tabbarImage1 = [unarchiver decodeObjectForKey:@"tabbarImage1"];
        self.navigationImage1 = [unarchiver decodeObjectForKey:@"navigationImage1"];
        self.tabbarImage2 = [unarchiver decodeObjectForKey:@"tabbarImage2"];
        self.navigationImage2 = [unarchiver decodeObjectForKey:@"navigationImage2"];
        self.tabbarImage3 = [unarchiver decodeObjectForKey:@"tabbarImage3"];
        self.navigationImage3 = [unarchiver decodeObjectForKey:@"navigationImage3"];
        self.tabbarImage4 = [unarchiver decodeObjectForKey:@"tabbarImage4"];
        self.navigationImage4 = [unarchiver decodeObjectForKey:@"navigationImage4"];
    }
    
    //如果用户没保存主题，就默认第一主题，保存了则用自己保存的主题
    if (navigationImageData == nil || tabbarImageData == nil) {
        self.navigationImageView.image = self.navigationImage1;
        self.tabbarImageView.image = self.tabbarImage1;
    } else {
        self.navigationImageView.image = [UIImage imageWithData:navigationImageData];
        self.tabbarImageView.image = [UIImage imageWithData:tabbarImageData];
    }
}

//配置4个改变导航栏颜色的按钮
- (void)addFourButton {
    self.grayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.grayButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.grayButton setImage:[UIImage imageNamed:@"grayTopic"]
                     forState:UIControlStateNormal];
    //设置button的highlighted效果为NO
    self.grayButton.adjustsImageWhenHighlighted = NO;
    [self.grayButton addTarget:self action:@selector(changeTopicToGrayAction:)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.orangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.orangeButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.orangeButton setImage:[UIImage imageNamed:@"orangeTopic"] forState:UIControlStateNormal];
    self.orangeButton.adjustsImageWhenHighlighted = NO;
    [self.orangeButton addTarget:self action:@selector(changeTopicToOrangeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.brownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.brownButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + 2 * ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.brownButton setImage:[UIImage imageNamed:@"brownTopic"] forState:UIControlStateNormal];
    self.brownButton.adjustsImageWhenHighlighted = NO;
    [self.brownButton addTarget:self action:@selector(changeTopicToBrownAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.magentaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.magentaButton.frame = CGRectMake(ScreenWidth / 5 - ScreenHeight / 20 + 3 * ScreenWidth / 5, ScreenHeight / 40, ScreenHeight / 20, ScreenHeight / 20);
    [self.magentaButton setImage:[UIImage imageNamed:@"magentaTopic"] forState:UIControlStateNormal];
    self.magentaButton.adjustsImageWhenHighlighted = NO;
    [self.magentaButton addTarget:self action:@selector(changeTopicToMagentaAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *colorString = [self.theCurrentUser objectForKey:@"navigationColor"];
    
    if ([colorString isEqualToString:@"gray"]) {
        [self.grayButton setImage:[UIImage imageNamed:@"selectedGrayTopic"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"orange"]) {
        [self.orangeButton setImage:[UIImage imageNamed:@"selectedOrangeTopic"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"brown"]) {
        [self.brownButton setImage:[UIImage imageNamed:@"selectedBrownTopic"] forState:UIControlStateNormal];
    } else if ([colorString isEqualToString:@"magenta"]) {
        [self.magentaButton setImage:[UIImage imageNamed:@"selectedMagentaTopic"] forState:UIControlStateNormal];
    }
    
    [self.changeTopicView addSubview:self.grayButton];
    [self.changeTopicView addSubview:self.orangeButton];
    [self.changeTopicView addSubview:self.brownButton];
    [self.changeTopicView addSubview:self.magentaButton];
    
}

//改变主题颜色为gray
- (void)changeTopicToGrayAction:(UIButton *)sender {
    //把button的图片改为已选择
    [sender setImage:[UIImage imageNamed:@"selectedGrayTopic"] forState:UIControlStateNormal];
    [self.orangeButton setImage:[UIImage imageNamed:@"orangeTopic"] forState:UIControlStateNormal];
    [self.brownButton setImage:[UIImage imageNamed:@"brownTopic"] forState:UIControlStateNormal];
    [self.magentaButton setImage:[UIImage imageNamed:@"magentaTopic"] forState:UIControlStateNormal];

    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage1;
    self.tabbarImageView.image = self.tabbarImage1;
    
    //把image格式转换为NSData格式
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"gray" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];
}

//改变主体颜色为orange
- (void)changeTopicToOrangeAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"selectedOrangeTopic"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayTopic"] forState:UIControlStateNormal];
    [self.brownButton setImage:[UIImage imageNamed:@"brownTopic"] forState:UIControlStateNormal];
    [self.magentaButton setImage:[UIImage imageNamed:@"magentaTopic"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage2;
    self.tabbarImageView.image = self.tabbarImage2;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"orange" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];

}

//改变主题颜色为brown
- (void)changeTopicToBrownAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"selectedBrownTopic"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayTopic"] forState:UIControlStateNormal];
    [self.orangeButton setImage:[UIImage imageNamed:@"orangeTopic"] forState:UIControlStateNormal];
    [self.magentaButton setImage:[UIImage imageNamed:@"magentaTopic"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor brownColor];
    
    //更改截图
    self.navigationImageView.image = self.navigationImage3;
    self.tabbarImageView.image = self.tabbarImage3;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"brown" forKey:@"navigationColor"];
    [self.theCurrentUser setObject:naviData forKey:@"navigationImage"];
    [self.theCurrentUser setObject:tabbarData forKey:@"tabbarImage"];
    self.theCurrentUser.fetchWhenSave = YES;
    [self.theCurrentUser saveInBackground];

}

//更改主题颜色为magenta
- (void)changeTopicToMagentaAction:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"selectedMagentaTopic"] forState:UIControlStateNormal];
    [self.grayButton setImage:[UIImage imageNamed:@"grayTopic"] forState:UIControlStateNormal];
    [self.orangeButton setImage:[UIImage imageNamed:@"orangeTopic"] forState:UIControlStateNormal];
    [self.brownButton setImage:[UIImage imageNamed:@"magentaTopic"] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barTintColor = [UIColor magentaColor];
    
    //获取保存在单例中的image
    self.navigationImageView.image = self.navigationImage4;
    self.tabbarImageView.image = self.tabbarImage4;
    
    NSData *naviData = UIImagePNGRepresentation(self.navigationImageView.image);
    NSData *tabbarData = UIImagePNGRepresentation(self.tabbarImageView.image);
    
    //把设置的颜色、image保存在currentUser里面
    [self.theCurrentUser setObject:@"magenta" forKey:@"navigationColor"];
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
