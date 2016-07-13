//
//  WLLShareDetailViewController.h
//  DailyNote
//
//  Created by Messi on 16/6/21.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Block)(NSString *starNumber);

@interface WLLShareDetailViewController : UIViewController

@property (strong, nonatomic) NoteDetail *passedObject;
@property (copy, nonatomic) Block block;
@property (strong, nonatomic) NSIndexPath *passedIndexPath;

@end
