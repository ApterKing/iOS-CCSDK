//
//  CCSDK.h
//  CCSDK
//
//  Created by wangcong on 16/5/21.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#ifndef CCSDK_h
#define CCSDK_h

// 框架需要使用到 ReactiveCocoa SDWebImage MBProgress Masonry pop，请使用cocoapod导入

/* --------------- Category ---------------- */
#import "ALAssetsLibrary+CCCategory.h"                  // 图片保存到自定义相册
#import "CALayer+CCCategory.h"                          // CALayer动画处理
#import "NSDate+CCCategory.h"                           // 时间格式化
#import "NSString+CCCategory.h"                         // 判定字符串是否为中文、Base64转换，计算文本CGSize，其他正则验证
#import "UIColor+CCCategory.h"                          // 通过16进制转换颜色 #ff32de
#import "UIFont+CCCategory.h"                           // 程序默认字体设置
#import "UIImage+CCCategory.h"                          // 图片缩放、拉伸、圆形图片
#import "UIView+CCCategory.h"                           // 设置UIView top left right bottom等
#import "UIViewController+CCCategory.h"                 // 设置初始化点击View键盘隐藏、借助MBProgress显示加载进度、加载错误、加载成功、hint提示

/* --------------- Cache    ---------------- */
#import "CCCacheManager.h"                              // 缓存工具，支持内存与磁盘两种缓存，支持磁盘缓存成功回调及清空缓存回调

/* --------------- Core     ---------------- */
#import "CCSDKCore.h"
#import "CCSDKConstant.h"
#import "CCSDKDefines.h"                                // 常用宏定义
#import "CCKeyboardHelper.h"                            // 用于处理UITextField, UITextView, UISearchBar键盘弹出

/* ----------------- Media  ---------------- */
#import "CCPlayer.h"
#import "CCRecorder.h"
#import "CCSoundPool.h"

/* ---------------- Network  ---------------- */
#import "CCHttpClient.h"                                // 同步异步http请求客户端 支持（POST/GET/PUT/HEAD/DELETE）方式访问服务器端 支持多文件上
// 传，支持取消操作，支持下载进度，支持断点续传功能
#import "CCMultiParam.h"                                // 多数据上传封装工具，用于（POST/PUT/DELETE)请求时上传多数据
#import "CCHttpRequest.h"                               // 网络请求类，通过CCHttpClient构建，支持上传回调设置
#import "CCHttpRequestCallback.h"                       // 网络请求回调，支持delegate 与block 初始化，支持响应提交数据的进度
#import "CCHttpResponse.h"                              // 网络请求响应类，用于处理网络请求数据响应，支持同步，异步读取数据
#import "CCHttpResponseCallback.h"                      // 网络请求响应回调，支持响应成功、失败、进度
#import "CCHttpResponseInfo.h"                          // http请求响应信息
#import "CCHttpError.h"                                 // http请求失败信息
#import "CCHttpErrorType.h"                             // http请求失败类型

/* ----------------- Sensor ---------------- */
#import "CCSensorMeterManager.h"                        // 距离、计步、挥拳
#import "CCPedometer.h"                                 // iOS计步
#import "CCHighMeter.h"                                 // 跳高计算
#import "CCPedometerData.h"                             // 计步数据
#import "CCPunchMeterData.h"                            // 挥拳数据

/* ----------------- UIKit ----------------- */
#import "CCBaseViewController.h"
#import "CCNavigationBarController.h"

/* ----------------- UIKit.Album ----------- */
#import "CCAlbumViewController.h"                       // 自定义相册，可多选单选
#import "CCAlbumModel.h"

/* ----------------- UIKit.PhotoBrowser ---- */
#import "CCPBViewController.h"                          // 相册浏览器，支持放大缩小，长图及多图，本地图片及网络图片
#import "CCPBPhotoModel.h"

/* ----------------- UIKit.EmojiKeyboard --- */
#import "CCEmojiInputView.h"
#import "CCEmojiKeyboard.h"

/* ----------------- UIKit.ImageCrop ------- */
#import "CCImageCropViewController.h"                   // 图片裁剪

/* ----------------- UIKit.QRCode ---------- */
#import "CCQRCodeScanViewController.h"                  // 二维码扫描

/* ----------------- UIKit.View ------------ */
#import "CCActionSheet.h"                               // 自定义ActionSheet
#import "CCBadgeView.h"                                 // BadgeView
#import "CCComboBox.h"                                  // 下拉选项
#import "CCLabel.h"                                     // 自定义Label，支持文本中含有@xx  #tag# http 自定义标签点击及颜色设置
#import "CCNavigationBarMenu.h"                         // NavigationBar上弹出菜单，类似于微信的弹出菜单
#import "CCProgressView.h"                              // 自定义进度条，支持设置圆形、条形、颜色等
#import "CCRatingStar.h"                                // 五角星打分控件
#import "CCSegmentedControl.h"                          // 类似于UISegmentedControl控件
#import "CCSpecialTextView.h"                           // 支持文本中含有@xx  #tag# http 自定义标签高亮及整体删除
#import "CCStackMenu.h"                                 // 弹出菜单，支持设置文字方向，弹出方向，图片设置
#import "CCStepSlider.h"                                // 可滑动进度条
#import "CCTextField.h"                                 // 自定义UITextField，设置文字边距
#import "CCTextView.h"                                  // 自定义UITextView，支持placeHolder设置

/* ---------------- Utils   ---------------- */
#import "CCCrc32.h"                                     // crc32小文件校验及大文件异步校验
#import "CCJsonUtil.h"                                  // json 数据解析与封装
#import "CCNetUtil.h"                                   // 网络状态检测
#import "CCEncryptUtil.h"                               // MD5、HMAC_SHA1 加密
#import "CCGTMBase64.h"                                 // Google Base64字符串编码，用于与android端对接

#endif /* CCSDK_h */
