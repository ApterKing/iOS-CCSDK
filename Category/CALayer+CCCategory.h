//
//  CALayer+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15/8/18.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    //X
    AnimReverDirectionX=0,
    
    //Y
    AnimReverDirectionY,
    
    //Z
    AnimReverDirectionZ,
    
} AnimReverDirection;

/*
 *  动画类型
 */
typedef enum{
    
    //水波
    TransitionAnimTypeRippleEffect=0,
    
    //吸走
    TransitionAnimTypeSuckEffect,
    
    //翻开书本
    TransitionAnimTypePageCurl,
    
    //正反翻转
    TransitionAnimTypeOglFlip,
    
    //正方体
    TransitionAnimTypeCube,
    
    //push推开
    TransitionAnimTypeReveal,
    
    //合上书本
    TransitionAnimTypePageUnCurl,
    
    //随机
    TransitionAnimTypeRamdom,
    
} TransitionAnimType;




/*
 *  动画方向
 */
typedef enum {
    
    //从上
    TransitionSubtypesFromTop=0,
    
    //从左
    TransitionSubtypesFromLeft,
    
    //从下
    TransitionSubtypesFromBotoom,
    
    //从右
    TransitionSubtypesFromRight,
    
    //随机
    TransitionSubtypesFromRamdom,
    
} TransitionSubType;


/*
 *  动画曲线
 */
typedef enum {
    
    //默认
    TransitionCurveDefault,
    
    //缓进
    TransitionCurveEaseIn,
    
    //缓出
    TransitionCurveEaseOut,
    
    //缓进缓出
    TransitionCurveEaseInEaseOut,
    
    //线性
    TransitionCurveLinear,
    
    //随机
    TransitionCurveRamdom,
    
} TransitionCurve;

@interface CALayer (CCCategory)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

- (void)topAdd:(CGFloat)add;
- (void)leftAdd:(CGFloat)add;
- (void)widthAdd:(CGFloat)add;
- (void)heightAdd:(CGFloat)add;

@end

@interface CALayer (CCAnim)

- (CAAnimation *)anim_shake:(NSArray *)rotations duration:(NSTimeInterval)duration repeatCount:(NSUInteger)repeatCount;

- (CAAnimation *)anim_revers:(AnimReverDirection)direction duration:(NSTimeInterval)duration isReverse:(BOOL)isReverse repeatCount:(NSUInteger)repeatCount timingFuncName:(NSString *)timingFuncName;

@end

@interface CALayer (CCTransition)

- (CATransition *)transitionWithAnimType:(TransitionAnimType)animType subType:(TransitionSubType)subType curve:(TransitionCurve)curve duration:(CGFloat)duration;

@end
