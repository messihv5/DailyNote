//
//  WLLAssetsCell.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAssetsCell.h"
#import "WLLAssetWrapper.h"
#import "WLLAssetViewColumn.h"

@implementation WLLAssetsCell

@synthesize delegate = _delegate;
@synthesize cellAssetViews = _cellAssetViews;

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        
        self.cellAssetViews = assets;
    }
    
    return self;
}

- (void)stopObserving {
    
    for (WLLAssetViewColumn *assetViewColumn in self.cellAssetViews) {
        
        [assetViewColumn removeObserver:self forKeyPath:@"isSelected"];
        
        [assetViewColumn removeFromSuperview];
    }
}

- (void)setCellAssetViews:(NSArray *)assets {
    
    
    [self stopObserving];
    
    
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[assets count]];
    
    for (WLLAssetWrapper *assetWrapper in assets) {
        
        WLLAssetViewColumn *assetViewColumn = [[WLLAssetViewColumn alloc] initWithImage:[UIImage imageWithCGImage:assetWrapper.asset.thumbnail]];
        assetViewColumn.column = [assets indexOfObject:assetWrapper];
        assetViewColumn.selected = assetWrapper.isSelected;
        
        __weak __typeof__(self) weakSelf = self;
        [assetViewColumn setShouldSelectItemBlock:^BOOL(NSInteger column) {
            return [weakSelf.delegate assetsTableViewCell:weakSelf shouldSelectAssetAtColumn:column];
        }];
        
        
        [assetViewColumn addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew context:NULL];
        
        [columns addObject:assetViewColumn];
    }
    
    _cellAssetViews = columns;
}

#define ASSET_VIEW_FRAME CGRectMake(0, 0, 75, 75)
#define ASSET_VIEW_PADDING 4

- (void)layoutSubviews {
    
    int assetsPerRow = self.frame.size.width / ASSET_VIEW_FRAME.size.width;
    float containerWidth = assetsPerRow * ASSET_VIEW_FRAME.size.width + (assetsPerRow - 1) * ASSET_VIEW_PADDING;
    
    
    CGRect containerFrame;
    containerFrame.origin.x = (self.frame.size.width - containerWidth) / 2;
    containerFrame.origin.y = (self.frame.size.height - ASSET_VIEW_FRAME.size.height) / 2;
    containerFrame.size.width = containerWidth;
    containerFrame.size.height = ASSET_VIEW_FRAME.size.height;
    
    
    UIView *assetsContainerView = [[UIView alloc] initWithFrame:containerFrame];
    assetsContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect frame = ASSET_VIEW_FRAME;
    
    for (WLLAssetViewColumn *assetView in self.cellAssetViews) {
        
        assetView.frame = frame;
        
        [assetsContainerView addSubview:assetView];
        
        
        frame.origin.x = frame.origin.x + frame.size.width + ASSET_VIEW_PADDING;
    }
    
    [self addSubview:assetsContainerView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isMemberOfClass:[WLLAssetViewColumn class]]) {
        
        WLLAssetViewColumn *column = (WLLAssetViewColumn *)object;
        if ([self.delegate respondsToSelector:@selector(assetsTableViewCell:didSelectAsset:atColumn:)]) {
            
            [self.delegate assetsTableViewCell:self didSelectAsset:column.isSelected atColumn:column.column];
        }
    }
}

- (void)dealloc {
    [self stopObserving];
}



@end
