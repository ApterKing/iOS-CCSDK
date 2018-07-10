//
//  UIImage+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 15-6-11.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CCCategory)

/**
 *  等比缩放图片
 *  @param targetSize 输出大小
 *  @return
 */
- (UIImage *)scaleToSize:(CGSize)targetSize;

/**
 *  等比缩放图片
 *  @param image   待缩放的图片
 *  @param targetSize 输出大小
 *  @return
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize;

/**
 *  缩放图片
 *  @param targetSize 输出大小
 *  @return
 */
- (UIImage *)forceScaleToSize:(CGSize)targetSize;

/**
 *  根据指定宽度等比压缩图片
 *
 *  @param sourceImage 原图片
 *  @param targetWith  指定宽度
 *
 *  @return
 */
+ (UIImage *)scaleImage:(UIImage *)sourceImage targetWidth:(CGFloat)targetWith;


/**
 *  根据宽度等比要是图片
 *
 *  @param targetWith
 *  @return
 */
- (UIImage *)scaleToTargetWith:(CGFloat)targetWith;


/**
 *  缩放图片
 *  @param image   待缩放的图片
 *  @param targetSize 输出大小
 *  @return
 */
+ (UIImage *)forceScaleImage:(UIImage *)image toSize:(CGSize)targetSize;

/**
 *  拉伸图片
 *
 *  @param top
 *  @param left
 *  @param bottom
 *  @param right
 *  @return
 */
- (UIImage *)stretchwithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

/**
 *  拉伸图片
 *  @param image  原始图片
 *  @param top
 *  @param left
 *  @param bottom
 *  @param right
 *  @return
 */
+ (UIImage *)stretchImage:(UIImage *)image top:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

/**
 *  将图片转换为圆形
 *
 *  @param name        图片名称
 *  @param borderWidth 边缘宽度
 *  @param borderColor 边缘颜色
 *  @return
 */
+ (UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 *  将图片转换成圆形
 *
 *  @param image       图片
 *  @param borderWidth 边缘宽度
 *  @param borderColor 边缘颜色
 *  @return
 */
+ (UIImage *)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 *  将颜色转换为图片
 *
 *  @param color
 *  @return
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

// 截取屏幕
+ (UIImage *)screenShot;

@end

@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

@interface UIImage(fixOrientation)

- (UIImage *)fixOrientation;

@end
