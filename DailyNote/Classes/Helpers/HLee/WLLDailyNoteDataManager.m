//
//  WLLDailyNoteDataManager.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLDailyNoteDataManager.h"

@interface WLLDailyNoteDataManager ()

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
// 添加日记
- (void)addDailyNoteWithNote:(NoteDetail *)note {
    
    [self.noteData insertObject:note atIndex:0];
}

//加载某一天的日记
- (void)loadTenDiariesOfDateString:(NSString *)dateString finished:(void (^)())finished{
    [self.noteData removeAllObjects];
    NSString *zeroString = [dateString stringByAppendingString:@" 00:00:00"];
    
    NSString *twentyfourString = [dateString stringByAppendingString:@" 23:59:59"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSDate *zeroDate = [formatter dateFromString:zeroString];
    
    NSDate *twentyfourDate = [formatter dateFromString:twentyfourString];
    
    AVQuery *dateQuery1 = [AVQuery queryWithClassName:@"Diary"];
    
    [dateQuery1 whereKey:@"belong" equalTo:[AVUser currentUser]];
    [dateQuery1 whereKey:@"createdAt" greaterThan:zeroDate];
    
    AVQuery *dateQuery2 = [AVQuery queryWithClassName:@"Diary"];
    
    [dateQuery2 whereKey:@"createdAt" lessThan:twentyfourDate];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[dateQuery1,dateQuery2]];
    
    [query orderByDescending:@"createdAt"];
    query.limit = 10;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.noteData addObjectsFromArray:objects];
        finished();
    }];
}


@end
