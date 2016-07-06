//
//  WLLCalendarView.m
//  DailyNote
//
//  Created by CapLee on 16/7/3.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLCalendarView.h"
#import "WLLCalendarCell.h"
#import "NSDate+WLLDate.h"

@interface WLLCalendarView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
/* 前一月 */
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
/* 日期 */
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
/* 后一月 */
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
/* 显示日历 */
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
/* 周数组 */
@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic , strong) UIView *mask;

@end

static NSString *const WLLCalendarCellIdentifier = @"calendar_cell";

@implementation WLLCalendarView

// 添加行为
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // 添加轻扫行为
    [self addSwipe];
    // 显示日历
    [self show];
}

- (void)awakeFromNib {
    // 注册
    [_collectionView registerClass:[WLLCalendarCell class] forCellWithReuseIdentifier:WLLCalendarCellIdentifier];
    // 周数组初始化
    _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
}

// 自定义日历布局
- (void)customsView {
    // 每日宽高为日历宽高的七分之一
    CGFloat itemWidth = _collectionView.width / 7;
    CGFloat itemHeight = _collectionView.height / 7;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 无间距
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // item大小
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    // 最小行列间距
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:NO];
}

// 设置日期
- (void)setDate:(NSDate *)date {
    _date = date;
    // 显示年月
    [_monthAndYearLabel setText:[NSString stringWithFormat:@"%.2ld-%li",
                                 [self.date month:date],[self.date year:date]]];
    NSLog(@"%ld", [self.date month:date]);
    [_collectionView reloadData];
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _weekDayArray.count;
    } else {
        return 42;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLLCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WLLCalendarCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {   // 如果section为0 显示周
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        [cell.dateLabel setTextColor:[UIColor redColor]];
    } else {    // 显示日
        // 本月的天数
        NSInteger daysInThisMonth = [self.date totaldaysInMonth:_date];
        // 本月第一天
        NSInteger firstWeekday = [self.date firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i < firstWeekday) {    // 如果item的row小于第一天日期, 不显示日
            [cell.dateLabel setText:@""];
            
        } else if (i > firstWeekday + daysInThisMonth - 1) {    // 相反, 相同
            [cell.dateLabel setText:@""];
        } else {    // 如果在之间 显示日期
            
            /**
             *  i(0~41), firstWeekday(0~30/29/27/28)
             *  第一天, 0 - firstWeekday + 1 = 0 - 0 + 1 = 1
             *
             */
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",day]];
            [cell.dateLabel setTextColor:[UIColor blueColor]];
            
            // 本月
            if ([_today isEqualToDate:_date]) {    // 如果是当天
                if (day == [self.date day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor grayColor]];
                } else if (day > [self.date day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor cyanColor]];
                }
            } else if ([_today compare:_date] == NSOrderedAscending) {
                [cell.dateLabel setTextColor:[UIColor blueColor]];
            }
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [self.date totaldaysInMonth:_date];
        NSInteger firstWeekday = [self.date firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [self.date day:_date]) {
                    return YES;
                }
            } else if ([_today compare:_date] == NSOrderedDescending) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self.date firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calendarBlock) {
        self.calendarBlock(day, [comp month], [comp year]);
    }
}

#pragma - 前一月和下一月
- (IBAction)previouseAction:(UIButton *)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.date = [self.date lastMonth:self.date];
    } completion:nil];
}

- (IBAction)nexAction:(UIButton *)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.date = [self.date nextMonth:self.date];
    } completion:nil];
}

#pragma mark - 显示日历
+ (instancetype)showOnView:(UIView *)view {
    WLLCalendarView *calendarView = [WLLCalendarView viewFromXib];
    calendarView.mask = [[UIView alloc] initWithFrame:view.bounds];
    calendarView.mask.backgroundColor = [UIColor blackColor];
    calendarView.mask.alpha = 0.3;
    [view addSubview:calendarView.mask];
    [view addSubview:calendarView];
    return calendarView;
}

// 显示日历
- (void)show {
    self.transform = CGAffineTransformTranslate(self.transform, 0, - self.height);
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [self customsView];
    }];
}

// 隐藏
- (void)hide {
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformTranslate(self.transform, 0, - self.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}

// 添加轻扫手势
- (void)addSwipe {
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nexAction:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
}

@end
