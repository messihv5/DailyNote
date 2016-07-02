//
//  WChaoShareCellTableViewCell.h
//  DailyNote
//
//  Created by Messi on 16/6/1.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WChaoShareCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *theTextLable;
@property (weak, nonatomic) IBOutlet UILabel *starNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
