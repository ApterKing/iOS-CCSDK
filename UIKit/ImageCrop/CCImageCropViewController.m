//
//  CCImageCropViewController.m
//  CCSDK
//
//  Created by wangcong on 15/12/28.
//  Copyright © 2015年 WangCong. All rights reserved.
//

#import "CCImageCropViewController.h"
#import "CCSDKDefines.h"
#import "UIColor+CCCategory.h"
#import "UIFont+CCCategory.h"

#define BOUNDCE_DURATION 0.3f

// 顶部view高度
#define kCCCropTopHeight      (IS_IPHONE_6_OR_LESS ? 84 : 100)

// 底部view高度
#define kCCCropBottomHeight   (IS_IPHONE_6_OR_LESS ? 94 : 120)

// 缩放比例
#define kCCCropMaximumScale     3.0

@interface CCImageCropViewController ()<UIScrollViewDelegate>

// 图片层
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, assign) CGFloat      scale; // 缩放比例

// 遮罩层及裁剪区域
@property (nonatomic, strong) UIView       *maskView;
@property (nonatomic, strong) UIView       *cropAreaView;
@property (nonatomic, assign) CGRect       cropAreaRect;

// 被裁剪图片在原图的区域
@property (nonatomic, assign) CGRect       cropedRect;

@end

@implementation CCImageCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cropSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
    CGFloat translucentHeight = (SCREEN_HEIGHT - kCCCropTopHeight - kCCCropBottomHeight - _cropSize.height) / 2.0;
    self.cropAreaRect = CGRectMake((SCREEN_WIDTH - _cropSize.width) / 2.0, kCCCropTopHeight + translucentHeight, _cropSize.width, _cropSize.height);
    [self _initSubview];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    self.originalImage = nil;
    self.scrollView = nil;
    self.imageView = nil;
    self.maskView = nil;
}

- (void)_initSubview {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 可滑动区域
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.cropAreaRect];
    self.scrollView.maximumZoomScale = kCCCropMaximumScale;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    
    CGFloat scaleX =  self.originalImage.size.width / CGRectGetWidth(self.cropAreaRect);
    CGFloat scaleY =  self.originalImage.size.height / CGRectGetHeight(self.cropAreaRect);
    self.scale = scaleX > scaleY ? scaleY : scaleX;
    self.scrollView.contentSize = CGSizeMake(self.originalImage.size.width / self.scale, self.originalImage.size.height / self.scale);
    [self.view addSubview:self.scrollView];
    
    // 图片
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.originalImage;
    self.imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.imageView];
    if (self.scrollView.contentSize.width > CGRectGetWidth(self.scrollView.frame)) {
        [self.scrollView setContentOffset:CGPointMake((self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame)) / 2.0, 0) animated:YES];
    }
    if (self.scrollView.contentSize.height > CGRectGetHeight(self.scrollView.frame)) {
        [self.scrollView setContentOffset:CGPointMake(0, (self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame)) / 2.0) animated:YES];
    }
    [self scrollViewDidZoom:self.scrollView];
    
    // 顶部及底部UIView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kCCCropTopHeight)];
    topView.backgroundColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    [self.view addSubview:topView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kCCCropBottomHeight, SCREEN_WIDTH, kCCCropBottomHeight)];
    bottomView.backgroundColor = topView.backgroundColor;
    [self.view addSubview:bottomView];
    
    // 蒙版
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.alpha = .5f;
    self.maskView.backgroundColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.maskView];
    
    self.cropAreaView = [[UIView alloc] initWithFrame:self.cropAreaRect];
    self.cropAreaView.userInteractionEnabled = NO;
    self.cropAreaView.layer.borderColor = [UIColor colorWithRGBHexString:@"#fb5f46"].CGColor;
    self.cropAreaView.layer.borderWidth = 1.0f;
    self.cropAreaView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.cropAreaView];
    [self _maskViewClipping];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(30, (CGRectGetHeight(bottomView.frame) - 36) / 2.0, 60, 35)];
    cancelButton.titleLabel.font = [UIFont appFontOfSize:IS_IPHONE_6_OR_LESS ? 19 : 22];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRGBHexString:@"#9e3a2a"] forState:UIControlStateHighlighted];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [bottomView addSubview:cancelButton];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottomView.frame) - CGRectGetMinX(cancelButton.frame) - CGRectGetWidth(cancelButton.frame), CGRectGetMinY(cancelButton.frame), CGRectGetWidth(cancelButton.frame), CGRectGetHeight(cancelButton.frame))];
    confirmButton.titleLabel.font = cancelButton.titleLabel.font;
    [confirmButton setTitleColor:[cancelButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[cancelButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [bottomView addSubview:confirmButton];
    
    @weakify(self);
    cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        return [RACSignal empty];
    }];
    
    confirmButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.cropHandler) {
                self.cropHandler(self, self.originalImage, [self _cropImage], self.cropedRect);
            }
        }];
        return [RACSignal empty];
    }];
}

- (void)_maskViewClipping {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0, CGRectGetWidth(self.cropAreaView.frame), CGRectGetMinY(self.cropAreaView.frame)));
    CGPathAddRect(path, nil, CGRectMake(0, CGRectGetMinY(self.cropAreaView.frame), CGRectGetMinX(self.cropAreaView.frame), CGRectGetHeight(self.cropAreaView.frame)));
    CGPathAddRect(path, nil, CGRectMake(CGRectGetMaxX(self.cropAreaView.frame), CGRectGetMinY(self.cropAreaView.frame), CGRectGetWidth(self.maskView.frame) - CGRectGetMinX(self.cropAreaView.frame), CGRectGetHeight(self.cropAreaView.frame)));
    CGPathAddRect(path, nil, CGRectMake(0, CGRectGetMaxY(self.cropAreaView.frame), CGRectGetWidth(self.cropAreaView.frame), SCREEN_HEIGHT));
    maskLayer.path = path;
    self.maskView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (UIImage *)_cropImage {
    CGRect latestRect = {self.scrollView.contentOffset, self.scrollView.contentSize};
    CGFloat x = latestRect.origin.x  * self.scale / self.scrollView.zoomScale;
    CGFloat y = latestRect.origin.y  * self.scale / self.scrollView.zoomScale;
    CGFloat w = self.cropAreaRect.size.width  * self.scale / self.scrollView.zoomScale;
    self.cropedRect = CGRectMake(x, y, w, w);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, self.cropedRect);
    CGSize size;
    size.width = self.cropedRect.size.width;
    size.height = self.cropedRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, self.cropedRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2.0 : CGRectGetWidth(scrollView.frame) / 2.0;
    CGFloat ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2.0 : CGRectGetHeight(scrollView.frame) / 2.0;
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
}

@end
