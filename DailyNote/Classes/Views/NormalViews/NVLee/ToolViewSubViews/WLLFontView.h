//
//  WLLFontView.h
//  DailyNote
//
//  Created by CapLee on 16/6/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

/**
 *  显示字体view
 */

#import <UIKit/UIKit.h>

// 改变字体大小协议
@protocol ChangeFontDelegate <NSObject>
/**
 *  改变字体大小协议方法
 *
 *  @param slider 根据slider的值
 */
- (void)changeFontWithSlider:(UISlider *)slider;

/**
 *  改变字体颜色
 *
 *  @param fontColor color
 */
- (void)changeFontColor:(UIColor *)fontColor;

@end

@interface WLLFontView : UIView
/* 协议属性 */
@property (nonatomic, assign) id <ChangeFontDelegate> fontDelegate;

@end
