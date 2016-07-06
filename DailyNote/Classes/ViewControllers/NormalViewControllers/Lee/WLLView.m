//
//  WLLView.m
//  DailyNote
//
//  Created by CapLee on 16/7/6.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLView.h"

@implementation WLLView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor cyanColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
