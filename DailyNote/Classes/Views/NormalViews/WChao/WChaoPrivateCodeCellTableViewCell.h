//
//  WChaoPrivateCodeCellTableViewCell.h
//  DailyNote
//
//  Created by Messi on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WChaoPrivateCodeCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privateCodeSwith;

@end
