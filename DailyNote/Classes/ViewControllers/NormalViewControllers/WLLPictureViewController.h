//
//  WLLPictureViewController.h
//  DailyNote
//
//  Created by Messi on 16/7/23.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WLLPassContentOffsetBlock)(NSInteger offsetByInteger);

@interface WLLPictureViewController : UIViewController

/**
 *  接收详情页面传过来的被点击的ImageView的tag，用于记录点击第几张照片
 */
@property (assign, nonatomic) NSInteger tagOfImageView;
/**
 *  接收从详情页面传过来的model
 */
@property (strong, nonatomic) NoteDetail *passedObject;

@property (copy, nonatomic) WLLPassContentOffsetBlock contentOffsetBlock;

@property (strong, nonatomic) NSMutableArray *localPictureArray;

@property (strong, nonatomic) NSMutableArray *internetPictureArray;

@end
