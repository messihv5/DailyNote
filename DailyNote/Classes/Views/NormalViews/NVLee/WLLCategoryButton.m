//
//  WLLCategoryButton.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLCategoryButton.h"

@implementation WLLCategoryButton

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 重新调整文字位置
    // 为什么要设置中间变量 : https://segmentfault.com/q/1010000000177216  http://stackoverflow.com/questions/8087823/why-does-xcode-say-the-following-expression-is-not-assignable
    CGRect tmp = self.titleLabel.frame;
    tmp.origin.x = 0;
    tmp.origin.y = 0;
    tmp.size.height = 30;
    self.titleLabel.frame = tmp;
    
    // 设置文字大小
    self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    // 宽度自动适应文字, 不能设置宽度
    [self.titleLabel adjustsFontSizeToFitWidth];
    
    // 重新调整图片位置
    CGRect img = self.imageView.frame;
    img.origin.x = self.titleLabel.frame.size.width;
    img.origin.y = 0;
    img.size.height = 25;
    img.size.width = 25;
    self.imageView.frame = img;
    
}

@end
