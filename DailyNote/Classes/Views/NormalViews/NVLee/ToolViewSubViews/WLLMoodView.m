//
//  WLLMoodView.m
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLMoodView.h"

@interface WLLMoodView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;
@property (weak, nonatomic) IBOutlet UICollectionView *weatherIcon;

@end

@implementation WLLMoodView

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

static NSString *const reuseIdentifier = @"weather_item";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.backgroundView = (UIView *)[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"label2"]];
        
    } else {
        
        cell.backgroundColor = [UIColor redColor];
    }
    
    [cell.backgroundView sizeToFit];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    
    UIView *view = [[UIView alloc] init];
    view = cell.backgroundView;
    NSLog(@"%@", cell.backgroundView);
    
}

#pragma mark - awakeFromNib
- (void)awakeFromNib {
    CGRect frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);
    self.frame = frame;
    
    [self.weatherIcon registerClass:[UICollectionViewCell class]
         forCellWithReuseIdentifier:reuseIdentifier];
    
    self.weatherIcon.dataSource = self;
    self.weatherIcon.delegate = self;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    layout.itemSize = CGSizeMake(65, 40);
    [self.weatherIcon setCollectionViewLayout:layout];
}

#pragma mark - 分享日记
- (IBAction)shareNoteAction:(UISwitch *)sender {
    
}


@end
