//
//  WLLMoodView.m
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLMoodView.h"

@implementation WLLMoodView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    CGRect frame = CGRectMake(0, kHeight, kWidth, kHeight*0.3);
    self.frame = frame;
}

@end
