//
//  WLLToolView.h
//  DailyNote
//
//  Created by CapLee on 16/5/30.
//  Copyright © 2016年 Messi. All rights reserved.
//


/**
 *  键盘上方工具栏
 */

#import <UIKit/UIKit.h>

// 显示或隐藏键盘上方工具栏协议
@protocol ToolViewDelegate <NSObject>

/**
 *  显示或隐藏键盘上方工具栏协议方法
 */
- (void)showOrHideFontView;

/**
 *  显示或隐藏选择颜色view
 */
- (void)showOrHideNoteBackgroundColorView;

/**
 *  选择插入日记图片的来源
 */
- (void)notePicturesSource;

/**
 *  选择心情
 */
- (void)choiceMoodForNote;

@end

@interface WLLToolView : UIView

/* 代理属性 */
@property (nonatomic, assign) id <ToolViewDelegate> toolViewDelegate;

@end
