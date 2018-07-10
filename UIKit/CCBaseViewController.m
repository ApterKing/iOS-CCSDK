//
//  CCBaseViewController.m
//  CCSDK
//
//  Created by wangcong on 15-1-23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCBaseViewController.h"

@interface CCBaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation CCBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRGBHexString:@"#eeeeee"];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 处理NavigationBar
    if (self.navigationController) {
        // 手势返回
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
        // 返回按钮
        NSString *resPath = [[NSBundle mainBundle] resourcePath];
        UIImage *backNor = [UIImage imageWithContentsOfFile:[resPath stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_navc_back_nor.png"]];
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
        _leftButton.adjustsImageWhenHighlighted = NO;
        [_leftButton setBackgroundImage:backNor forState:UIControlStateNormal];
        _leftButton.tag = -1024;
        [_leftButton addTarget:self action:@selector(leftBarButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)leftBarButtonItemClick:(UIButton *)leftButton
{
    if (self.navigationItem)
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    CCLog(@"%@--->viewWillAppear", NSStringFromClass(self.class));
}

#pragma mark - protect
//- (void)navigationBarBackgroundChangeWithAlpha:(CGFloat)alpha
//{
//    if (alpha <= 0 ) {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[[UINavigationBar appearance].barTintColor colorWithAlphaComponent:.0f]] forBarMetrics:UIBarMetricsDefault];
//    } else {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[[UINavigationBar appearance].barTintColor colorWithAlphaComponent:alpha < 1.0 ? alpha : 0.99]] forBarMetrics:UIBarMetricsDefault];
//    }
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    CCLog(@"%@--->viewDidAppear", NSStringFromClass(self.class));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    CCLog(@"%@--->viewWillDisappear", NSStringFromClass(self.class));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    CCLog(@"%@--->viewDidDisappear", NSStringFromClass(self.class));
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    CCLog(@"%@--->viewWillLayoutSubviews", NSStringFromClass(self.class));
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//    CCLog(@"%@--->didReceiveMemoryWarning", NSStringFromClass(self.class));
}

- (void)dealloc
{
    NSLog(@"%@--->dealloc", NSStringFromClass(self.class));
}

@end
