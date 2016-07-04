//
//  DailyNoteCell.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "DailyNoteCell.h"

@interface DailyNoteCell ()


/* 日期 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/* 星期 */
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
/* 年月 */
//@property (weak, nonatomic) IBOutlet UILabel *monthAndYear;
/* 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DailyNoteCell

- (void)setModel:(AVObject *)model {
    
    _model = model;
    
    self.contentLabel.text = [model objectForKey:@"content"];
    
    NSDate *createdDate = [model objectForKey:@"createdAt"];
    
    self.weekLabel.text = [NSString wd_weekDayFromDate:createdDate];
    
    self.timeLabel.text = [NSString nt_timeFromDate:createdDate];
    
    self.dateLabel.text = [NSString nt_monthAndYearFromDate:createdDate];
    
    
    // 计算：1 获取要计算的字符串
    NSString *temp = self.contentLabel.text;
    // 计算：2 准备工作
    // 宽度和label的宽度一样，高度给一个巨大的值
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 2000);
    // 这里要和上面label指定的字体一样
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    // 计算：3 调用方法，获得rect
    CGRect rect = [temp boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    // 计算：4 获取当前的label的frame，并将新的frame重新设置上去
    CGRect frame = self.contentLabel.frame;
    frame.size.height = rect.size.height;
    self.contentLabel.frame = frame;

}

- (CGFloat)heightForCell:(NSString *)text {
    // 计算：1 准备工作
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 2000);
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    // 计算：2 通过字符串获得rect
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    CGFloat height = 20.287109;
    
    if (!self.noteImage.image) {
        if (rect.size.height <= 3 * height) {
            return rect.size.height + self.timeView.frame.size.height + 35;
        } else {
            return 3 * height + self.timeView.frame.size.height + 35;
        }
    } else {
        if (rect.size.height <= 3*height) {
            return rect.size.height + self.timeView.frame.size.height + self.noteImage.frame.size.height;
        } else {
            return 3*height + self.timeView.frame.size.height + self.noteImage.frame.size.height;
        }
        
    }
}


@end
