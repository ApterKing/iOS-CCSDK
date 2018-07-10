//
//  CCNavigationBarMenu.h
//  CCSDK
//
//  Created by wangcong on 16/1/19.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCNavigationBarMenuItem : NSObject

@property (nonatomic, strong) UIImage  *image;// 图标
@property (nonatomic, copy  ) NSString *title;// 标题

@property (nonatomic, strong) UIColor  *titleColor;// 颜色   #4a4a4a
@property (nonatomic, strong) UIFont   *titleFont;// 字体大小 system 15.5  17

+ (instancetype)navigationBarMenuItemWithImage:(UIImage *)image title:(NSString *)title;

@end

@interface CCNavigationBarMenu : NSObject

@property (nonatomic, strong) NSArray *items;// 菜单数据
@property (nonatomic, assign) CGRect  triangleFrame;// 三角形位置 default : CGRectMake(width-25, 0, 12, 12)

@property (nonatomic, strong) UIColor *separatorColor;// 分割线颜色 #e8e8e8
@property (nonatomic, assign) CGFloat rowHeight;// 菜单条目高度

@property (nonatomic, copy) void(^didSelectMenuItem)(CCNavigationBarMenu *menu, CCNavigationBarMenuItem *item);// 点击条目

- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width;
- (void)show;
- (void)dismiss;

@end
