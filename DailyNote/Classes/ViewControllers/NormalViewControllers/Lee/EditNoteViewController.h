//
//  EditNoteViewController.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//


/// 编辑页面 

#import <UIKit/UIKit.h>
@class NoteDetail;

typedef void(^Block)(NoteDetail *passedToDailyNote);

@interface EditNoteViewController : UIViewController
/* 传入detail页面cell下标 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *eTitle;

//接收从详情页面传过来的AVObject
@property (strong, nonatomic) NoteDetail *passedObject;
/*反向给dailyNOte页面传个对象*/
@property (copy, nonatomic) Block block;
/*把第一页面数组的个数传过来*/
@property (assign, nonatomic) NSInteger numberOfModelInArray;
/**
 *  标记是否从calendar穿过来的model
 */
@property (assign, nonatomic) BOOL isFromeCalendar;

@end
