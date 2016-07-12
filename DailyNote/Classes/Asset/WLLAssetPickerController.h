//
//  WLLAssetPickerController.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

extern NSString *const WLLAssetPickerAssetsOwningLibraryInstance;
extern NSString *const WLLAssetPickerURLsForSelectedAssets;
extern NSString *const WLLAssetPickerSelectedAssets;

typedef void (^PickerDidCompleteBlock)(NSDictionary *info);
typedef void (^PickerDidCancelBlock)(void);
typedef void (^PickerDidFailBlock)(NSError *error);

@protocol WLLAssetPickerControllerDelegate;

@interface WLLAssetPickerController : UINavigationController

@property (nonatomic, readonly) NSArray *selectedAssets;
@property (nonatomic, readonly) NSUInteger selectedCount;


@property (nonatomic, readwrite) NSInteger selectionLimit;

/**
 Creates a picker controller with an existing ALAssetsLibrary instance.
 
 @param library An instance of ALAssetsLibrary.
 @param completion A block to be executed when the picker controller finishes successfully. This block has not return value and takes a single argument: an NSDictionary containing the selection information. The keys for this dictionary are listed in “Selection Info Keys”
 @param canceled test
 
 */
+ (WLLAssetPickerController *)pickerWithAssetsLibrary:(ALAssetsLibrary *)library
                                          completion:(PickerDidCompleteBlock)completion
                                            canceled:(PickerDidCancelBlock)canceled;

+ (WLLAssetPickerController *)pickerWithCompletion:(PickerDidCompleteBlock)completion
                                         canceled:(PickerDidCancelBlock)canceled;

- (id)initWithDelegate:(id<WLLAssetPickerControllerDelegate>)delegate;

- (void)setPickerCompletionBlock:(PickerDidCompleteBlock)block;
- (void)setPickerCanceledBlock:(PickerDidCancelBlock)block;
- (void)setPickerFailedBlock:(PickerDidFailBlock)block;

@end


@protocol WSAssetPickerControllerDelegate <UINavigationControllerDelegate>

- (void)assetPickerControllerDidCancel:(WLLAssetPickerController *)sender;


- (void)assetPickerController:(WLLAssetPickerController *)sender didFinishPickingMediaWithAssets:(NSArray *)assets;

@end