//
//  NoteDetail.h
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteDetail : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *dates;
@property (nonatomic, copy) NSString *weekLabel;
@property (nonatomic, copy) NSString *monthAndYear;
@property (nonatomic, copy) NSString *time;

@end
