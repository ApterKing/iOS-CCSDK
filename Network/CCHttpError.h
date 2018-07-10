//
//  CCHttpError.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//


/**
 *  Http请求出错信息
 */
#import <Foundation/Foundation.h>
#import "CCHttpErrorType.h"

@interface CCHttpError : NSObject

@property(nonatomic, assign) CCHttpErrorTypeEnum    type;
@property(nonatomic, assign) NSInteger              statusCode;
@property(nonatomic, weak)   NSString               *statusMessage;
@property(nonatomic, weak)   NSException            *exception;
@property(nonatomic, weak)   NSString               *requestURL;

@end
