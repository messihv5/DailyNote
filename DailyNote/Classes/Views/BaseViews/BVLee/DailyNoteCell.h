//
//  DailyNoteCell.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

/**
 *  DailyNoteCell
 */


#import <UIKit/UIKit.h>

@class NoteDetail;

@interface DailyNoteCell : UITableViewCell
/* 日记模型 */
@property (nonatomic, strong) NoteDetail *model;

@property (weak, nonatomic) IBOutlet UIImageView *noteImage;

@property (weak, nonatomic) IBOutlet UIView *timeView;
/* 内容 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


//- (CGFloat)heightForCell:(NSString *)text;
+ (CGFloat)heightForCell:(NSString *)text model:(NoteDetail *)model;

@end
