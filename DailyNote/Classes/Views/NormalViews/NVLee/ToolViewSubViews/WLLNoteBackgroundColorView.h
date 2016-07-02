//
//  WLLNoteBackgroundColorView.h
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//


/**
 *  选择日记背景色页面
 */

#import <UIKit/UIKit.h>

// 改变日记背景颜色协议
@protocol ChangeNoteBackgroundColorDelegate <NSObject>

/**
 *  改变背景颜色协议方法
 *
 *  @param color 选中item的颜色
 */
- (void)changeNoteBackgroundColor:(UIColor *)color;

@end

@interface WLLNoteBackgroundColorView : UICollectionView

/* 协议属性 */
@property (nonatomic, assign) id <ChangeNoteBackgroundColorDelegate> colorDelegate;

@end
