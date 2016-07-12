//
//  WLLAssetWrapper.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAssetWrapper.h"

@implementation WLLAssetWrapper

@synthesize asset = _asset;
@synthesize selected = _selected;

- (id)initWithAsset:(ALAsset *)asset
{
    if ((self = [super init])) {
        _asset = asset;
    }
    return self;
}

@end
