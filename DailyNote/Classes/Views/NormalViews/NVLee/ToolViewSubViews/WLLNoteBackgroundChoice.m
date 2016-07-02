//
//  WLLNoteBackgroundChoice.m
//  DailyNote
//
//  Created by CapLee on 16/6/14.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLNoteBackgroundChoice.h"

@implementation WLLNoteBackgroundChoice

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)cancelChoiceBackgroundColorAction:(UIButton *)sender {
    
    if (_cancelDelegate && [_cancelDelegate respondsToSelector:@selector(cancelChoice)]) {
        [_cancelDelegate cancelChoice];
    }
}

@end
