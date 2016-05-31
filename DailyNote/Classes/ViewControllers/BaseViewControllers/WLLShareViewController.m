//
//  WLLShareViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLShareViewController.h"

@interface WLLShareViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *shareTableView;

@property (strong, nonatomic) NSArray *data;//messi did this

@end

@implementation WLLShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //WChao did this
    self.shareTableView.delegate = self;
    self.shareTableView.dataSource = self;
    
    [self.shareTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CW_Cell"];
    
    AVUser *user = [AVUser currentUser];
    AVQuery *userQuery = [AVQuery queryWithClassName:@"Dairy"];
    [userQuery whereKey:@"belong" equalTo:user];
    [userQuery whereKeyExists:@"picture"];
    AVQuery *categoryQuery = [AVQuery queryWithClassName:@"Dairy"];
    [categoryQuery whereKey:@"Category" equalTo:@"第一类"];
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[userQuery, categoryQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.data = objects;
        [self.shareTableView reloadData];
    }];;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW_Cell"
                                                            forIndexPath:indexPath];
    AVObject *object = self.data[indexPath.row];
    NSArray *array = [object objectForKey:@"picture"];
    AVFile *file = array[0];
    [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
        NSData *data = [file getData];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = image;
            cell.textLabel.text = [object objectForKey:@"content"];
        });
    }];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
