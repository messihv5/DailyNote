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

#pragma mark - 数组
// 请求数据
//- (void)requestDataAndFinished:(void (^)())finished {
//    
//    [self.noteData removeAllObjects];
//    
//    // 异步加载数据
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        NoteDetail *model = [[NoteDetail alloc] init];
//        // 日记内容初始值
//        model.content = @"今天下载了随手记~~~今天下载了随手记~~~今天下载了随手记~~~rect.size.height/self.contentLabel.numberOfLinesrect.size.height/self.contentLabel.numberOfLines";
//        model.date = [[NSDate alloc] init];
//        model.dates = [NSString nt_nowDateFromDate:model.date];
//        model.monthAndYear = [NSString nt_monthAndYearFromDate:model.date];
//        model.time = [NSString nt_timeFromDate:model.date];
//        model.weekLabel = [NSString wd_weekDayFromDate:model.date];
//        
//        // 背景色, 字体颜色, 字体大小初始值
//        model.backColor = [UIColor whiteColor];
//        model.fontColor = [UIColor blackColor];
//        model.contentFont = [UIFont sf_adapterScreenWithFont];
//        
//        [self.noteData addObject:model];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            finished();
//        });
//    });
//}


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
        [self getDataFromArray:objects];
        finished();
    }];
}

- (NSArray *)getDataFromArray:(NSArray <AVObject *>*)array {
    for (AVObject *object in array) {
        NoteDetail *model = [[NoteDetail alloc] init];
        
        //diaryID
        model.diaryId = object.objectId;
        
        //获取日期
        model.date = [object objectForKey:@"createdAt"];
        
        //获取点赞用户数组，判断用户是否点赞
        NSMutableArray *staredUserArray = [object objectForKey:@"staredUser"];
        model.staredUserArray = staredUserArray;
        
        //获取日记的创建时间
        NSString *string = nil;
        
        NSDate *createdDate = [object objectForKey:@"createdAt"];
        
        NSDate *currentDate = [NSDate date];
        
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:createdDate];
        
        if (timeInterval / (24 * 60 * 60) >= 1) {
            string = [NSString stringWithFormat:@"%ld天前", (NSInteger)timeInterval / (24 * 60 * 60) ];
        } else if (timeInterval / (60 * 60) >= 1) {
            string = [NSString stringWithFormat:@"%ld小时前", (NSInteger)timeInterval / (60 * 60)];
        } else if (timeInterval / 60 >= 1) {
            string = [NSString stringWithFormat:@"%ld分钟以前", (NSInteger)timeInterval / 60];
        } else {
            string = [NSString stringWithFormat:@"%ld秒前", (NSInteger)timeInterval];
        }
        model.timeString = string;
        
        //点赞数
        model.starNumber = [object objectForKey:@"starNumber"];
        if (model.starNumber == nil) {
            model.starNumber = @"0";
        }
        
        //内容
        model.content = [object objectForKey:@"content"];
        
        //背景颜色
        NSData *backColorData = [object objectForKey:@"backColor"];
        NSKeyedUnarchiver *backColorUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:backColorData];
        UIColor *backColor = [backColorUnarchiver decodeObjectForKey:@"backColor"];
        model.backColor = backColor;
        
        //字体颜色
        NSData *fontColorData = [object objectForKey:@"fontColor"];
        NSKeyedUnarchiver *fontColorUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:fontColorData];
        UIColor *fontColor = [fontColorUnarchiver decodeObjectForKey:@"fontColor"];
        model.fontColor = fontColor;
        
        //字体大小
        NSString *fontNumberString = [object objectForKey:@"fontNumber"];
        model.fontNumber = fontNumberString;
        
        //获取当前日记的点赞数
        model.currentDiaryStarNumber = [object objectForKey:@"starNumber"];
        
        //获取日记的阅读次数
        NSString *readTime = [object objectForKey:@"readTime"];
        model.readTime = readTime;
        
        //获取到这篇日记的作者的信息
        NSArray *keys = [NSArray arrayWithObjects:@"belong", nil];
        [object fetchInBackgroundWithKeys:keys block:^(AVObject *object, NSError *error) {
            AVUser *relatedUser = [object objectForKey:@"belong"];
            
            //获取用户的nickName
            model.nickName = [relatedUser objectForKey:@"nickName"];
            
            //获取签名
            model.signature = [relatedUser objectForKey:@"signature"];
            
            //获取总的点赞数
            model.totalStarNumber = [relatedUser objectForKey:@"starNumber"];
            
            //获取背景图片
            AVFile *backgroundImage = [relatedUser objectForKey:@"theBackgroundImage"];
            if (backgroundImage == nil) {
                model.backgroundImage = nil;
            } else {
                [backgroundImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    UIImage *image = [UIImage imageWithData:data];
                    model.backgroundImage = image;
                }];
            }
            
            //获取headImage
            AVFile *headImage = [relatedUser objectForKey:@"headImage"];
            
            if (headImage == nil) {
                model.headImage = nil;
            } else {
                [headImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    UIImage *image = [UIImage imageWithData:data];
                    model.headImage = image;
                }];
            }
        }];
        [self.noteData addObject:model];
    }
    return self.noteData;
}

//下拉加载某一天剩余的日记
- (void)loadMoreDiariesOfDateString:(NSString *)dateString dateFromloadedDiary:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    NSString *zeroString = [dateString stringByAppendingString:@" 00:00:00"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSDate *zeroDate = [formatter dateFromString:zeroString];
    
    AVQuery *zeroDateQuery = [AVQuery queryWithClassName:@"Diary"];
    
    [zeroDateQuery whereKey:@"createdAt" greaterThanOrEqualTo:zeroDate];
    
    AVQuery *dateQuery = [AVQuery queryWithClassName:@"Diary"];
    
    [dateQuery whereKey:@"createdAt" lessThan:date];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[zeroDateQuery, dateQuery]];
    
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}

//上拉加载dailyNoteViewcontroller主页面的10篇日记
- (void)loadTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished{
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" lessThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}

//下拉刷新dailyNoteViewcontroller主页面的10篇日记
- (void)refreshTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 10;
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query whereKey:@"createdAt" greaterThan:date];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}

//下拉刷新指定日期的10篇日记
- (void)refreshTenDiriesOfTheCurrentUserByDateString:(NSString *)dateString dateFromLoadDiary:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    NSString *twentyfourString = [dateString stringByAppendingString:@" 23:59:59"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSDate *twentyfourDate = [formatter dateFromString:twentyfourString];
    
    AVQuery *twentyfourDateQuery = [AVQuery queryWithClassName:@"Diary"];
    
    [twentyfourDateQuery whereKey:@"createdAt" lessThanOrEqualTo:twentyfourDate];
    
    AVQuery *dateQuery = [AVQuery queryWithClassName:@"Diary"];
    
    [dateQuery whereKey:@"createdAt" greaterThan:date];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[twentyfourDateQuery, dateQuery]];
    
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}

//加载10篇分享的日记
- (void)loadTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
//    [query whereKey:@"isPublic" equalTo:@"YES"];
    [query whereKey:@"createdAt" lessThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
    
}

//刷新10篇分享的日记
- (void)refreshTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
    
    
}

//加载10篇收藏的日记
- (void)loadTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVRelation *collectionRelation = [[AVUser currentUser] relationForKey:@"collectionDiaries"];
    
    AVQuery *relationQuery = [collectionRelation query];
    
    relationQuery.limit = 10;
    [relationQuery orderByDescending:@"createdAt"];
    [relationQuery whereKey:@"createdAt" lessThan:date];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}
//刷新10篇收藏的日记
- (void)refreshTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVRelation *collectionRelation = [[AVUser currentUser] relationForKey:@"collectionDiaries"];
    
    AVQuery *relationQuery = [collectionRelation query];
    
    relationQuery.limit = 10;
    [relationQuery orderByDescending:@"createdAt"];
    [relationQuery whereKey:@"createdAt" greaterThan:date];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
    }];
}

@end
