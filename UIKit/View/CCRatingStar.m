//
//  CCRatingStar.m
//  CCSDK
//
//  Created by wangcong on 15/7/7.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCRatingStar.h"

#define FOREGROUND_STAR_IMAGE_NAME @"icon_ratingstar_sel"
#define BACKGROUND_STAR_IMAGE_NAME @"icon_ratingstar_nor"
#define DEFALUT_STAR_NUMBER 5
#define ANIMATION_TIME_INTERVAL 0.2

@interface CCRatingStar ()

@property (nonatomic, strong) UIView *foregroundStarView;
@property (nonatomic, strong) UIView *backgroundStarView;

@property (nonatomic, assign) NSInteger numberOfStars;

@end

@implementation CCRatingStar

#pragma mark - Init Methods
- (instancetype)init
{
    NSAssert(NO, @"You should never call this method in this class. Use initWithFrame: instead!");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStars:DEFALUT_STAR_NUMBER];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _numberOfStars = DEFALUT_STAR_NUMBER;
        [self buildDataAndUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars
{
    if (self = [super initWithFrame:frame]) {
        _numberOfStars = numberOfStars;
        [self buildDataAndUI];
    }
    return self;
}

#pragma mark - Private Methods

- (void)buildDataAndUI
{
    _scorePercent = 1;
    _hasAnimation = YES;
    _allowIncompleteStar = YES;
    _allowUserChange = NO;
    
    self.foregroundStarView = [self createStarViewWithImage:FOREGROUND_STAR_IMAGE_NAME];
    self.backgroundStarView = [self createStarViewWithImage:BACKGROUND_STAR_IMAGE_NAME];
    
    [self addSubview:self.backgroundStarView];
    [self addSubview:self.foregroundStarView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapRateView:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)userTapRateView:(UITapGestureRecognizer *)gesture
{
    if (_allowUserChange) {
        CGPoint tapPoint = [gesture locationInView:self];
        CGFloat offset = tapPoint.x;
        CGFloat realStarScore = offset / (self.bounds.size.width / self.numberOfStars);
        CGFloat starScore = self.allowIncompleteStar ? realStarScore : ceilf(realStarScore);
        self.scorePercent = starScore / self.numberOfStars;
    }
}

- (UIView *)createStarViewWithImage:(NSString *)imageName
{
    NSString *resource_path = [[NSBundle mainBundle] resourcePath];
    UIImage *image = [UIImage imageWithContentsOfFile:[resource_path stringByAppendingPathComponent:[NSString stringWithFormat:@"ccsdk.bundle/images/%@.png", imageName]]];
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    for (NSInteger i = 0; i < self.numberOfStars; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * self.bounds.size.width / self.numberOfStars, 0, self.bounds.size.width / self.numberOfStars, self.bounds.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:imageView];
    }
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    CGFloat animationTimeInterval = self.hasAnimation ? ANIMATION_TIME_INTERVAL : 0;
    [UIView animateWithDuration:animationTimeInterval animations:^{
        weakSelf.foregroundStarView.frame = CGRectMake(0, 0, weakSelf.bounds.size.width * weakSelf.scorePercent, weakSelf.bounds.size.height);
    }];
}

#pragma mark - Get and Set Methods
- (void)setScorePercent:(CGFloat)scroePercent
{
    if (_scorePercent == scroePercent) {
        return;
    }
    
    if (scroePercent < 0) {
        _scorePercent = 0;
    } else if (scroePercent > 1) {
        _scorePercent = 1;
    } else {
        _scorePercent = scroePercent;
    }
    
    if ([self.delegate respondsToSelector:@selector(ratingStar:scroePercentDidChange:)]) {
        [self.delegate ratingStar:self scroePercentDidChange:_scorePercent];
    }
    
    [self setNeedsLayout];
}

- (void)setForegroundImage:(UIImage *)foregroundImage
{
    _foregroundImage = foregroundImage;
    for (UIView *view in [self.foregroundStarView subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgv = (UIImageView *)view;
            imgv.image = _foregroundImage;
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    for (UIView *view in [self.backgroundStarView subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgv = (UIImageView *)view;
            imgv.image = _backgroundImage;
        }
    }
}

@end
