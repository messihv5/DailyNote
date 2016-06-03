//
//  WLLShareViewController.m
//  DailyNote
//
//  Created by Messi on 16/5/24.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLShareViewController.h"
#import "WChaoShareCellTableViewCell.h"

@interface WLLShareViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *shareTableView;
@property (strong, nonatomic) NSArray *data;//messi did this
@property (strong, nonatomic) NSIndexPath *parameterIndexPath;
//存储点赞的用户
@property (strong, nonatomic) NSMutableArray *mutableData;

@end

@implementation WLLShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //WChao did this
    self.shareTableView.delegate = self;
    self.shareTableView.dataSource = self;
    
//    [self.shareTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CW_Cell"];
    [self.shareTableView registerNib:[UINib nibWithNibName:@"WChaoShareCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CW_Cell"];
    
    
    //查询数据库中的日记，并保存在数组中，然后刷新tableView
//    AVUser *user = [AVUser currentUser];
    AVQuery *userQuery = [AVQuery queryWithClassName:@"Dairy"];
//    [userQuery whereKey:@"belong" equalTo:user];
    [userQuery whereKeyExists:@"picture"];
    [userQuery whereKey:@"isPrivate" equalTo:@"public"];
    AVQuery *categoryQuery = [AVQuery queryWithClassName:@"Dairy"];
    [categoryQuery whereKey:@"Category" equalTo:@"第一类"];
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[userQuery, categoryQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.data = objects;
        [self.shareTableView reloadData];
    }];;
    
}

//懒加载
- (NSMutableArray *)mutableData {
    if (_mutableData == nil) {
        _mutableData = [NSMutableArray array];
    }
    return _mutableData;
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WChaoShareCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CW_Cell"
                                                            forIndexPath:indexPath];
    AVObject *object = self.data[indexPath.row];
    NSArray *array = [object objectForKey:@"picture"];
    AVFile *file = array[0];
    [AVFile getFileWithObjectId:file.objectId withBlock:^(AVFile *file, NSError *error) {
        NSData *data = [file getData];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.headImageView.image = image;
            cell.theTextLable.text = [object objectForKey:@"content"];
            cell.starNumberLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"starNumber"]];
            [cell.starButton setBackgroundImage:[UIImage imageNamed:@"smallStar"] forState:UIControlStateNormal];
            [cell.starButton addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
            self.parameterIndexPath = indexPath;
            NSMutableArray *array = [NSMutableArray array];
            [self.mutableData addObject:array];
        });
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)starAction:(UIButton *)sender {
    
    //通过cell上的按钮获取点击的cell的indexPath
    NSIndexPath *indexPath = [self.shareTableView indexPathForCell:(WChaoShareCellTableViewCell *)[[sender superview] superview]];
    
    //检查dairy数组，如果含有该用户，就return，不能进行点赞
    
    AVObject *dairy = self.data[indexPath.row];

    NSMutableArray *array = [dairy objectForKey:@"staredUser"];
    if ([array containsObject:[AVUser currentUser]]) {
        return;
    }
    
    //点赞后点赞数字加1
    UIView *contentView = sender.superview;
    NSArray *viewArray =  contentView.subviews;
    for (UIView *view in viewArray) {
        if (view.tag == 1) {
            UILabel *label = (UILabel *)view;
            label.text = [NSString stringWithFormat:@"%ld", [label.text integerValue] + 1];
        }
    }
    
    //日记里面保存的点赞数字也加1
    NSNumber *num = [dairy objectForKey:@"starNumber"];
    num = [NSNumber numberWithInteger:[num integerValue] + 1];
    [dairy setObject:num forKey:@"starNumber"];
    
    //把点赞的用户添加到数组中，以便下次点赞时进行判断
    AVUser *user = [AVUser currentUser];
    
    //把点赞的用户添加到dairy的数组中保存
    [array addObject:user];
    
    dairy.fetchWhenSave = YES;
    [dairy setObject:array forKey:@"staredUser"];
    [dairy saveInBackground];

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
