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

// 由未经indexPath进入而获取的model, 修改后传至DailyNote页面
@protocol SendEditModelDelegate <NSObject>

/**
 *  由未经indexPath进入而获取的model, 修改后传至DailyNote页面
 *
 *  @param model 修改后model
 */
- (void)sendEditModel:(NoteDetail *)model;

@end

typedef void (^Block)(BOOL isRefreshing);

@interface EditNoteViewController : UIViewController
/* 传入detail页面cell下标 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *eTitle;

@property (nonatomic, assign) id <SendEditModelDelegate> modelDelegate;

//传给第一页面判断是否进行刷新
@property (assign, nonatomic) BOOL isRefreshing;
//传值
@property (copy, nonatomic) Block block;

@end
