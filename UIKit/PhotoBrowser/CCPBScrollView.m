//
//  CCPBScrollView.m
//  CCSDK
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPBScrollView.h"
#import "CCPBPageView.h"

@interface CCPBScrollView ()

@property (nonatomic, assign) BOOL isScrollToIndex;

@end

@implementation CCPBScrollView

- (instancetype)init {
    return [[self.class alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = NO;
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    __block CGRect frame = self.bounds;
    CGFloat w = CGRectGetWidth(frame);
    frame.size.width = w - 10;
    __block int count = 0;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CCPBPageView class]]) {
            CCPBPageView *pageView = (CCPBPageView *)obj;
            pageView.tag = count;
            CGFloat x = w * pageView.pageIndex;
            frame.origin.x = x;
            [UIView animateWithDuration:0.01 animations:^{
                pageView.frame = frame;
            }];
            count += 1;
        }
    }];
    
    // 第一次加载的时候滑动到指定页面
    if(!_isScrollToIndex) {
        CGFloat offsetX = w * _index;
        [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        _isScrollToIndex = YES;
    }
}

#pragma mark - public
- (void)saveImageToAlbum {
    NSArray *subviews = self.subviews;
    for (id obj in subviews) {
        if ([obj isKindOfClass:[CCPBPageView class]]) {
            CCPBPageView *pageView = (CCPBPageView *)obj;
            if (pageView.tag == self.index) {
                [pageView saveImageToAlbum];
                break;
            }
        }
    }
}

@end
