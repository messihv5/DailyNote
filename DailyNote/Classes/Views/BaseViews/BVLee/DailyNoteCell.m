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
/* 时间 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DailyNoteCell

- (void)setModel:(NoteDetail *)model {
    
    _model = model;
    
    self.contentLabel.text = model.content;
    
    NSDate *createdDate = model.date;
    
    self.weekLabel.text = [NSString wd_weekDayFromDate:createdDate];
    
    self.timeLabel.text = [NSString nt_timeFromDate:createdDate];
    
    self.dateLabel.text = [NSString nt_monthAndYearFromDate:createdDate];
    
    //图片解析
    NSArray *photoArray = model.photoArray;
    
    if (photoArray != nil && photoArray.count != 0) {
        if ([photoArray[0] isKindOfClass:[AVFile class]]) {
            AVFile *file = photoArray[0];
            
            [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
                NSURL *url = [NSURL URLWithString:file.url];
                [self.noteImage sd_setImageWithURL:url];
            }];
        } else {
            
            NSString *path = photoArray[0];
            
            self.noteImage.image = [UIImage imageWithContentsOfFile:path];
        }
    }
    
    
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

+ (CGFloat)heightForCell:(NSString *)text model:(NoteDetail *) model{
    // 计算：1 准备工作
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 2000);
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    // 计算：2 通过字符串获得rect
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    CGFloat height = 20.287109;

    if (model.photoArray == nil) {
        
        if (rect.size.height <= height + 1) {
            return height + 28 + 40;
        } else if (rect.size.height <= 2 * height + 2 && rect.size.height > height + 1){
            return 2 * height + 28 + 40;
        } else {
            return 3 * height + 28 + 40;
        }
    } else if (model.photoArray.count == 0){
        if (rect.size.height <= height + 1) {
            return height + 28 + 40;
        } else if (rect.size.height <= 2 * height + 2 && rect.size.height > height + 1){
            return 2 * height + 28 + 40;
        } else {
            return 3 * height + 28 + 40;
        }
    } else {
        if (rect.size.height <= height + 1) {
            return height + 28 + 40 + 200;
        } else if (rect.size.height <= 2 * height + 2 && rect.size.height > height + 1){
            return 2 * height + 28 + 40 + 200;
        } else {
            return 3 * height + 28 + 40 + 200;
        }

    }
}


@end
