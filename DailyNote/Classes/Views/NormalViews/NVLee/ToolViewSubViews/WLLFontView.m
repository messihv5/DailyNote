//
//  WLLFontView.m
//  DailyNote
//
//  Created by CapLee on 16/6/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLFontView.h"
#import "WLLMyColor.h"

@interface WLLFontView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
/* 当前字体大小 */
@property (weak, nonatomic) IBOutlet UILabel *currentFont;
/* 改变字体大小的滑条 */
@property (weak, nonatomic) IBOutlet UISlider *changeSlider;
/* 颜色选择栏 */
@property (weak, nonatomic) IBOutlet UICollectionView *fontColorView;
/* 显示当前颜色 */
@property (weak, nonatomic) IBOutlet UIView *currentColor;

@end


@implementation WLLFontView

- (void)awakeFromNib {
    // 指定选择字体颜色View代理
    self.fontColorView.dataSource = self;
    self.fontColorView.delegate = self;
    // 注册item
    [self.fontColorView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.currentFont.text = [NSString stringWithFormat:@"%.0f", self.changeSlider.value];
    
}

// slider 拖动改变当前字体大小
- (IBAction)changeFont:(UISlider *)sender {
    self.currentFont.text = [NSString stringWithFormat:@"%0.f", sender.value];
    // 调用代理
    if (_fontDelegate && [_fontDelegate respondsToSelector:@selector(changeFontWithSlider:)]) {
        [_fontDelegate changeFontWithSlider:sender];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    
    return myColor.fontColor.count;
}

// 返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    cell.backgroundColor = myColor.fontColor[indexPath.row];
    
    return cell;
}

// cell 返回大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(35, 20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(itemEdgesInset, itemEdgesInset, itemEdgesInset, itemEdgesInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    cell.backgroundColor = myColor.fontColor[indexPath.row];
    self.currentColor.backgroundColor = cell.backgroundColor;
    // 调用代理
    if (_fontDelegate && [_fontDelegate respondsToSelector:@selector(changeFontColor:)]) {
        [_fontDelegate changeFontColor:cell.backgroundColor];
    }

}




@end
