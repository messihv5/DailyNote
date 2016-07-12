//
//  WLLAssetPickerController.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAssetPickerController.h"
#import "WLLAssetPickerState.h"
#import "WLLAlbumTableViewController.h"

#define SELECTED_COUNT_KEY @"selectedCount"

@interface WLLAssetPickerController ()
@property (nonatomic, strong) WLLAssetPickerState *assetPickerState;
@property (nonatomic, readwrite) NSUInteger selectedCount;
@property (nonatomic) UIStatusBarStyle originalStatusBarStyle;

@property (nonatomic, strong) PickerDidFailBlock pickerDidFailBlock;
@end


@implementation WLLAssetPickerController

@dynamic selectedAssets;

#pragma mark - Initialization -


+ (WLLAssetPickerController *)pickerWithCompletion:(PickerDidCompleteBlock)completion
                                         canceled:(PickerDidCancelBlock)canceled {
    return [[self class] pickerWithAssetsLibrary:nil
                                      completion:completion
                                        canceled:canceled];
}


+ (WLLAssetPickerController *)pickerWithAssetsLibrary:(ALAssetsLibrary *)library
                                          completion:(PickerDidCompleteBlock)completion
                                            canceled:(PickerDidCancelBlock)canceled {
    WLLAssetPickerController *picker = [[[self class] alloc] init];
    picker.assetPickerState.assetsLibrary = library;
    picker.assetPickerState.pickerDidCompleteBlock = completion;
    picker.assetPickerState.pickerDidCancelBlock = canceled;
    return picker;
}


- (id)init {
    
    
    WLLAlbumTableViewController *albumTableViewController = [[WLLAlbumTableViewController alloc] initWithStyle:UITableViewStylePlain];
    albumTableViewController.assetPickerState = self.assetPickerState;
    
    self = [super initWithRootViewController:albumTableViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    }
    return self;
}

- (id)initWithDelegate:(id <WLLAssetPickerControllerDelegate>)delegate {
    WLLAssetPickerController *picker = [[[self class] alloc] init];
    picker.delegate = delegate;
    return picker;
}


- (WLLAssetPickerState *)assetPickerState {
    if (!_assetPickerState) {
        _assetPickerState = [[WLLAssetPickerState alloc] init];
    }
    return _assetPickerState;
}


- (void)setSelectionLimit:(NSInteger)selectionLimit {
    if (_selectionLimit != selectionLimit) {
        _selectionLimit = selectionLimit;
        self.assetPickerState.selectionLimit = _selectionLimit;
    }
}

#pragma mark - Block Setters -

- (void)setPickerCompletionBlock:(PickerDidCompleteBlock)block {
    self.assetPickerState.pickerDidCompleteBlock = block;
}


- (void)setPickerCanceledBlock:(PickerDidCancelBlock)block {
    self.assetPickerState.pickerDidCancelBlock = block;
}

- (void)setPickerFailedBlock:(PickerDidFailBlock)block {
    
    self.pickerDidFailBlock = block;
    
    __weak __typeof__(self) weakSelf = self;
    [self.assetPickerState setPickerDidFailBlock:^(NSError *error) {
        
        // Forward the error.
        if (weakSelf.pickerDidFailBlock)
            weakSelf.pickerDidFailBlock(error);
    }];
}

#pragma mark - Overrides -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof__(self) weakSelf = self;
    
    if (self.assetPickerState.pickerDidCancelBlock == nil) {
        [self.assetPickerState setPickerDidCancelBlock:^{
            if ([weakSelf.delegate conformsToProtocol:@protocol(WLLAssetPickerControllerDelegate)])
                [weakSelf.delegate performSelector:@selector(assetPickerControllerDidCancel:) withObject:weakSelf];
        }];
    }
    
    if (self.assetPickerState.pickerDidCompleteBlock == nil) {
        [self.assetPickerState setPickerDidCompleteBlock:^(NSDictionary *info) {
            if ([weakSelf.delegate conformsToProtocol:@protocol(WLLAssetPickerControllerDelegate)]) {
                NSArray *selectedAssets = [weakSelf.assetPickerState.info objectForKey:WLLAssetPickerSelectedAssets];
                [weakSelf.delegate performSelector:@selector(assetPickerController:didFinishPickingMediaWithAssets:) withObject:weakSelf withObject:selectedAssets];
            }
        }];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    [_assetPickerState addObserver:self forKeyPath:SELECTED_COUNT_KEY options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle animated:YES];
    
    [_assetPickerState removeObserver:self forKeyPath:SELECTED_COUNT_KEY];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - KVO -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![object isEqual:self.assetPickerState]) return;
    
    if ([SELECTED_COUNT_KEY isEqualToString:keyPath]) {
        
        self.selectedCount = self.assetPickerState.selectedCount;
    }
}

@end
