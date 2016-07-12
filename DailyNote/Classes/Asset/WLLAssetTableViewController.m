//
//  WLLAssetTableViewController.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//
#import "WLLAssetTableViewController.h"
#import "WLLAssetPickerState.h"
#import "WLLAssetsCell.h"
#import "WLLAssetWrapper.h"

#define ASSET_WIDTH_WITH_PADDING 79.0f

@interface WLLAssetTableViewController () <WLLAssetsTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *fetchedAssets;
@property (nonatomic, readonly) NSInteger assetsPerRow;
@end


@implementation WLLAssetTableViewController

@synthesize assetPickerState = _assetPickerState;
@synthesize assetsGroup = _assetsGroup;
@synthesize fetchedAssets = _fetchedAssets;
@synthesize assetsPerRow =_assetsPerRow;


#pragma mark - View Lifecycle

#define TABLEVIEW_INSETS UIEdgeInsetsMake(2, 0, 2, 0);

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.wantsFullScreenLayout = YES;
    
    if (self.navigationController.toolbarItems.count > 0) {
        self.toolbarItems = self.navigationController.toolbarItems;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.navigationController.toolbarItems.count > 0) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    self.navigationItem.title = @"Loading";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonAction:)];
    
    
    
    self.tableView.contentInset = TABLEVIEW_INSETS;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.allowsSelection = NO;
    
    
    [self fetchAssets];
}


#pragma mark - Getters

- (NSMutableArray *)fetchedAssets {
    if (!_fetchedAssets) {
        _fetchedAssets = [NSMutableArray array];
    }
    return _fetchedAssets;
}

- (NSInteger)assetsPerRow {
    return MAX(1, (NSInteger)floorf(self.tableView.contentSize.width / ASSET_WIDTH_WITH_PADDING));
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}


#pragma mark - Fetching Code

- (void)fetchAssets {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (!result || index == NSNotFound) {

                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    self.navigationItem.title = [NSString stringWithFormat:@"%@", [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
                });
                
                return;
            }
            
            WLLAssetWrapper *assetWrapper = [[WLLAssetWrapper alloc] initWithAsset:result];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.fetchedAssets addObject:assetWrapper];
                
            });
            
        }];
    });
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

#pragma mark - Actions

- (void)doneButtonAction:(id)sender {
    [self.assetPickerState sessionCompleted];
}


#pragma mark - WLLAssetsTableViewCellDelegate Methods

- (BOOL)assetsTableViewCell:(WLLAssetsCell *)cell shouldSelectAssetAtColumn:(NSUInteger)column {
    return (self.assetPickerState.selectedCount < self.assetPickerState.selectionLimit);
}

- (void)assetsTableViewCell:(WLLAssetsCell *)cell didSelectAsset:(BOOL)selected atColumn:(NSUInteger)column {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSUInteger assetIndex = indexPath.row * self.assetsPerRow + column;
    
    WLLAssetWrapper *assetWrapper = [self.fetchedAssets objectAtIndex:assetIndex];
    assetWrapper.selected = selected;
    
    [self.assetPickerState changeSelectionState:selected forAsset:assetWrapper.asset];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (self.fetchedAssets.count + self.assetsPerRow - 1) / self.assetsPerRow;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)indexPath {
    NSRange assetRange;
    assetRange.location = indexPath.row * self.assetsPerRow;
    assetRange.length = self.assetsPerRow;
    
    if (assetRange.length > self.fetchedAssets.count - assetRange.location) {
        assetRange.length = self.fetchedAssets.count - assetRange.location;
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:assetRange];
    
    return [self.fetchedAssets objectsAtIndexes:indexSet];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AssetCellIdentifier = @"WLLAssetCell";
    WLLAssetsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AssetCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[WLLAssetsCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:AssetCellIdentifier];
    } else {
        
        cell.cellAssetViews = [self assetsForIndexPath:indexPath];
    }
    cell.delegate = self;
    
    return cell;
}


#pragma mark - Table view delegate

#define ROW_HEIGHT 79.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

@end
