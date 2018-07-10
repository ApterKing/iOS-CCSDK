//
//  CCQRCodeScanViewController.m
//  DYSport
//
//  Created by wangcong on 15/12/29.
//  Copyright © 2015年 WangCong. All rights reserved.
//

#import "CCQRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+CCCategory.h"
#import "CCSDKDefines.h"

@interface CCQRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *qrSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;

// 蒙版层
@property (nonatomic, strong) UIView *maskView;

// 扫描区域
@property (nonatomic, strong) UIView *scanView;

// 线
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation CCQRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubview];
    [self _startQRCodeReading];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"扫描";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    if (self.qrSession) {
        [self.qrSession stopRunning];
        self.qrSession = nil;
    }
    
    if (self.qrVideoPreviewLayer) {
        self.qrVideoPreviewLayer = nil;
    }
    
    if (self.disposable) {
        [self.disposable dispose];
        self.disposable = nil;
    }
}

- (void)_initSubview {
    
    // 资源路径
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images"];
    
    // 蒙版
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.alpha = .4f;
    self.maskView.backgroundColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.maskView];
    
    // 扫描区域
    CGFloat width = APP_WIDTH - (IS_IPHONE_6_OR_LESS ? 130 : 180);
    self.scanView = [[UIView alloc] initWithFrame:CGRectMake((APP_WIDTH - width) / 2.0, (APP_HEIGHT - width) / 2.0 - 80, width, width)];
    self.scanView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.scanView.layer.borderWidth = 1.0f;
    self.scanView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.scanView];
    [self _maskViewClipping];
    
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scanView.frame) - 15, CGRectGetMinY(self.scanView.frame) + 5, CGRectGetWidth(self.scanView.frame) + 30, 15)];
    [self.lineImageView setImage:[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"qr_line.png"]]];
    [self.view addSubview:self.lineImageView];
    
    //说明label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame) + 15, APP_WIDTH, 20)];
    label.text = @"将二维码置于框内,即可自动扫描";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:13.0];
    label.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:label];
    
    // 边角view
    width = 14;
    UIImageView *tlImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scanView.frame) - width / 2.0, CGRectGetMinY(self.scanView.frame) - width / 2.0, width, width)];
    tlImageView.image = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"qr_tl.png"]];
    [self.view addSubview:tlImageView];
    
    UIImageView *lbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tlImageView.frame), CGRectGetMaxY(self.scanView.frame) - CGRectGetWidth(tlImageView.frame) / 2.0, CGRectGetWidth(tlImageView.frame), CGRectGetHeight(tlImageView.frame))];
    lbImageView.image = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"qr_lb.png"]];
    [self.view addSubview:lbImageView];
    
    UIImageView *brImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.scanView.frame) - CGRectGetWidth(tlImageView.frame) / 2.0, CGRectGetMinY(lbImageView.frame), CGRectGetWidth(tlImageView.frame), CGRectGetHeight(tlImageView.frame))];
    brImageView.image = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"qr_br.png"]];
    [self.view addSubview:brImageView];
    
    UIImageView *trImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(brImageView.frame), CGRectGetMinY(tlImageView.frame), CGRectGetWidth(tlImageView.frame), CGRectGetHeight(tlImageView.frame))];
    trImageView.image = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"qr_tr.png"]];
    [self.view addSubview:trImageView];
    
    // 扫描界面
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //摄像头判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    
    //设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:self.scanView.frame];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    } else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    preview.frame = self.view.layer.bounds;
    
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    self.qrVideoPreviewLayer = preview;
    self.qrSession = session;
}

- (void)_maskViewClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0, CGRectGetWidth(self.maskView.frame), CGRectGetMinY(self.scanView.frame)));
    CGPathAddRect(path, nil, CGRectMake(0, CGRectGetMinY(self.scanView.frame), CGRectGetMinX(self.scanView.frame), CGRectGetHeight(self.scanView.frame)));
    CGPathAddRect(path, nil, CGRectMake(CGRectGetMaxX(self.scanView.frame), CGRectGetMinY(self.scanView.frame), CGRectGetWidth(self.maskView.frame) - CGRectGetMinX(self.scanView.frame), CGRectGetHeight(self.scanView.frame)));
    CGPathAddRect(path, nil, CGRectMake(0, CGRectGetMaxY(self.scanView.frame), CGRectGetWidth(self.maskView.frame), SCREEN_HEIGHT));
    maskLayer.path = path;
    self.maskView.layer.mask = maskLayer;
    CGPathRelease(path);
}

#pragma mark -
#pragma mark 输出代理方法
//此方法是在识别到QRCode，并且完成转换
//如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //扫描结果
    if (metadataObjects.count > 0) {
        [self _stopQRCodeReading];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0) {
            NSLog(@"---------%@", obj.stringValue);
            NSString *resultStringValue = obj.stringValue;
            if (self.QRCodeSuccessHandler) {
                self.QRCodeSuccessHandler(self, resultStringValue);
            } else {
                if (self.QRCodeFailureHandler) {
                    self.QRCodeFailureHandler(self);
                }
            }
        } else {
            if (self.QRCodeFailureHandler) {
                self.QRCodeFailureHandler(self);
            }
        }
    } else {
        if (self.QRCodeFailureHandler) {
            self.QRCodeFailureHandler(self);
        }
    }
}

#pragma mark -
#pragma mark 交互事件
- (void)_startQRCodeReading {
    [self.qrSession startRunning];
    @weakify(self);
    self.disposable = [[[RACSignal interval:1.0 / 20 onScheduler:[RACScheduler scheduler]]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         @strongify(self);
         [self _animationLine];
    }];
}

- (void)_stopQRCodeReading {
    [self.disposable dispose];
    self.disposable = nil;
    [self.qrSession stopRunning];
}

- (void)_cancelQRCodeReading
{
    [self _startQRCodeReading];
    if (self.QRCodeCancelHandler) {
        self.QRCodeCancelHandler(self);
    }
}

#pragma mark -
#pragma mark 上下滚动交互线
- (void)_animationLine
{
    __block CGRect frame = _lineImageView.frame;
    static BOOL flag = YES;
    if (flag) {
        frame.origin.y = CGRectGetMinY(self.scanView.frame) + 5;
        flag = NO;
        [UIView animateWithDuration:1.0 / 20 animations:^{
            frame.origin.y += 5;
            self.lineImageView.frame = frame;
        } completion:nil];
    } else {
        if (self.lineImageView.frame.origin.y >= CGRectGetMinY(self.scanView.frame) + 5) {
            if (self.lineImageView.frame.origin.y >= CGRectGetMaxY(self.scanView.frame) - 15) {
                frame.origin.y = CGRectGetMinY(self.scanView.frame) + 5;
                self.lineImageView.frame = frame;
                flag = YES;
            } else {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    frame.origin.y += 5;
                    self.lineImageView.frame = frame;
                } completion:nil];
            }
        } else {
            flag = !flag;
        }
    }
}

@end
