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

@property (strong, nonatomic) UIImage *topicImage;
@property (strong, nonatomic) UIImage *navigationImage1;
@property (strong, nonatomic) UIImage *navigationImage2;
@property (strong, nonatomic) UIImage *navigationImage3;
@property (strong, nonatomic) UIImage *navigationImage4;
@property (strong, nonatomic) UIImage *tabbarImage1;
@property (strong, nonatomic) UIImage *tabbarImage2;
@property (strong, nonatomic) UIImage *tabbarImage3;
@property (strong, nonatomic) UIImage *tabbarImage4;

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
