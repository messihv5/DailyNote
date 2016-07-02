//
//  WLLMyColor.m
//  DailyNote
//
//  Created by CapLee on 16/6/12.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLMyColor.h"

#define arcColor arc4random()%256/255.0

@implementation WLLMyColor

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor greenColor], [UIColor grayColor], [UIColor cyanColor], [UIColor purpleColor], [UIColor grayColor], [UIColor darkGrayColor], [UIColor yellowColor], [UIColor brownColor], [UIColor orangeColor], nil];
        
        self.fontColor = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor grayColor], [UIColor blackColor], [UIColor cyanColor], [UIColor purpleColor], [UIColor brownColor], [UIColor lightGrayColor], [UIColor whiteColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor colorWithRed:0.0 green:0.502 blue:0.502 alpha:1.0], [UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0], nil];
    }
    return self;
}




@end
