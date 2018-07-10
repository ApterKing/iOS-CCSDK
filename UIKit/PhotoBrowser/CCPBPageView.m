//
//  CCPBPageView.m
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPBPageView.h"
#import "ALAssetsLibrary+CCCategory.h"
#import "NSString+CCCategory.h"
#import "UIViewController+CCCategory.h"
#import "CCPBImageView.h"
#import "CCPBLoadingView.h"
#import "CCSDKDefines.h"

#define kCCPBPhotoMinScale 1.0f
#define KCCPBPhotoMaxScale 4.5f

@interface CCPBPageView ()<UIScrollViewDelegate>
{
    CGFloat _zoomScale;
}

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) CCPBImageView *imageView;
@property(nonatomic, strong) CCPBLoadingView *loadingView;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

/** 旋转手势 */
@property (nonatomic,strong) UIRotationGestureRecognizer *rotationGesture;

@property (nonatomic, strong) UIViewController *controller;

@end


@implementation CCPBPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubviews];
        
        @weakify(self);
        [[RACObserve(self, photoModel) ignore:nil] subscribeNext:^(id x) {
            @strongify(self);
            [self _configWithPhotoModel:x];
        }];
        
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)_initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = KCCPBPhotoMaxScale;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
    
    self.imageView = [[CCPBImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.center = self.scrollView.center;
    [self.scrollView addSubview:self.imageView];
    
    self.loadingView = [[CCPBLoadingView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 60) / 2.0, (CGRectGetHeight(self.frame) - 60) / 2.0, 60, 60)];
    self.loadingView.progress = 0.0f;
    [self addSubview:self.loadingView];
    
    self.rotationGesture = [[UIRotationGestureRecognizer alloc] init];
    [self addGestureRecognizer:self.rotationGesture];
    
    @weakify(self);
    [self.rotationGesture.rac_gestureSignal subscribeNext:^(UIRotationGestureRecognizer *rotationGesture) {
        @strongify(self);
        self.imageView.transform = CGAffineTransformRotate(rotationGesture.view.transform, rotationGesture.rotation);
        rotationGesture.rotation = 0;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.loadingView.frame = CGRectMake((CGRectGetWidth(self.frame) - 60) / 2.0, (CGRectGetHeight(self.frame) - 60) / 2.0, 60, 60);
}

- (void)_configWithPhotoModel:(CCPBPhotoModel *)photoModel
{
    if (photoModel.image == nil) {     // 网络请求
        @weakify(self);
        self.loadingView.hidden = NO;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[photoModel.netUrl stringByEscapingForUrlArgument]] placeholderImage:nil options:SDWebImageLowPriority|SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            @strongify(self);
            CGFloat progress = receivedSize / ((CGFloat)expectedSize);
            [self.loadingView setProgress:progress animated:YES];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if(image != nil) {
                self.loadingView.progress = 0.0f;
            } else {
                UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_image_loading_fail.png"]];
                self.imageView.image = defaultImage;
            }
            self.loadingView.hidden = YES;
            
            self.scrollView.contentSize = self.imageView.calculatedFrame.size;
            self.imageView.frame = self.imageView.calculatedFrame;
            self.scrollView.maximumZoomScale = APP_WIDTH / self.imageView.calculatedFrame.size.width > KCCPBPhotoMaxScale ? APP_WIDTH / self.imageView.calculatedFrame.size.width : KCCPBPhotoMaxScale;
            if (self.imageView.calculatedFrame.size.width < APP_WIDTH && self.imageView.calculatedFrame.size.height < APP_HEIGHT) {
                // 缩放到边界对其屏幕
                self.scrollView.zoomScale = APP_WIDTH / self.imageView.calculatedFrame.size.width > APP_HEIGHT / self.imageView.calculatedFrame.size.height ? APP_HEIGHT / self.imageView.calculatedFrame.size.height : APP_WIDTH / self.imageView.calculatedFrame.size.width;
                self.scrollView.minimumZoomScale = self.scrollView.zoomScale;
            } else {
                self.zoomScale = 1.0;
                self.scrollView.minimumZoomScale = 1.0;
            }
        }];
    } else {
        self.imageView.image = photoModel.image;
        self.loadingView.hidden = YES;
        
        self.scrollView.contentSize = self.imageView.calculatedFrame.size;
        self.imageView.frame = self.imageView.calculatedFrame;
            self.scrollView.maximumZoomScale = APP_WIDTH / self.imageView.calculatedFrame.size.width > KCCPBPhotoMaxScale ? APP_WIDTH / self.imageView.calculatedFrame.size.width : KCCPBPhotoMaxScale;
        if (self.imageView.calculatedFrame.size.width < APP_WIDTH && self.imageView.calculatedFrame.size.height < APP_HEIGHT) {
            // 缩放到边界对其屏幕
            self.scrollView.zoomScale = APP_WIDTH / self.imageView.calculatedFrame.size.width > APP_HEIGHT / self.imageView.calculatedFrame.size.height ? APP_HEIGHT / self.imageView.calculatedFrame.size.height : APP_WIDTH / self.imageView.calculatedFrame.size.width;
                self.scrollView.minimumZoomScale = self.scrollView.zoomScale;
        } else {
            self.zoomScale = 1.0;
            self.scrollView.minimumZoomScale = 1.0;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xcenter = scrollView.center.x, ycenter = scrollView.center.y;
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2.0 : xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2.0 : ycenter;
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
}

#pragma mark - public
- (void)saveImageToAlbum {
    if (self.imageView.image != nil) {
        if (self.assetsLibrary == nil) {
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        [self.assetsLibrary saveImage:self.imageView.image toAlbum:@"动缘健身" withCompletionBlock:^(NSError *error) {
            if (!error) {
                [[self viewController] showSuccessHudWithHint:@"保存成功" delay:2.0];
            } else {
                [[self viewController] showErrorHudWithHint:@"保存失败" delay:2.0];
            }
        }];
    }
}

- (UIViewController *)viewController {
    if (self.controller == nil) {
        for (UIView *next = self.superview; next; next = next.superview) {
            if ([next.nextResponder isKindOfClass:[UIViewController class]]) {
                self.controller = (UIViewController *) next.nextResponder;
                break;
            }
        }
    }
    return self.controller;
}

- (void)reset {
    //缩放比例
    self.zoomScale = 1.0f;
    
    self.imageView.frame = CGRectZero;
}

- (CGFloat)zoomScale {
    return self.scrollView.zoomScale;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    _zoomScale = zoomScale;
    [self.scrollView setZoomScale:zoomScale animated:YES];
}

@end
