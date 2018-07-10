//
//  CCCacheManager.m
//  CCSDK
//
//  Created by wangcong on 15-1-21.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCCacheManager.h"

static CCCacheManager *instance = nil;
static dispatch_once_t predicate;

@implementation CCCacheManager

+ (instancetype)sharedInstance
{
    dispatch_once(&predicate, ^{
        if (instance == nil) {
            instance = [[[self class] alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSString *)cachePath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *dir = [[[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"kdslitucc"];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return dir;
}

- (void)initialCache
{
    if (isInitialized) return;
    isInitialized = YES;
    
    // 异步得到当前缓存大小
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *filePathArray = [self getFilesInDir:[CCCacheManager cachePath]];
        for (NSString *filePath in filePathArray) {
            _cacheSize += [[fileManager attributesOfItemAtPath:filePath error:NULL] fileSize];
        }
    });
}

- (BOOL)cacheData:(NSData *)data withFileName:(NSString *)fileName
{
    NSString *filePath = [[CCCacheManager cachePath] stringByAppendingPathComponent:fileName];
    return [self cacheData:data withPath:filePath];
}

- (void)cacheData:(NSData *)data withFileName:(NSString *)fileName callback:(block_cache_callback)bCallback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess = [self cacheData:data withFileName:fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bCallback) bCallback(isSuccess);
        });
    });
}

- (BOOL)cacheData:(NSData *)data withPath:(NSString *)filePath
{
    @try {
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
        } else {
            [data writeToFile:filePath atomically:YES];
        }
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
    }
}

- (void)cacheData:(NSData *)data withPath:(NSString *)filePath callback:(block_cache_callback)bCallback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess = [self cacheData:data withPath:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bCallback) bCallback(isSuccess);
        });
    });
}

- (NSData *)dataForFileName:(NSString *)fileName
{
    NSString *filePath = [[CCCacheManager cachePath] stringByAppendingPathComponent:fileName];
    return [self dataForFilePath:filePath];
}

- (NSData *)dataForFilePath:(NSString *)filePath
{
    @try {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        return fileExists ? [NSData dataWithContentsOfFile:filePath] : nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
    }
}

- (void)clearCache:(block_cache_clear)bClear
{
    __block NSArray *fileArray = [self getFilesInDir:[CCCacheManager cachePath]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *filePath in fileArray) {
            if ([fileManager fileExistsAtPath:filePath]) {
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bClear) bClear(YES);
        });
    });
}

// 获取指定文件夹下的所有文件，包括下级目录中的文件
- (NSArray *)getFilesInDir:(NSString *)cacheDir
{
    NSMutableArray *pathArray = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:cacheDir error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [cacheDir stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObject:[self getFilesInDir:fullPath]];
            }
        }
    }
    return pathArray;
}

@end
