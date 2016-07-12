//
//  WLLAssetViewColumn.h
//  LBCAssetPicker
//
//  Created by CapLee on 16/7/7.
//  Copyright © 2016年 CapLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLLAssetViewColumn : UIView

@property (nonatomic) NSUInteger column;
@property (nonatomic, getter=isSelected) BOOL selected;

+ (WLLAssetViewColumn *)assetViewWithImage:(UIImage *)thumbnail;

- (id)initWithImage:(UIImage *)thumbnail;

- (void)setShouldSelectItemBlock:(BOOL(^)(NSInteger column))shouldSelectItemBlock;

@end