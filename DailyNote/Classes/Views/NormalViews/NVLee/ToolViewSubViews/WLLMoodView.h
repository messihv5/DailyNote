//
//  WLLMoodView.h
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//


/**
 *  心情视图, 选择心情及将日志分享
 */

#import <UIKit/UIKit.h>

@interface WLLMoodView : UIView

@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;
/**
 *  天气imageView的父视图
 */
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) NSInteger numberOfImage;

@end
