//
//  WLLMoodView.m
//  DailyNote
//
//  Created by CapLee on 16/6/8.
//  Copyright © 2016年 Messi. All rights reserved.
//

#import "WLLMoodView.h"
#import "WLLWeatherCell.h"


@interface WLLMoodView ()

@property (weak, nonatomic) IBOutlet UIImageView *sunny;
@property (weak, nonatomic) IBOutlet UIImageView *sunnyInterval;
@property (weak, nonatomic) IBOutlet UIImageView *cloudy;
@property (weak, nonatomic) IBOutlet UIImageView *rainy;
@property (weak, nonatomic) IBOutlet UIImageView *moon;
@property (weak, nonatomic) IBOutlet UIImageView *thunder;
@property (weak, nonatomic) IBOutlet UIImageView *snow;
@property (weak, nonatomic) IBOutlet UIImageView *fog;

@end

@implementation WLLMoodView


- (void)awakeFromNib {
    self.numberOfImage = 1000;
    
    UITapGestureRecognizer *sunnyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.sunny addGestureRecognizer:sunnyTap];
    
    UITapGestureRecognizer *sunnyIntervalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.sunnyInterval addGestureRecognizer:sunnyIntervalTap];
    
    UITapGestureRecognizer *cloudyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.cloudy addGestureRecognizer:cloudyTap];
    
    UITapGestureRecognizer *rainyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.rainy addGestureRecognizer:rainyTap];
    
    UITapGestureRecognizer *moonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.moon addGestureRecognizer:moonTap];
    
    UITapGestureRecognizer *thunderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.thunder addGestureRecognizer:thunderTap];
    
    UITapGestureRecognizer *snowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.snow addGestureRecognizer:snowTap];
    
    UITapGestureRecognizer *fogTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeatherAction:)];
    [self.fog addGestureRecognizer:fogTap];
}


- (void)selectedWeatherAction:(UITapGestureRecognizer *)tap {

    switch (tap.view.tag) {
        case 0: {   // sunny
            [self selectedImageAnimation:_sunny];
            // 如果已经有选中的天气, 在改选其他的天气前
            if (self.numberOfImage == 0) {
                if (self.isSelected == NO) {
                    self.sunny.image = [UIImage imageNamed:@"sunny_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.sunny.image = [UIImage imageNamed:@"sunny"];
                self.isSelected = NO;
            } else {
                self.sunny.image = [UIImage imageNamed:@"sunny_selected"];
                self.isSelected = YES;
            }
            
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            
            self.numberOfImage = 0;
            break;
        }
        case 1: {  // sunnyInterval
            [self selectedImageAnimation:_sunnyInterval];
            if (self.numberOfImage == 1) {
                if (self.isSelected == NO) {
                    self.sunnyInterval.image = [UIImage imageNamed:@"sunny_interval_selected"];
                    self.isSelected = YES;
                    return;
                }
                
                self.sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
                self.isSelected = NO;
            } else {
                self.sunnyInterval.image = [UIImage imageNamed:@"sunny_interval_selected"];
                self.isSelected = YES;
            }
            
            _sunny.image = [UIImage imageNamed:@"sunny"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            
            self.numberOfImage = 1;
            break;
        }
        case 2:    // cloudy
            [self selectedImageAnimation:_cloudy];
            if (self.numberOfImage == 2) {
                if (self.isSelected == NO) {
                    self.cloudy.image = [UIImage imageNamed:@"cloudy_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.cloudy.image = [UIImage imageNamed:@"cloudy"];
                self.isSelected = NO;
            } else {
                self.cloudy.image = [UIImage imageNamed:@"cloudy_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            
            self.numberOfImage = 2;
            break;
        case 3:    // rainy
            [self selectedImageAnimation:_rainy];
            if (self.numberOfImage == 3) {
                if (self.isSelected == NO) {
                    self.rainy.image = [UIImage imageNamed:@"rainy_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.rainy.image = [UIImage imageNamed:@"rainy"];
                self.isSelected = NO;
            } else {
                self.rainy.image = [UIImage imageNamed:@"rainy_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            
            self.numberOfImage = 3;
            break;
        case 4:   // moon
            [self selectedImageAnimation:_moon];

            if (self.numberOfImage == 4) {
                if (self.isSelected == NO) {
                    self.moon.image = [UIImage imageNamed:@"moon_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.moon.image = [UIImage imageNamed:@"moon"];
                self.isSelected = NO;
            } else {
                self.moon.image = [UIImage imageNamed:@"moon_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            
            self.numberOfImage = 4;
            break;
        case 5:    // thunder
            [self selectedImageAnimation:_thunder];

            if (self.numberOfImage == 5) {
                if (self.isSelected == NO) {
                    self.thunder.image = [UIImage imageNamed:@"thunder_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.thunder.image = [UIImage imageNamed:@"thunder"];
                self.isSelected = NO;
            } else {
                self.thunder.image = [UIImage imageNamed:@"thunder_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _fog.image = [UIImage imageNamed:@"fog"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            
            self.numberOfImage = 5;
            break;
        case 6:    // snow
            [self selectedImageAnimation:_snow];

            if (self.numberOfImage == 6) {
                if (self.isSelected == NO) {
                    self.snow.image = [UIImage imageNamed:@"snow_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.snow.image = [UIImage imageNamed:@"snow"];
                self.isSelected = NO;
            } else {
                self.snow.image = [UIImage imageNamed:@"snow_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _fog.image = [UIImage imageNamed:@"fog"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            
            self.numberOfImage = 6;
            break;
        case 7:    // fog
            [self selectedImageAnimation:_fog];

            if (self.numberOfImage == 7) {
                if (self.isSelected == NO) {
                    self.fog.image = [UIImage imageNamed:@"fog_selected"];
                    self.isSelected = YES;
                    return;
                }
                self.fog.image = [UIImage imageNamed:@"fog"];
                self.isSelected = NO;
            } else {
                self.fog.image = [UIImage imageNamed:@"fog_selected"];
                self.isSelected = YES;
            }

            _sunny.image = [UIImage imageNamed:@"sunny"];
            _sunnyInterval.image = [UIImage imageNamed:@"sunny_interval"];
            _moon.image = [UIImage imageNamed:@"moon"];
            _thunder.image = [UIImage imageNamed:@"thunder"];
            _snow.image = [UIImage imageNamed:@"snow"];
            _cloudy.image = [UIImage imageNamed:@"cloudy"];
            _rainy.image = [UIImage imageNamed:@"rainy"];
            self.numberOfImage = 7;
            break;
    }
    
}



- (void)selectedImageAnimation:(UIImageView *)imageView {
    [UIView animateWithDuration:0.5 animations:^{
        
        imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        CGAffineTransform transform = imageView.transform;
        imageView.transform = CGAffineTransformScale(transform, 1.2, 1.2);
        
    }];
    
    [UIView animateWithDuration:1 animations:^{
        
        imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transform = imageView.transform;
        imageView.transform = CGAffineTransformScale(transform, 1.0, 1.0);
        
    }];
}

@end
