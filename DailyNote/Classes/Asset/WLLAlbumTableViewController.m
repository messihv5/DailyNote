//
//  WLLAlbumTableViewController.m
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import "WLLAlbumTableViewController.h"
#import "WLLAssetPickerState.h"
#import "WLLAssetTableViewController.h"

@interface WLLAlbumTableViewController ()

@property (nonatomic, strong) NSMutableArray *assetGroups; // Data source (all groups of assets).

@end

@implementation WLLAlbumTableViewController

#pragma mark - Getters

- (NSMutableArray *)assetGroups
{
    if (!_assetGroups) {
        _assetGroups = [NSMutableArray array];
    }
    return _assetGroups;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.wantsFullScreenLayout = YES;
    
    [self.assetPickerState clearSelectedAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Loading…";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelButtonAction:)];
    
    [self.assetPickerState.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.title = @"Albums";
                [self.tableView reloadData];
            });
            return;
        }
        
        [self.assetGroups addObject:group];
        
    } failureBlock:^(NSError *error) {
        
        [self.assetPickerState sessionFailed:error];
    }];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma  mark - Actions

- (void)cancelButtonAction:(id)sender {
    [self.assetPickerState sessionCanceled];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WLLAlbumCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // TODO: Make this a delegate choice.
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [group valueForProperty:ALAssetsGroupPropertyName], [group numberOfAssets]];
    cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // TODO: Make this a delegate choice.
    
    WLLAssetTableViewController *assetTableViewController = [[WLLAssetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    assetTableViewController.assetPickerState = self.assetPickerState;
    assetTableViewController.assetsGroup = group;
    
    [self.navigationController pushViewController:assetTableViewController animated:YES];
}

#define ROW_HEIGHT 57.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

@end
