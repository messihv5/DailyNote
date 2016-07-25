//
//  WLLMoodView.m
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLMoodView.h"
#import "WLLWeatherCell.h"

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
    
    WLLWeatherCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    if (indexPath.row == 0) {
        
        UIImage *image = [UIImage imageNamed:@"mood"];
        UIImage *highlightedImage = [UIImage imageNamed:@"label2"];
        
        cell.weatherIcon = [[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage];
        
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLLWeatherCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];

    NSLog(@"%@", cell.weatherIcon);
    
}

#pragma mark - awakeFromNib
- (void)awakeFromNib {
    CGRect frame = CGRectMake(0, kHeight, kWidth, kHeight*0.4);
    self.frame = frame;
    
    [self.weatherIcon registerClass:[WLLWeatherCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.weatherIcon.dataSource = self;
    self.weatherIcon.delegate = self;
    
    // cell 布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    layout.itemSize = CGSizeMake(65, 40);
    [self.weatherIcon setCollectionViewLayout:layout];
}

#pragma mark - 分享日记
- (IBAction)shareNoteAction:(UISwitch *)sender {
    
}


@end
