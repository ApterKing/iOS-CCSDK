//
//  CCImageCropViewController.h
//  CCSDK
//
//  Created by wangcong on 15/12/28.
//  Copyright © 2015年 WangCong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCImageCropViewController;

// 截图回调  返回原图、剪切后的图及剪切位置
typedef void(^CCImageCropHandler)(CCImageCropViewController *imageCropViewController, UIImage *originalImage, UIImage *cropedImage, CGRect cropedRect);

@interface CCImageCropViewController : UIViewController

// 待裁剪图片
@property (nonatomic, strong) UIImage *originalImage;

// 裁剪大小 default: {screenWidth, screenWidth}
@property (nonatomic, assign) CGSize   cropSize;

// 裁剪后回调
@property (nonatomic, copy) CCImageCropHandler cropHandler;


@end
