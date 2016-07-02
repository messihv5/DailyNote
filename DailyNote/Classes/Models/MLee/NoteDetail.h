//
//  NoteDetail.h
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

// 日记模型

#import <Foundation/Foundation.h>

@interface NoteDetail : NSObject
/* 日期 */
@property (nonatomic, strong) NSDate *date;
/* 日记内容 */
@property (nonatomic, copy) NSString *content;
/* 日期 */
@property (nonatomic, copy) NSString *dates;
/* 礼拜 */
@property (nonatomic, copy) NSString *weekLabel;
/* 年月 */
@property (nonatomic, copy) NSString *monthAndYear;
/* 时间 */
@property (nonatomic, copy) NSString *time;
/* 字体大小 */
@property (nonatomic, strong) UIFont *contentFont;
/* 存储背景色, 字体颜色 */
@property (nonatomic, strong) UIColor *backColor, *fontColor;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray<UIImage *> *imageArray;

@end
