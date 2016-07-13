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

//根据点击的日期加载日记
- (void)loadTenDiariesOfDateString:(NSString *)dateString finished:(void (^)())finished;

//加载dailyNoteViewcontroller页面的10篇日记
- (void)loadTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished error:(void (^)())hasError;

//下拉加载某一天剩余的日记
- (void)loadMoreDiariesOfDateString:(NSString *)dateString dateFromloadedDiary:(NSDate *)date finished:(void (^)())finished;

//下拉刷新dailyNoteViewcontroller主页面的10篇日记
- (void)refreshTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished;

//下拉刷新指定日期的10篇日记
- (void)refreshTenDiriesOfTheCurrentUserByDateString:(NSString *)dateString dateFromLoadDiary:(NSDate *)date finished:(void (^)())finished;

//加载10篇分享的日记
- (void)loadTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished error:(void (^)())hasError;

//刷新10篇分享的日记
- (void)refreshTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished;

//加载10篇收藏的日记
- (void)loadTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished;

//刷新10篇收藏的日记
- (void)refreshTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished;
@end
