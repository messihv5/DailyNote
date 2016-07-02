//
//  WLLNotesCategoryView.h
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//


/**
 *  选择分类页面
 */

#import <UIKit/UIKit.h>

/**
 *  编辑分类页面协议
 */
@protocol CategoryEditViewDelegate <NSObject>

/**
 *  推出分类页面
 */
- (void)pushCategoryEditView;

/**
 *  展示对应数据
 *
 *  @param index cell index
 */
- (void)showAppropriateDataWithIndex:(NSIndexPath *)index;

@end

@interface WLLNotesCategoryView : UITableView

@property (nonatomic, assign) id <CategoryEditViewDelegate> categoryDelegate;


@end
