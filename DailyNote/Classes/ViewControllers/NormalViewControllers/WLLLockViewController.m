//
//  WLLLockViewController.m
//  DailyNote
//
//  Created by Messi on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLLockViewController.h"

@interface WLLLockViewController ()

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *selectedButtonArray;
@property (assign, nonatomic) CGPoint lineStarPoint;
@property (assign, nonatomic) CGPoint lineEndPoint;
@property (assign, nonatomic) BOOL drawFlag;
@property (copy, nonatomic) NSString *firstTime;
@property (copy, nonatomic) NSString *secondTime;
@property (assign, nonatomic) NSInteger i;
@property (strong, nonatomic) UILabel *instructionLabel;

@end

@implementation WLLLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.i = 0;
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundImageView];
    
    CGRect instructionLabelRect = CGRectMake(20, ScreenHeight / 8, ScreenWidth - 40, ScreenHeight / 8);
    self.instructionLabel = [[UILabel alloc] initWithFrame:instructionLabelRect];
    self.instructionLabel.text = @"请输入手势";
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.instructionLabel];
    
    [self creatLockButton];
}

//懒加载
- (NSMutableArray *)buttonArray {
    if (_buttonArray == nil) {
        _buttonArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _buttonArray;
}

- (NSMutableArray *)selectedButtonArray {
    if (_selectedButtonArray == nil) {
        _selectedButtonArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _selectedButtonArray;
}

//创建解锁按钮
- (void)creatLockButton {
    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(3 * ScreenWidth / 16 + j * ScreenWidth / 4, 3 * ScreenHeight / 16 + i * ScreenHeight / 4, ScreenWidth / 8, ScreenHeight / 8);
            
            //必须加上 
            button.userInteractionEnabled = NO;
            button.tag = 1000 + i * 3 + j;
            [button setImage:[UIImage imageNamed:@"blue_circle"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"yellow_circle"] forState:UIControlStateHighlighted];
            [self.buttonArray addObject:button];
            [self.view addSubview:button];
        }
    }
}

#pragma mark - touches事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch != nil) {
        for (UIButton *button in self.buttonArray) {
            CGPoint touchPoint = [touch locationInView:button];
            if ([button pointInside:touchPoint withEvent:nil]) {
                self.drawFlag = YES;
                self.lineStarPoint = button.center;
                [self.selectedButtonArray addObject:button];
                [button setImage:[UIImage imageNamed:@"yellow_circle"] forState:UIControlStateNormal];
            }

        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch && self.drawFlag) {
        self.lineEndPoint = [touch locationInView:self.backgroundImageView];
        for (UIButton *button in self.buttonArray) {
            CGPoint touchPoint = [touch locationInView:button];
            if ([button pointInside:touchPoint withEvent:nil]) {
                BOOL buttonContained = NO;
                for (UIButton *selectedButton in self.selectedButtonArray) {
                    if (selectedButton == button) {
                        buttonContained = YES;
                        break;
                    }
                }
                if (buttonContained == NO) {
                    [self.selectedButtonArray addObject:button];
                    [button setImage:[UIImage imageNamed:@"yellow_circle"] forState:UIControlStateNormal];
                }
            }
        }
        self.backgroundImageView.image =  [self drawLockLine];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    NSString *codeString = [NSString string];
    for (UIButton *selectedButton in self.selectedButtonArray) {
        NSString *buttonString = [NSString stringWithFormat:@"%ld", selectedButton.tag];
        codeString = [codeString stringByAppendingString:buttonString];
    }
    
    //记录手势输入的次数
    self.i++;
    
    if (self.indexPath) {
        if (self.i == 1) {
            self.firstTime = codeString;
        } else {
            self.secondTime = codeString;
        }
        if ([self.secondTime isEqualToString:self.firstTime]) {
//            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//            [user setObject:codeString forKey:@"lockCode"];
//            [user synchronize];
            [[AVUser currentUser] setObject:codeString forKey:@"lockCode"];
            [[AVUser currentUser] saveInBackground];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if (self.i == 1) {
                self.instructionLabel.text = @"请再次输入手势";
            } else {
                self.instructionLabel.text = @"请确保输入和第一次一致";
            }
        }
    } else {
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        NSString *code = [user objectForKey:@"lockCode"];
        NSString *code = [[AVUser currentUser] objectForKey:@"lockCode"];
        if ([code isEqualToString:codeString]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
    
    self.drawFlag = NO;
    self.backgroundImageView.image = nil;
    self.selectedButtonArray = nil;
}

//画图操作
- (UIImage *)drawLockLine {
    UIImage *image = nil;
    
    UIColor *color = [UIColor yellowColor];
    CGFloat width = 5.0f;
    
    CGSize imageContextSize = self.backgroundImageView.frame.size;
    
    UIGraphicsBeginImageContext(imageContextSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    CGContextMoveToPoint(context, self.lineStarPoint.x, self.lineStarPoint.y);
    for (UIButton *selectedButton in self.selectedButtonArray) {
        CGPoint drawPoint = selectedButton.center;
        CGContextAddLineToPoint(context, drawPoint.x, drawPoint.y);
    }
    CGContextAddLineToPoint(context, self.lineEndPoint.x, self.lineEndPoint.y);
    CGContextStrokePath(context);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
    
}

//取消提示框
- (void)dismissAlertAction:(NSTimer *)timer {
    UIAlertController *alertController = timer.userInfo;
    [alertController dismissViewControllerAnimated:YES completion:nil];
    alertController = nil;
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
