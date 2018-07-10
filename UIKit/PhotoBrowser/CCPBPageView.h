//
//  CCPBPageView.h
//  DYSport
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPBPhotoModel.h"

@interface CCPBPageView : UIView

/** 相册模型 */
@property(nonatomic, strong) CCPBPhotoModel *photoModel;

@property(nonatomic, assign) NSUInteger pageIndex;

@property(nonatomic, assign) CGFloat zoomScale;

- (void)saveImageToAlbum;

/*
 *  重置
 */
- (void)reset;

@end
