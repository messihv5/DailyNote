//
//  WLLToolView.m
//  DailyNote
//
//  Created by CapLee on 16/5/30.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLToolView.h"

@implementation WLLToolView

// toolView frame
- (void)drawRect:(CGRect)rect {
    self.height = kHeight * 0.07;
    self.y = kHeight - self.height;
    self.width = kWidth;
}

// 键盘显示/隐藏
- (IBAction)showOrHiddenKeyborad:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change) name:@"change" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"change" object:nil];
}
// 改变字体大小及颜色
- (IBAction)changeNoteFontEvent:(UIButton *)sender {
    
    if (_toolViewDelegate && [_toolViewDelegate respondsToSelector:@selector(showOrHideFontView)]) {
        [_toolViewDelegate showOrHideFontView];
    }
    
}
// 选择日记纸张背景
- (IBAction)choiceBackgroundColor:(UIButton *)sender {
    
    if (_toolViewDelegate && [_toolViewDelegate respondsToSelector:@selector(showOrHideNoteBackgroundColorView)]) {
        [_toolViewDelegate showOrHideNoteBackgroundColorView];
    }
}
// 日记中插入图片
- (IBAction)insertPicturesIntoNote:(UIButton *)sender {
    if (_toolViewDelegate && [_toolViewDelegate respondsToSelector:@selector(notePicturesSource)]) {
        [_toolViewDelegate notePicturesSource];
    }
}
// 心情
- (IBAction)choiceMood:(UIButton *)sender {
    if (_toolViewDelegate && [_toolViewDelegate respondsToSelector:@selector(choiceMoodForNote)]) {
        [_toolViewDelegate choiceMoodForNote];
    }
}


- (void)change {

}

@end
