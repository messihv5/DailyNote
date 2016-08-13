//
//  WChaoShareCellTableViewCell.m
//  DailyNote
//
//  Created by Messi on 16/6/1.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WChaoShareCellTableViewCell.h"

@implementation WChaoShareCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.contentView.x = 10;
    self.contentView.y = 10;
    self.contentView.width = self.width - 20;
    self.contentView.height = self.height - 20;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor cyanColor];
    self.contentView.layer.cornerRadius= 5;
}

@end
