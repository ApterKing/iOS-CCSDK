//
//  CCNavigationBarController.m
//  CCSDK
//
//  Created by wangcong on 15/7/9.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCNavigationBarController.h"
#import "UIColor+CCCategory.h"

@implementation CCNavigationBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor colorWithRGBHexString:@"#151515"], NSForegroundColorAttributeName,
                                                [UIFont appFontOfSize:18],
                                                NSFontAttributeName, nil]];
    self.navigationController.navigationBar.clipsToBounds = NO;
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[[UINavigationBar appearance].barTintColor colorWithAlphaComponent:0.99]] forBarMetrics:UIBarMetricsDefault];
}

@end
