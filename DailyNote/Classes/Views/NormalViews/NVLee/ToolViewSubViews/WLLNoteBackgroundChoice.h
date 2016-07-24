//
//  WLLNoteBackgroundChoice.h
//  DailyNote
//
//  Created by CapLee on 16/6/14.
//  Copyright © 2016年 Messi. All rights reserved.
//


/**
 *  取消背景色
 */

#import <UIKit/UIKit.h>

// 取消选择背景颜色代理
@protocol CancelChoiceDelegate <NSObject>

/**
 *  取消背景色
 */
- (void)cancelChoice;

@end

@interface WLLNoteBackgroundChoice : UIView

@property (nonatomic, weak) id <CancelChoiceDelegate> cancelDelegate;

@end
