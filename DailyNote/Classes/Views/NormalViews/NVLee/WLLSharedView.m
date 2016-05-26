//
//  WLLSharedView.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLSharedView.h"

@implementation WLLSharedView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.height = 400;
    rect.size.width = 200;
    self.backgroundColor = [UIColor purpleColor];
}


@end
