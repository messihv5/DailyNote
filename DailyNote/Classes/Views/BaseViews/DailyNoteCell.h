//
//  DailyNoteCell.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteDetail;

@interface DailyNoteCell : UITableViewCell

/* 日记模型 */
@property (nonatomic, strong) NoteDetail *model;

@end
