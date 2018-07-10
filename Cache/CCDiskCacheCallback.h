//
//  CCDiskCacheCallback.h
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

/**
 *  用于缓存数据回调，清空缓存、缓存数据成功回调
 */
#import <Foundation/Foundation.h>

/**
 *  清空缓存成功
 *  @prama BOOL 是否清空成功
 */
typedef void(^block_cache_clear)(BOOL);

/**
 *  缓存数据成功回调
 *  @prama BOOL 是否缓存数据成功
 */
typedef void(^block_cache_callback)(BOOL);

@interface CCDiskCacheCallback : NSObject

@end
