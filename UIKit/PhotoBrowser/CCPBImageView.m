//
//  CCPBImageView.m
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPBImageView.h"

@interface CCPBImageView ()

@end

@implementation CCPBImageView

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    if(image == nil) return;
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self _innerCalculatedFrame];
}

- (void)_innerCalculatedFrame {
    CGFloat imageW = self.image.size.width;
    CGFloat imageH = self.image.size.height;
    
    CGFloat superW = CGRectGetWidth(self.superview.frame);
    CGFloat superH = CGRectGetHeight(self.superview.frame);
    
    CGFloat scale = imageW / superW;
    if (imageW >= imageH) {   // 宽大于高
        CGFloat calculatedW = scale < 1.0 ? imageW : superW;
        CGFloat calculatedH = scale < 1.0 ? imageH : imageH / scale;
        _calculatedFrame = (CGRect){CGPointMake(self.superview.center.x - calculatedW / 2.0, self.superview.center.y - calculatedH / 2.0), CGSizeMake(calculatedW, calculatedH)};
    } else {
        CGFloat calculatedW = imageH < superH ? imageW : superW;
        CGFloat calculatedH = imageH < superH ? imageH : imageH / scale;
        _calculatedFrame = (CGRect){CGPointMake(imageH / scale < superH ? self.superview.center.x - calculatedW / 2.0 : 0, imageH / scale < superH ? self.superview.center.y - calculatedH / 2.0 : 0), CGSizeMake(calculatedW, calculatedH)};
    }
}

/**
 *  根据图片计算出合理的宽高
 *  @return
 */
//- (void)_calculatedFrame
//{
//    CGSize size = self.image.size;
//    
//    CGFloat w = size.width;
//    CGFloat h = size.height;
//    
//    CGRect superFrame = self.superview.frame;
//    CGFloat superW = superFrame.size.width ;
//    CGFloat superH = superFrame.size.height;
//    
//    CGFloat calW = superW;
//    CGFloat calH = superW;
//    
//    if (w >= h) {//较宽
//        
//        if(w > superW) { //比屏幕宽
//            CGFloat scale = superW / w;
//            //确定宽度
//            calW = w * scale;
//            calH = h * scale;
//            
//        } else if(w <= superW) {//比屏幕窄，直接居中显示
//            calW = w;
//            calH = h;
//        }
//    } else if(w < h) {//较高
//        CGFloat scale1 = superH / h;
//        CGFloat scale2 = superW / w;
//        BOOL isFat = w * scale1 > superW;//比较胖
//        
//        CGFloat scale =isFat ? scale2 : scale1;
//        if(h > superH){//比屏幕高
//            //确定宽度
//            calW = w * scale;
//            calH = h * scale;
//        } else if(h <= superH){//比屏幕窄，直接居中显示
//            if(w > superW){
//                //确定宽度
//                calW = w * scale;
//                calH = h * scale;
//            } else {
//                calW = w;
//                calH = h;
//            }
//        }
//    }
//    
//    CGFloat x = self.superview.center.x - calW * .5f;
//    CGFloat y = self.superview.center.y - calH * .5f;
//    CGRect frame = (CGRect){CGPointMake(x, y), CGSizeMake(calW, calH)};
//    _calculatedFrame = frame;
//}

@end
