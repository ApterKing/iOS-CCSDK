//
//  CCPBScrollView.h
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCPBScrollView : UIScrollView

// 当前显示第几张图片
@property (nonatomic, assign) NSUInteger index;

- (void)saveImageToAlbum;

@end
