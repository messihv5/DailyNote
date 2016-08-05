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

/*日期*/
@property (strong, nonatomic) NSDate *date;
/* 日记内容 */
@property (nonatomic, copy) NSString *content;
/* 多久以前写的日记 */
@property (nonatomic, copy) NSString *timeString;
/*昵称*/
@property (copy, nonatomic) NSString *nickName;
/*点赞数*/
@property (copy, nonatomic) NSString *starNumber;
/*头像*/
@property (strong, nonatomic) NSURL *headImageUrl;
/*点赞用户数组*/
@property (strong, nonatomic) NSMutableArray *staredUserArray;
/*日记背景颜色*/
@property (strong, nonatomic) UIColor *backColor;
/*字体颜色*/
@property (strong, nonatomic) UIColor *fontColor;
/*字体大小*/
@property (copy, nonatomic) NSString *fontNumber;
/*日记的id*/
@property (copy, nonatomic) NSString *diaryId;
/*签名*/
@property (copy, nonatomic) NSString *signature;
/*总的点赞数*/
@property (copy, nonatomic) NSString *totalStarNumber;
/*该日记的点赞数*/
@property (copy, nonatomic) NSString *currentDiaryStarNumber;
/*背景图片*/
@property (strong, nonatomic) NSURL *backgroundImageUrl;
/*日记被阅读的次数*/
@property (copy, nonatomic) NSString *readTime;
/*存放照片*/
@property (copy, nonatomic) NSString *imageUrl;
/*存放日记里面的图片*/
@property (strong, nonatomic) NSMutableArray *photoArray;
/*存放图片url的数组*/
@property (strong, nonatomic) NSMutableArray *photoUrlArray;
/**
 *  日记的更新时间，主要用于记录日记删除的时间
 */
@property (strong, nonatomic) NSDate *updatedDate;
/**
 *  日记分享日期
 */
@property (strong, nonatomic) NSDate *sharedDate;
/**
 *  收藏的日记数组
 */
@property (strong, nonatomic) NSMutableArray *collectionDiaries;
/**
 *  保存天气的图标
 */
@property (strong, nonatomic) UIImage *weatherImage;

@end
