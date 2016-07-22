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

- (BOOL)isNetworkAvailable {
    Reachability *network = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus = [network currentReachabilityStatus];
    
    if (networkStatus == 0) {
        return NO;
    } else {
        return YES;
    }
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
    
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24 * 60 * 60;
    [query orderByDescending:@"createdAt"];
    query.limit = 5;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}

//上拉加载某一天剩余的日记
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
    
    query.limit = 5;
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24 * 60 * 60;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}

//下拉刷新指定日期的5篇日记
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
    
    query.limit = 5;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}

//加载dailyNoteViewcontroller主页面的5篇日记
- (void)loadTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished error:(void (^)())hasError{
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24 * 60 * 60;
    
    query.limit = 5;
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"wasDeleted" notEqualTo:@"YES"];
    [query whereKey:@"createdAt" lessThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            hasError();
        } else {
            [self getDataFromArray:objects];
            finished();
            if ([WLLDailyNoteDataManager sharedInstance].isNetworkAvailable) {
                for (AVObject *object in objects) {
                    
                    NSArray *photoArray = [object objectForKey:@"photoArray"];
                    
                    NSArray *photoUrlArray = [object objectForKey:@"photoUrlArray"];
                    
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    if (photoArray != nil && photoArray.count != 0) {
                        for (AVFile *file in photoArray) {
                            [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                                NSString *urlString = file.url;
                                if ([photoUrlArray containsObject:urlString]) {
                                    
                                } else {
                                    [tempArray addObject:file.url];
                                    
                                    if (tempArray.count == photoArray.count) {
                                        [object addObjectsFromArray:tempArray forKey:@"photoUrlArray"];
                                        object.fetchWhenSave = YES;
                                        [object saveInBackground];
                                    }
                                    
                                }
                            }];
                        }
                    }
                    
                }

            }
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
    }];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

//下拉刷新dailyNoteViewcontroller主页面的5篇日记
- (void)refreshTenDiariesOfTheCurrentUserByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 5;
    [query whereKey:@"wasDeleted" notEqualTo:@"YES"];
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query whereKey:@"createdAt" greaterThan:date];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
                [self getDataFromArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}
- (void)getDataFromArray:(NSArray <AVObject *>*)array {
    for (AVObject *object in array) {
        NoteDetail *model = [[NoteDetail alloc] init];
        
        //diaryID
        model.diaryId = object.objectId;
        
        //获取日期
        model.date = [object objectForKey:@"createdAt"];
        
        //日记内容
        model.content = [object objectForKey:@"content"];
        
        //日记更新时间
        model.updatedDate = object.updatedAt;
        
        //图片数组
        NSMutableArray *photoArray = [object objectForKey:@"photoArray"];
        
        model.photoArray = photoArray;
        
        model.photoUrlArray = [object objectForKey:@"photoUrlArray"];

        [self.noteData addObject:model];

        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }
}


//加载5篇分享的日记
- (void)loadTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished error:(void (^)())hasError{
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 5;
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 24 * 60 * 60;
    [query orderByDescending:@"createdAt"];
//    [query whereKey:@"isPublic" equalTo:@"YES"];
    [query whereKey:@"createdAt" lessThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            hasError();
        } else {
            [self getDataFromShareArray:objects];
            finished();
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
    }];
}

//解析分享页面的数据
- (void)getDataFromShareArray:(NSArray *)array {
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
            string = [NSString stringWithFormat:@"%ld天前", (NSInteger)timeInterval / (24 * 60 * 60)];
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
        
        //获取当前日记的点赞数
        model.currentDiaryStarNumber = [object objectForKey:@"starNumber"];
        
        //获取日记的阅读次数
        NSString *readTime = [object objectForKey:@"readTime"];
        if (readTime == nil) {
            model.readTime = @"0";
        }
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
        
            model.backgroundImageUrl = [NSURL URLWithString:backgroundImage.url];
        
            //获取headImage
            AVFile *headImage = [relatedUser objectForKey:@"headImage"];
        
            model.headImageUrl = [NSURL URLWithString:headImage.url];
        }];
        [self.noteData addObject:model];
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }
}

//刷新5篇分享的日记
- (void)refreshTenDiariesOfSharingByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 5;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromShareArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}

//加载5篇收藏的日记
- (void)loadTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVRelation *collectionRelation = [[AVUser currentUser] relationForKey:@"collectionDiaries"];
    
    AVQuery *relationQuery = [collectionRelation query];
    
    relationQuery.limit = 5;
    relationQuery.cachePolicy = kAVCachePolicyCacheElseNetwork;
    relationQuery.maxCacheAge = 24 * 60 * 60;
    [relationQuery orderByDescending:@"createdAt"];
    [relationQuery whereKey:@"createdAt" lessThan:date];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromShareArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}
//刷新5篇收藏的日记
- (void)refreshTenDiariesOfCollectionByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    
    AVRelation *collectionRelation = [[AVUser currentUser] relationForKey:@"collectionDiaries"];
    
    AVQuery *relationQuery = [collectionRelation query];
    
    relationQuery.limit = 5;
    [relationQuery orderByDescending:@"createdAt"];
    [relationQuery whereKey:@"createdAt" greaterThan:date];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self getDataFromShareArray:objects];
        finished();
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    }];
}

/**
 *  加载五篇回收站的日记
 *
 *  @param date     当前的日期
 *  @param finished block，返回主页面刷新的block
 */
- (void)loadFiveDiariesOfRecycleByDate:(NSDate *)date finished:(void (^)())finished {
    [self.noteData removeAllObjects];
    AVQuery *query = [AVQuery queryWithClassName:@"Diary"];
    
    query.limit = 5;
    [query whereKey:@"belong" equalTo:[AVUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"wasDeleted" equalTo:@"YES"];
    [query whereKey:@"createdAt" lessThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        } else {
            [self getDataFromArray:objects];
            finished();
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
    }];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

@end
