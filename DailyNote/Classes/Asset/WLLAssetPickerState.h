//
//  WLLAssetPickerState.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface WLLAssetPickerState : NSObject

@property (nonatomic, strong) void (^pickerDidCompleteBlock)(NSDictionary *info);
@property (nonatomic, strong) void (^pickerDidCancelBlock)(void);
@property (nonatomic, strong) void (^pickerDidFailBlock)(NSError *error);

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, readonly) NSDictionary *info;
@property (nonatomic, readwrite) NSUInteger selectedCount;
@property (nonatomic, readwrite) NSInteger selectionLimit;

- (void)clearSelectedAssets;

- (void)sessionCanceled;
- (void)sessionCompleted;
- (void)sessionFailed:(NSError *)error;

- (void)changeSelectionState:(BOOL)selected forAsset:(ALAsset *)asset;

@end
