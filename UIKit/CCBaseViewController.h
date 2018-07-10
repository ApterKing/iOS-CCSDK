//
//  CCBaseViewController.h
//  CCSDK
//
//  Created by wangcong on 15-1-23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCBaseViewController : UIViewController

@property (nonatomic, strong) UIButton *leftButton;
/**
 *  点击返回按钮操作
 *
 *  @param barButtonItem 
 */
- (void)leftBarButtonItemClick:(UIButton *)leftButton;

@end
