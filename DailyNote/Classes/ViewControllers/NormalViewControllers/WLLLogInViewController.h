//
//  WLLLogInViewController.h
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^boolBlock)(BOOL isBackFromLoginController);

@interface WLLLogInViewController : UIViewController

@property (copy, nonatomic) boolBlock block;

@end
