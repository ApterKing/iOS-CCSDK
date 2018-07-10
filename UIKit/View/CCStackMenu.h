//
//  CCStackMenu.h
//  CCSDK
//
//  Created by wangcong on 16/3/22.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  CCStackMenuItem
 */
typedef NS_ENUM(NSInteger, CCStackMenuItemTitlePosition) {
    CCStackMenuItemTitlePositionLeft = 0,
    CCStackMenuItemTitlePositionRight,
    CCStackMenuItemTitlePositionUp,
    CCStackMenuItemTitlePositionDown
};

@protocol CCStackMenuItemDelegate;
@interface CCStackMenuItem : UIView

@property (nonatomic, strong, readonly ) UIImage                      *image; //normal图片
@property (nonatomic, strong, readonly ) UIImage                      *highlightedImage;// 高亮图片
@property (nonatomic, strong, readonly ) NSString                     *title; // 文字描述
@property (nonatomic, assign, readwrite) CCStackMenuItemTitlePosition titlePosition; // 文字方向
@property (nonatomic, weak             ) id<CCStackMenuItemDelegate     > delegate;

+ (instancetype)stackMenuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage title:(NSString *)title titlePosition:(CCStackMenuItemTitlePosition)titlePosition;

@end

/*
 *  CCStackMenuItemDelegate
 */
@protocol CCStackMenuItemDelegate <NSObject>

@optional
- (void)stackMenuItemDidTouched:(CCStackMenuItem *)menuItem;

@end

/**
 *  CCStackMenu  弹出菜单，支持设置文字方向，弹出方向，图片设置
 */
typedef NS_ENUM(NSInteger, CCStackMenuDirection) {
    CCStackMenuDirectionUp         = 0,
    CCStackMenuDirectionDown,
    CCStackMenuDirectionLeft,
    CCStackMenuDirectionRight
};

typedef NS_ENUM(NSInteger, CCStackMenuAnimationType) {
    CCStackMenuAnimationTypeLinear = 0,
    CCStackMenuAnimationTypeProgressive,
    CCStackMenuAnimationTypeProgressiveInverse
};

@protocol CCStackMenuDelegate;
@interface CCStackMenu : NSObject

@property (nonatomic, assign  ) CGFloat                  itemsSpacing; // item间距 default: (is_iphone_5_or_less ? 6 : 8)
@property (nonatomic, assign  ) CGSize                   itemsSize;    // item大小 default(is_iphone_5_or_less ? 45 : 55)
@property (nonatomic, strong  ) UIFont                   *itemTitleFont; // item字体
@property (nonatomic, strong  ) UIColor                  *itemTitleBackgroundColor; // 背景颜色 clearColor
@property (nonatomic, strong  ) UIColor                  *itemTitleTextColor; // 字体颜色 #9b9b9b
@property (nonatomic, assign  ) CCStackMenuDirection     stackDirection;// default CCStackMenuDirectionUp
@property (nonatomic, readonly) BOOL                     isShow;
@property (nonatomic, weak    ) id<CCStackMenuDelegate     > delegate;

// 初始化控件
- (instancetype)initWithItems:(NSArray *)items;

- (NSArray *)items;

// 显示在superView，与appendView位置相关
- (void)showInView:(UIView *)superView append:(UIView *)appendView;
- (void)dismiss;

@end

@protocol CCStackMenuDelegate <NSObject>

@optional
- (void)stackMenuWillShow:(CCStackMenu *)stackMenu; //即将打开
- (void)stackMenuDidShow:(CCStackMenu *)stackMenu; // 已经打开
- (void)stackMenuWillDismiss:(CCStackMenu *)stackMenu; // 即将关闭
- (void)stackMenuDidDismiss:(CCStackMenu *)stackMenu; // 已经关闭
- (void)stackMenu:(CCStackMenu *)menu didTouchedItem:(CCStackMenuItem *)item; // 点击

@end
