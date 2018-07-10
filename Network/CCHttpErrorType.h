//
//  CCHttpErrorType.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/*
 *  网络请求出错类型
 */
#ifndef HurricaneConsumer_CCHttpErrorType_h
#define HurricaneConsumer_CCHttpErrorType_h

typedef NS_ENUM(NSInteger, CCHttpErrorTypeEnum) {
    HTTP_ERROR_LOCAL,
    HTTP_ERROR_NET,
    HTTP_ERROR_TIMEOUT,
    HTTP_ERROR_RESPONSE,
    HTTP_ERROR_INTERRUPT
};

#define HTTP_ERROR_LOCAL_REASON      @"本地数据封装出错"
#define HTTP_ERROR_NET_REASON        @"网络未连接";
#define HTTP_ERROR_TIMEOUT_REASON    @"连接超时"
#define HTTP_ERROR_RESPONSE_REASON   @">=400 访问服务器出错"
#define HTTP_ERROR_INTERRUPT_REASON  @"用户取消了请求操作"

#endif
