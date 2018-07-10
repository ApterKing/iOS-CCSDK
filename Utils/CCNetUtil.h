//
//  CCNetUtil.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CCNetworkStatus) {
    net_status_none,     //无网络
    net_status_wwan,     //手机网络
    net_status_wifi      //wifi网络
};

@interface CCNetUtil : NSObject

/**
 *  检测网络类型
 *  @return NetworkStatus
 */
+ (CCNetworkStatus)networkStatus;

/*!
 *  判断网络是否可用
 *
 *  @return BOOL (可用:YES; 不可用:NO)
 */
+ (BOOL)connectedToNet;

@end
