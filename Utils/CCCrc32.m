//
//  CCCrc32.m
//  CCSDK
//
//  Created by wangcong on 16/3/16.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import "CCCrc32.h"

@interface CCCrc32Inner : NSObject<NSStreamDelegate>

@property (nonatomic, strong) NSInputStream           *inputStream;
@property (nonatomic, assign) uLong                   crc32;
@property (nonatomic, copy  ) CCCrc32CompletedHandler handler;
@property (nonatomic, assign) BOOL                    isFinished;

- (void)crc32WithFileAtPath:(NSString *)filePath handler:(CCCrc32CompletedHandler)handler;

- (void)crc32WithURL:(NSURL *)url handler:(CCCrc32CompletedHandler)handler;

- (void)crc32WithData:(NSData *)data handler:(CCCrc32CompletedHandler)handler;

@end

@implementation CCCrc32Inner

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)crc32WithFileAtPath:(NSString *)filePath handler:(CCCrc32CompletedHandler)handler {
    self.handler = handler;
    self.inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    while (!self.isFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)crc32WithURL:(NSURL *)url handler:(CCCrc32CompletedHandler)handler {
    self.handler = handler;
    self.inputStream = [NSInputStream inputStreamWithURL:url];
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    while (!self.isFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)crc32WithData:(NSData *)data handler:(CCCrc32CompletedHandler)handler {
    self.handler = handler;
    self.inputStream = [NSInputStream inputStreamWithData:data];
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    while (!self.isFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            self.crc32 = crc32(0, Z_NULL, 0);
            break;
        case NSStreamEventHasBytesAvailable:
        {
            NSInputStream *inputStream = (NSInputStream *)aStream;
            uint8_t buffer[8 * 1024];
            NSInteger byteReaded = 0;
            if ((byteReaded = [inputStream read:buffer maxLength:8 * 1024]) > 0) {
                self.crc32 = crc32(self.crc32, buffer, (uInt)byteReaded);
            }
            break;
        }
        case NSStreamEventErrorOccurred:
            self.isFinished = YES;
            if (self.handler) self.handler(self.crc32);
            break;
        case NSStreamEventEndEncountered:
            self.isFinished = YES;
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            if (self.handler) self.handler(self.crc32);
            break;
        default:
            break;
    }
}

@end

@implementation CCCrc32

+ (uLong)crc32WithFilePath:(NSString *)filePath {
    return [self crc32WithData:[NSData dataWithContentsOfFile:filePath]];
}

+ (uLong)crc32WithURL:(NSURL *)url {
    return [self crc32WithData:[NSData dataWithContentsOfURL:url]];
}

+ (uLong)crc32WithData:(NSData *)data {
    uLong crc = crc32(0, Z_NULL, 0);
    return crc32(crc, data.bytes, (uInt)data.length);
}

+ (void)crc32WithFileAtPath:(NSString *)filePath handler:(CCCrc32CompletedHandler)handler {
    CCCrc32Inner *crc32Inner = [[CCCrc32Inner alloc] init];
    [crc32Inner crc32WithFileAtPath:filePath handler:handler];
}

+ (void)crc32WithURL:(NSURL *)url handler:(CCCrc32CompletedHandler)handler {
    CCCrc32Inner *crc32Inner = [[CCCrc32Inner alloc] init];
    [crc32Inner crc32WithURL:url handler:handler];
}

+ (void)crc32WithData:(NSData *)data handler:(CCCrc32CompletedHandler)handler {
    CCCrc32Inner *crc32Inner = [[CCCrc32Inner alloc] init];
    [crc32Inner crc32WithData:data handler:handler];
}

@end
