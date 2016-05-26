//
//  WLLDailyNoteDataManager.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLDailyNoteDataManager.h"
#import "NoteDetail.h"

@interface WLLDailyNoteDataManager ()

@property (nonatomic, strong) NSMutableArray *noteArray;

@end

static WLLDailyNoteDataManager *manager = nil;

@implementation WLLDailyNoteDataManager

// 单例实现
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WLLDailyNoteDataManager new];
    });
    return manager;
}

// lazy loading
- (NSMutableArray *)noteArray {
    
    if (!_noteArray) {
        _noteArray = [[NSMutableArray alloc] init];
    }
    return _noteArray;
}

// 请求数据
- (void)requestDataAndFinished:(void (^)())finished {
    
    // 异步加载数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (int i = 0; i < 5; i++) {
            
            NoteDetail *model = [[NoteDetail alloc] init];
            model.content = [NSString stringWithFormat:@"%d---日本, 一个小小的弹丸之地, 一个资源极度匮乏的岛国, 其早就了一场极度惨烈的世界大战", i];
            model.date = [[NSDate alloc] initWithTimeIntervalSinceNow:(i*5+i)*3600];
            
            // 设置时间格式
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd"];
            
            NSDateFormatter *formatterMY = [[NSDateFormatter alloc] init];
            [formatterMY setDateFormat:@"yyyy.MM"];
            
            NSDateFormatter *formatterT = [[NSDateFormatter alloc] init];
            [formatterT setDateFormat:@"HH:mm"];
            
            // 按照时间格式将date转换为所需时间
            NSString *dateLabel = [formatter stringFromDate:model.date];
            
            NSString *monthAndYear = [formatterMY stringFromDate:model.date];
            
            NSString *time = [formatterT stringFromDate:model.date];
            
            model.dates = dateLabel;
            model.monthAndYear = monthAndYear;
            model.time = time;
            
            // 初始calendar
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            // 初始dateComponents
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            
            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            
            // 从date中按照unitFlags内容抽取时间: 年, 月, 日, 周, 时, 分, 秒
            comps = [calendar components:unitFlags fromDate:model.date];
            
            NSInteger week = [comps weekday];
            NSString *weekStr = [self getweek:week];
            model.weekLabel = weekStr;
            
            [self.noteArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            finished();
        });
    });
}

// 根据week对应为周几
- (NSString*)getweek:(NSInteger)week {
    
    NSString *weekStr = nil;
    
    if (week==1) {
        weekStr = @"周日";
    } else if (week == 2) {
        weekStr = @"周一";
    } else if (week == 3) {
        weekStr = @"周二";
    } else if (week==4){
        weekStr = @"周三";
    } else if (week == 5) {
        weekStr = @"周四";
    } else if (week == 6) {
        weekStr = @"周五";
    } else if (week == 7){
        weekStr = @"周六";
    }
    return weekStr;
}

// 返回数组个数
- (NSInteger)countOfNoteArray {
    return self.noteArray.count;
}

// 返回模型
- (NoteDetail *)returnModelWithIndex:(NSInteger)index {
    
    NoteDetail *model = self.noteArray[index];
    return model;
}

@end
