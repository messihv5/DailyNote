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


/**
 * 单例
 */
+ (instancetype)sharedInstance;


/**
 * 请求数据
 */
- (void)requestDataAndFinished:(void(^)())finished;

/**
 * 返回index对应的模型
 */
- (NoteDetail *)returnModelWithIndex:(NSInteger)index;

/**
 * 返回数组个数
 */
- (NSInteger)countOfNoteArray;

@end
