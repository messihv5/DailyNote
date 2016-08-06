//
//  UIView+WLLExtension.m
//  DailyNote
//
//  Created by CapLee on 16/6/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "UIView+WLLExtension.h"

@implementation UIView (WLLExtension)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (CGFloat)width {
    return  self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (CGFloat)height {
    return self.frame.size.height;
}

// 类方法 从xib中加载
+ (instancetype)viewFromXib {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self)
                                          owner:nil
                                        options:nil]
            lastObject];
}

+ (UIView *)cs_viewCoverMainSreen {
    
    CGRect frame = CGRectMake(0, 0, kWidth, kHeight);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    view.userInteractionEnabled = NO;
    return view;
}

@end
