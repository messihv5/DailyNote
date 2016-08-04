//
//  WLLAssetPickerState.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAssetPickerState.h"
#import "WLLAssetWrapper.h"

NSString *const WLLAssetPickerAssetsOwningLibraryInstance = @"WLLAssetPickerAssetsOwningLibraryInstance";
NSString *const WLLAssetPickerURLsForSelectedAssets       = @"WLLAssetPickerURLsForSelectedAssets";
NSString *const WLLAssetPickerSelectedAssets              = @"WLLAssetPickerSelectedAssets";

@interface WLLAssetPickerState ()

@property (nonatomic, strong) NSMutableOrderedSet *selectedAssetsSet;

@end

@implementation WLLAssetPickerState

@dynamic info;

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSDictionary *)info {
    NSArray *selectedAssets = self.selectedAssetsSet.array.copy;
    NSArray *urls = [selectedAssets valueForKeyPath:@"defaultRepresentation.url"];
    
    return
    @{
      WLLAssetPickerAssetsOwningLibraryInstance : self.assetsLibrary,
      WLLAssetPickerSelectedAssets : selectedAssets,
      WLLAssetPickerURLsForSelectedAssets : urls,
      };
}

- (NSMutableOrderedSet *)selectedAssetsSet {
    if (!_selectedAssetsSet) {
        _selectedAssetsSet = [NSMutableOrderedSet orderedSet];
    }
    return _selectedAssetsSet;
}

- (void)clearSelectedAssets {
    [self.selectedAssetsSet removeAllObjects];
    self.selectedCount = 0;
}

- (void)sessionCanceled {
    if (self.pickerDidCancelBlock)
        self.pickerDidCancelBlock();
}

- (void)sessionCompleted {
    if (self.pickerDidCompleteBlock)
        self.pickerDidCompleteBlock(self.info);
}

- (void)sessionFailed:(NSError *)error {
    if (self.pickerDidFailBlock)
        self.pickerDidFailBlock(error);
}

- (void)changeSelectionState:(BOOL)selected forAsset:(ALAsset *)asset {
    if (selected) {
        [self.selectedAssetsSet addObject:asset];
    } else {
        [self.selectedAssetsSet removeObject:asset];
    }
    
    // Update the observable count property.
    self.selectedCount = [self.selectedAssetsSet count];
}

@end