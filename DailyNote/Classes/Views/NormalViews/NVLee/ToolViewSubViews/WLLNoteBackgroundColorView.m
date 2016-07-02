//
//  WLLNoteBackgroundColorView.m
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLNoteBackgroundColorView.h"
#import "WLLMyColor.h"

@interface WLLNoteBackgroundColorView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@end

@implementation WLLNoteBackgroundColorView

- (void)awakeFromNib {
    self.dataSource = self;
    self.delegate = self;
    
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"item"];
    
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    return myColor.backgroundColor.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    item.backgroundColor = myColor.backgroundColor[indexPath.row];
    
    return item;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kWidth*0.305, kHeight*0.3-20);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(itemEdgesInset, itemEdgesInset, itemEdgesInset, itemEdgesInset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    
    WLLMyColor *myColor = [[WLLMyColor alloc] init];
    item.backgroundColor = myColor.backgroundColor[indexPath.row];
    
    if (_colorDelegate && [_colorDelegate respondsToSelector:@selector(changeNoteBackgroundColor:)]) {
        [_colorDelegate changeNoteBackgroundColor:item.backgroundColor];
    }
}






@end
