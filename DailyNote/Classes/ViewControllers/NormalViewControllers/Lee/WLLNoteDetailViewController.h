//
//  WLLNoteDetailViewController.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

/// DailyNote详情页面

#import <UIKit/UIKit.h>

typedef void(^DeleteDiaryBlock)();

@class NoteDetail;

@interface WLLNoteDetailViewController : UIViewController
/*接受从主页面传过来的日记*/
@property (nonatomic, strong) NoteDetail *passedObject;
/* 将cell下标传给Edit页面 */
@property (nonatomic, assign) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *title;

/**
 *  删除日记block，在详情页面删除日记，执行block，dailyNoteViewcontroller删除对应的日记model
 */
@property (copy, nonatomic) DeleteDiaryBlock deleteDiary;

@end
