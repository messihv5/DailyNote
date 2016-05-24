//
//  DailyNoteCell.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "DailyNoteCell.h"

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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 设置时间轴中圆圈半径
    self.under.layer.cornerRadius = self.under.frame.size.height/2;
    self.upper.layer.cornerRadius = self.upper.frame.size.height/2;
    [self layoutIfNeeded];
    [self setNeedsLayout];
    
    self.contentLabel.text = @"日本, 一个小小的弹丸之地, 一个资源极度匮乏的岛国, 其早就了一场极度惨烈的世界大战";
    
    // 设置时间
    [self setTimeLabels];
    // 设置星期
    [self setWeek];
}

/**
 * 设置时间
 */
- (void)setTimeLabels {
    
    // 初始化date
    NSDate *date = [[NSDate alloc] init];
    // 设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    NSDateFormatter *formatterMY = [[NSDateFormatter alloc] init];
    [formatterMY setDateFormat:@"yyyy.MM"];
    
    NSDateFormatter *formatterT = [[NSDateFormatter alloc] init];
    [formatterT setDateFormat:@"HH:mm"];
    
    // 按照时间格式将date转换为所需时间
    NSString *dateLabel = [formatter stringFromDate:date];
    
    NSString *monthAndYear = [formatterMY stringFromDate:date];
    
    NSString *time = [formatterT stringFromDate:date];
    
    self.dateLabel.text = dateLabel;
    self.monthAndYear.text = monthAndYear;
    self.timeLabel.text = time;
}

/**
 * 设置星期
 */
- (void)setWeek {
    
    // 初始date
    NSDate *date = [[NSDate alloc] init];
    
    // 初始calendar
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 初始dateComponents
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // 从date中按照unitFlags内容抽取时间: 年, 月, 日, 周, 时, 分, 秒
    comps = [calendar components:unitFlags fromDate:date];
    
    NSInteger week = [comps weekday];
    NSString *weekStr = [self getweek:week];
    
    self.weekLabel.text = weekStr;

}

/**
 * 根据week对应为周几
 */
- (NSString*)getweek:(NSInteger)week {
    
    NSString *weekStr = nil;
    
    if(week==1)    {
        weekStr=@"周日";
    }else if(week==2){
        weekStr=@"周一";
    }else if(week==3){
        weekStr=@"周二";
    }else if(week==4){
        weekStr=@"周三";
    }else if(week==5){
        weekStr=@"周四";
    }else if(week==6){
        weekStr=@"周五";
    }else if(week==7){
        weekStr=@"周六";
    }
    return weekStr;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
