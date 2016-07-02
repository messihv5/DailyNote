//
//  UIFont+ScreenFont.m
//  DailyNote
//
//  Created by CapLee on 16/6/13.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "UIFont+ScreenFont.h"


#define kFont4 kFont6s*480/736
#define kFont5 kFont6s*568/736
#define kFont6 kFont6s*667/736
#define kFont6s 17

@implementation UIFont (ScreenFont)

+ (UIFont *)sf_adapterScreenWithFont {
    
    CGFloat fontSize = 0;
    
    if (kHeight == 480) {
        fontSize = kFont4;
    } else if (kHeight == 568) {
        fontSize = kFont5;
    } else if (kHeight == 667) {
        fontSize = kFont6;
    } else if (kHeight == 736) {
        fontSize = kFont6s;
    }
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    return font;
}

@end
