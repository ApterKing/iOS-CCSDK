//
//  CCHttpError.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCHttpError.h"

@implementation CCHttpError

- (NSString *)description
{
    NSString *typeReason = @"";
    switch (_type) {
        case HTTP_ERROR_LOCAL:
            typeReason = HTTP_ERROR_LOCAL_REASON;
            break;
        case HTTP_ERROR_NET:
            typeReason = HTTP_ERROR_NET_REASON;
            break;
        case HTTP_ERROR_TIMEOUT:
            typeReason = HTTP_ERROR_TIMEOUT_REASON;
            break;
        case HTTP_ERROR_RESPONSE:
            typeReason = HTTP_ERROR_RESPONSE_REASON;
            break;
        default:
            typeReason = HTTP_ERROR_INTERRUPT_REASON;
            break;
    }
    return [NSString stringWithFormat:@"[type:  %@  + statusCode:  %li  +  message: %@ \n requestURL: %@ \n exception: %@", typeReason, _statusCode, _statusMessage, _requestURL, _exception.description];
}

@end
