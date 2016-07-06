//
//  WLLDailyNoteDataManager.h
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//


// 单例: 管理日记页面数据

#import <Foundation/Foundation.h>

@class NoteDetail;

@interface WLLDailyNoteDataManager : NSObject

/* 存储日志 */
@property (nonatomic, strong) NSMutableArray *noteData;


/**
 * 单例
 */
+ (instancetype)sharedInstance;


/**
 * 返回index对应的模型
 */
- (NoteDetail *)getModelWithIndex:(NSInteger)index;


/**
 * 请求分类数据
 */
- (void)requestDataAndFinished:(void(^)())finished;


/**
 *  返回日记数组
 *
 *  @return 返回数组
 */
- (NSMutableArray *)getNoteData;

/**
 *  返回数组个数
 *
 *  @return 个数
 */
- (NSInteger)countOfNoteData;


/**
 *  添加日志
 *
 *  @param note 日志模型
 */
- (void)addDailyNoteWithNote:(NoteDetail *)note;

//根据点击的日期加载日记
- (void)loadTenDiariesOfDateString:(NSString *)dateString finished:(void (^)())finished;

@end
