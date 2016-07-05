//
//  WLLNoteDetailViewController.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

/// DailyNote详情页面

#import <UIKit/UIKit.h>

@class NoteDetail;

@interface WLLNoteDetailViewController : UIViewController
/* NoteDetail 模型 */
@property (nonatomic, strong) AVObject *passedObject;
/* 将cell下标传给Edit页面 */
@property (nonatomic, assign) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *title;

@end
