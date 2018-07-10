//
//  CCQRCodeScanViewController.h
//  CCSDK
//
//  Created by wangcong on 15/12/29.
//  Copyright © 2015年 WangCong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCQRCodeScanViewController : CCBaseViewController

//扫描取消
@property (nonatomic, copy) void (^QRCodeCancelHandler) (CCQRCodeScanViewController *);

//扫描结果
@property (nonatomic, copy) void (^QRCodeSuccessHandler) (CCQRCodeScanViewController *, NSString *);

//扫描失败
@property (nonatomic, copy) void (^QRCodeFailureHandler) (CCQRCodeScanViewController *);

@end
