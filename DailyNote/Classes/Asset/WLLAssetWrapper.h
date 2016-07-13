//
//  WLLAssetWrapper.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface WLLAssetWrapper : NSObject

@property (nonatomic, strong, readonly) ALAsset *asset;
@property (nonatomic, getter = isSelected) BOOL selected;

- (id)initWithAsset:(ALAsset *)asset;

@end
