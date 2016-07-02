//
//  UIView+WLLExtension.h
//  DailyNote
//
//  Created by CapLee on 16/6/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

/**
 *  UIView扩展
 *
 *  将宽高等重写, 方便使用
 */

#import <UIKit/UIKit.h>

@interface UIView (WLLExtension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

/**
 * 从xib中加载view
 */
+ (instancetype)viewFromXib;

/**
 *  添加遮屏效果view
 */
+ (UIView *)cs_viewCoverMainSreen;
@end
