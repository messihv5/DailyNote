//
//  WLLNoteBackgroundChoice.h
//  DailyNote
//
//  Created by CapLee on 16/6/14.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CancelChoiceDelegate <NSObject>

- (void)cancelChoice;

@end

@interface WLLNoteBackgroundChoice : UIView

@property (nonatomic, weak) id <CancelChoiceDelegate> cancelDelegate;

@end
