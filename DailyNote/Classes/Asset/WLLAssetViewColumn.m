//
//  WLLAssetViewColumn.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAssetViewColumn.h"
#import "WLLAssetWrapper.h"

@interface WLLAssetViewColumn ()
@property (nonatomic, weak) UIImageView *selectedView;
@property (nonatomic, strong) BOOL (^shouldSelectItem)(NSInteger column);
@end


@implementation WLLAssetViewColumn

@synthesize column = _column;
@synthesize selected = _selected;
@synthesize selectedView = _selectedView;


#pragma mark - Initialization

#define ASSET_VIEW_FRAME CGRectMake(0, 0, 75, 75)

+ (WLLAssetViewColumn *)assetViewWithImage:(UIImage *)thumbnail {
    WLLAssetViewColumn *assetView = [[WLLAssetViewColumn alloc] initWithImage:thumbnail];
    
    return assetView;
}

- (id)initWithImage:(UIImage *)thumbnail {
    if ((self = [super initWithFrame:ASSET_VIEW_FRAME])) {
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:ASSET_VIEW_FRAME];
        assetImageView.contentMode = UIViewContentModeScaleToFill;
        assetImageView.image = thumbnail;
        [self addSubview:assetImageView];
    }
    return self;
}

- (void)setShouldSelectItemBlock:(BOOL(^)(NSInteger column))shouldSelectItemBlock {
    self.shouldSelectItem = shouldSelectItemBlock;
}

#pragma mark - Setters/Getters

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        
        [self willChangeValueForKey:@"isSelected"];
        _selected = selected;
        [self didChangeValueForKey:@"isSelected"];
        
        self.selectedView.hidden = !_selected;
    }
    [self setNeedsDisplay];
}

#define SELECTED_IMAGE @"daily.png"

- (UIImageView *)selectedView {
    if (!_selectedView) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SELECTED_IMAGE]];
        imageView.hidden = YES;
        [self addSubview:imageView];
        
        _selectedView = imageView;
    }
    return _selectedView;
}


#pragma mark - Actions

- (void)userDidTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        BOOL canSelect = YES;
        if (self.shouldSelectItem)
            canSelect = self.shouldSelectItem(self.column);
        
        self.selected = (canSelect && (self.selected == NO));
    }
}

@end
