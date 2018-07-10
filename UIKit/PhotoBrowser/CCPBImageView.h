//
//  CCPBImageView.h
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCPBImageView : UIImageView

// 根据图片大小与屏幕比例计算出的最终rect
@property (nonatomic, assign) CGRect calculatedFrame;

@end
