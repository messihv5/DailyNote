//
//  WLLModifyInfomationViewController.h
//  DailyNote
//
//  Created by Messi on 16/5/31.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Block)(NSString *nickName, NSString *signature);

@interface WLLModifyInfomationViewController : UIViewController

@property (copy, nonatomic) NSString *nickNameString;
@property (copy, nonatomic) NSString *signatureString;
@property (copy, nonatomic) Block block;

@end
