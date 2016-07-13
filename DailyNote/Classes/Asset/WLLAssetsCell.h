//
//  WLLAssetsCell.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLLAssetsTableViewCellDelegate;

@interface WLLAssetsCell : UITableViewCell

@property (nonatomic, strong) NSArray *cellAssetViews;

@property (nonatomic, weak) id <WLLAssetsTableViewCellDelegate> delegate;

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier;

@end

@protocol WLLAssetsTableViewCellDelegate <NSObject>

- (BOOL)assetsTableViewCell:(WLLAssetsCell *)cell shouldSelectAssetAtColumn:(NSUInteger)column;

- (void)assetsTableViewCell:(WLLAssetsCell *)cell didSelectAsset:(BOOL)selected atColumn:(NSUInteger)column;

@end