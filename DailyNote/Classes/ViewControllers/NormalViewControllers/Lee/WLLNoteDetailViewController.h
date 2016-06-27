//
//  WLLNoteDetailViewController.h
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteDetail;

@interface WLLNoteDetailViewController : UIViewController

@property (nonatomic, strong) NoteDetail *noteDetail;
@property (nonatomic, assign) NSIndexPath *index;

//接受从shareViewController传过来的日记
@property (strong, nonatomic) AVObject *passedObject;

@end
