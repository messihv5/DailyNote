//
//  EditNoteViewController.m
//  DailyNote
//
//  Created by CapLee on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()

@end

@implementation EditNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"嘿嘿嘿";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)saveNote:(UIBarButtonItem *)button {
    
    NSLog(@"%s", __func__);
}

- (void)cancel {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
