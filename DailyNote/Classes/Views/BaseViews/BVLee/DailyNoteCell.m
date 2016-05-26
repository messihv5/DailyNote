//
//  DailyNoteCell.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "DailyNoteCell.h"
#import "NoteDetail.h"

@interface DailyNoteCell ()

/* 时间轴中两个圈 */
@property (weak, nonatomic) IBOutlet UIView *under;
@property (weak, nonatomic) IBOutlet UIView *upper;

/* 日期 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/* 星期 */
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
/* 年月 */
@property (weak, nonatomic) IBOutlet UILabel *monthAndYear;
/* 内容 */
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
/* 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DailyNoteCell

- (void)setModel:(NoteDetail *)model {
    
    _model = model;
    
    self.contentLabel.text = model.content;
    self.monthAndYear.text = model.monthAndYear;
    self.timeLabel.text = model.time;
    self.dateLabel.text = model.dates;
    self.weekLabel.text = model.weekLabel;
    
    // 设置时间轴中圆圈半径
    self.under.layer.cornerRadius = self.under.frame.size.height/2;
    self.upper.layer.cornerRadius = self.upper.frame.size.height/2;
    [self layoutIfNeeded];
    [self setNeedsLayout];
    
}


@end
