//
//  WLLNotesCategoryView.m
//  DailyNote
//
//  Created by CapLee on 16/5/25.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLNotesCategoryView.h"
#import "WLLDailyNoteDataManager.h"

@interface WLLNotesCategoryView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation WLLNotesCategoryView

@dynamic delegate;


- (void)awakeFromNib {
    
    self.dataSource = self;
    self.delegate = self;
    
    self.rowHeight = kHeight*0.05;
    
    // 初始化自身frame, color
    CGRect frame = CGRectMake((kWidth-kWidth*0.4831)/2, 64, kWidth*0.4831, 0);
    self.frame = frame;
    
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.layer.cornerRadius = 5;
    
    // 设置footView
    [self setupTableFootView];
    
}
// 设置footView
- (void)setupTableFootView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 100, 414, 30);
    [button setTitle:@"编辑我的分类" forState:UIControlStateNormal];
    
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.titleLabel.font = [UIFont sf_adapterScreenWithFont];
    
    // 添加点击响应
    [button addTarget:self action:@selector(editCategory:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableFooterView = button;
    
}


// 响应事件
- (void)editCategory:(UIButton *)button {
    if (_categoryDelegate && [_categoryDelegate respondsToSelector:@selector(pushCategoryEditView)]) {
        [_categoryDelegate pushCategoryEditView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *array = [[[WLLDailyNoteDataManager sharedInstance] getCategoryData] allKeys];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"category_cell"];
    }

    
//    NSArray *array = [[[WLLDailyNoteDataManager sharedInstance] getCategoryData] allKeys];
//    cell.textLabel.text = array[indexPath.row];
//    
//    cell.textLabel.textColor = [UIColor whiteColor];
//    
//    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_categoryDelegate && [_categoryDelegate respondsToSelector:@selector(showAppropriateDataWithIndex:)]) {
//        
//        [_categoryDelegate showAppropriateDataWithIndex:indexPath];
//    }
}



@end
