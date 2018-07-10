//
//  CCPBPhotoModel.m
//  DYSport
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPBPhotoModel.h"

@implementation CCPBPhotoModel

- (void)setLocalPath:(NSString *)localPath
{
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    if (image == nil) {
        NSLog(@"加载本地图片出错");
        image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathExtension:@"ccsdk.bundle/images/icon_image_loading_fail.png"]];
    }
    self.image = image;
}

@end
