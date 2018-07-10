//
//  CCPBPhotoModel.h
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCPBPhotoModel : NSObject

// 网络路径
@property(nonatomic, copy) NSString *netUrl;

// 本地图片或者是加载了的网络图片
@property(nonatomic, strong) UIImage *image;

// 本地文件路径或者本地图片
@property(nonatomic, copy) NSString *localPath;

// 附加信息
@property(nonatomic, strong) NSObject *info;

@end
