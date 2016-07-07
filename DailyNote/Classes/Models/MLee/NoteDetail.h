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

/* 日记内容 */
@property (nonatomic, copy) NSString *content;
/* 多久以前写的日记 */
@property (nonatomic, copy) NSString *timeString;
/*昵称*/
@property (copy, nonatomic) NSString *nickName;
/*点赞数*/
@property (copy, nonatomic) NSString *starNumber;
/*头像*/
@property (strong, nonatomic) UIImage *headImage;
@property (strong, nonatomic) NSArray *staredUserArray;

@end
