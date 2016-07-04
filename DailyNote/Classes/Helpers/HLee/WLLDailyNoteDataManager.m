//
//  WLLDailyNoteDataManager.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLDailyNoteDataManager.h"

@interface WLLDailyNoteDataManager ()

/* 存储日志 */
@property (nonatomic, strong) NSMutableArray *noteData;

@end

static WLLDailyNoteDataManager *manager = nil;

@implementation WLLDailyNoteDataManager

// 单例实现
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WLLDailyNoteDataManager alloc] init];
    });
    return manager;
}

// lazy loading
- (NSMutableArray *)noteData {
    
    if (!_noteData) {
        _noteData = [[NSMutableArray alloc] init];
    }
    return _noteData;
}

#pragma mark - 数组
// 请求数据
- (void)requestDataAndFinished:(void (^)())finished {
    
    [self.noteData removeAllObjects];
    
    // 异步加载数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NoteDetail *model = [[NoteDetail alloc] init];
        // 日记内容初始值
        model.content = @"今天下载了随手记~~~今天下载了随手记~~~今天下载了随手记~~~rect.size.height/self.contentLabel.numberOfLinesrect.size.height/self.contentLabel.numberOfLines";
        model.date = [[NSDate alloc] init];
        model.dates = [NSString nt_nowDateFromDate:model.date];
        model.monthAndYear = [NSString nt_monthAndYearFromDate:model.date];
        model.time = [NSString nt_timeFromDate:model.date];
        model.weekLabel = [NSString wd_weekDayFromDate:model.date];
        
        // 背景色, 字体颜色, 字体大小初始值
        model.backColor = [UIColor whiteColor];
        model.fontColor = [UIColor blackColor];
        model.contentFont = [UIFont sf_adapterScreenWithFont];
        
        [self.noteData addObject:model];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            finished();
        });
    });
}


// 返回模型
- (NoteDetail *)getModelWithIndex:(NSInteger)index{
    
    NoteDetail *model = self.noteData[index];
    return model;
}

// 取到分类数组
- (NSMutableArray *)getNoteData {
    return self.noteData;
}

// 返回数组个数
- (NSInteger)countOfNoteData {
    
    return self.noteData.count;
}

// 添加日记
- (void)addDailyNoteWithNote:(NoteDetail *)note {
    
    [self.noteData insertObject:note atIndex:0];
}



@end
