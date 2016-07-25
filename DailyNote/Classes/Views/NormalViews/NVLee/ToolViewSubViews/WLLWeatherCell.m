//
//  WLLWeatherCell.m
//  DailyNote
//
//  Created by CapLee on 16/7/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLWeatherCell.h"

@implementation WLLWeatherCell

- (UIImageView *)weatherIcon {
    if (!_weatherIcon) {
        _weatherIcon = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_weatherIcon];
    }
    return _weatherIcon;
}

@end
