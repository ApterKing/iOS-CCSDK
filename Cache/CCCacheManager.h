//
//  CCCacheManager.h
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDiskCacheCallback.h"

/**
 *  Created by wangcong on 14-11-27. <br>
 *  缓存管理器
 */
@interface CCCacheManager : NSCache
{
@private
    BOOL isInitialized;     //是否已经完成了缓存初始化
}

// 缓存大小，在框架初始化成功后不一定能够马上得到当前目录中的缓存大小，缓存大小通过异步方式计算
@property(nonatomic, readonly) long long cacheSize;

+ (instancetype)sharedInstance;

/**
 *  获取到默认缓存路径
 *  @return
 */
+ (NSString *)cachePath;

/**
 *  异步初始化缓存，用于读取当前缓存大小，该方法无需用户直接调用
 */
- (void)initialCache;

/**
 *  同步将数据缓存到指定的目录[cachePath]
 *  @param data     需要缓存的数据
 *  @param fileName 缓存文件名
 *  @return
 */
- (BOOL)cacheData:(NSData *)data withFileName:(NSString *)fileName;

/**
 *  异步将数据缓存到指定的目录[cachePath]
 *  @param data     需要缓存的数据
 *  @param fileName 缓存文件名
 *  @param bCallback 缓存数据成功或失败回调
 *  @return
 */
- (void)cacheData:(NSData *)data withFileName:(NSString *)fileName callback:(block_cache_callback)bCallback;

/**
 *  同步将数据缓存到指定目录
 *  @param data     需要缓存的数据
 *  @param filePath 文件路劲
 *  @return
 */
- (BOOL)cacheData:(NSData *)data withPath:(NSString *)filePath;

/**
 *  同步将数据缓存到指定目录
 *  @param data     需要缓存的数据
 *  @param filePath 文件路劲
 *  @param bCallback 缓存数据成功或失败回调
 *  @return
 */
- (void)cacheData:(NSData *)data withPath:(NSString *)filePath callback:(block_cache_callback)bCallback;

/**
 *  同步获取缓存的数据
 *  @param fileName
 *  @return NSData
 */
- (NSData *)dataForFileName:(NSString *)fileName;

/**
 *  同步获取指定路劲下的缓存数据
 *  @param filePath 文件路劲
 *  @return
 */
- (NSData *)dataForFilePath:(NSString *)filePath;

/**
 *  清空缓存
 *  @param clear
 */
- (void)clearCache:(block_cache_clear)bClear;

@end
