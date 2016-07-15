//
//  WLLShareDetailViewController.h
//  DailyNote
//
//  Created by Messi on 16/6/21.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Block)(NSString *starNumber);
typedef void (^ImageBlock)(UIImage *image);

@interface WLLShareDetailViewController : UIViewController

@property (strong, nonatomic) NoteDetail *passedObject;
/*把点赞数传回去*/
@property (copy, nonatomic) Block block;
/*把点赞的image传回去*/
@property (copy, nonatomic) ImageBlock imageBlock;
@property (strong, nonatomic) NSIndexPath *passedIndexPath;

@end
