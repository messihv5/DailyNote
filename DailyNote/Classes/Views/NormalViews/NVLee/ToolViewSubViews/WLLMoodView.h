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

@property (weak, nonatomic) IBOutlet UICollectionView *weatherIcon;
@end
