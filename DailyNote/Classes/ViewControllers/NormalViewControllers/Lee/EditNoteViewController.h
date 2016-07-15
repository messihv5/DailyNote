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

//typedef void(^Block)(NoteDetail *passedToDailyNote);

// 由未经indexPath进入而获取的model, 修改后传至DailyNote页面
@protocol SendEditModelDelegate <NSObject>

/**
 *  由未经indexPath进入而获取的model, 修改后传至DailyNote页面
 *
 *  @param model 修改后model
 */
- (void)sendEditModel:(NoteDetail *)model;

@end

@interface EditNoteViewController : UIViewController
/* 传入detail页面cell下标 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *eTitle;

@property (nonatomic, assign) id <SendEditModelDelegate> modelDelegate;

//接收从详情页面传过来的AVObject
@property (strong, nonatomic) NoteDetail *passedObject;

//@property (copy, nonatomic) Block block;

@end
