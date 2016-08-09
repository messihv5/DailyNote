//
//  WLLAssetTableViewController.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

@class WLLAssetPickerState;

@interface WLLAssetTableViewController : UITableViewController

@property (nonatomic, weak) WLLAssetPickerState *assetPickerState;
@property (nonatomic, weak) ALAssetsGroup *assetsGroup; // Data source (a specific, filtered, group of assets).
@property (assign, nonatomic) NSInteger numberOfPictures;

@end