//
//  WLLTimePickerController.h
//  DailyNote
//
//  Created by Messi on 16/6/14.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Block)(NSString *string);

@interface WLLTimePickerController : UIViewController

@property (copy, nonatomic) Block block;

@end
