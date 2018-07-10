//
//  CCProgressView.m
//  CCSDK
//
//  Created by wangcong on 15/8/25.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCProgressView.h"

#define kCCProgressFillColor                [UIColor clearColor]
#define kCCProgressTintColor                [UIColor colorWithRGBHexString:@"#F9A953"]
#define kCCTrackTintColor                   [UIColor colorWithRGBHexString:@"#EFEFEF"]

#define kAnimTimeInterval 0.35

@interface CCProgressView ()

@property(nonatomic, strong) CAShapeLayer *trackLayer;
@property(nonatomic, strong) CAShapeLayer *progressLayer;
@property(nonatomic, strong) CATextLayer *textLayer;

@end

@implementation CCProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self initSubviews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

#pragma mark - private
- (void)initSubviews
{
    _progressViewStyle = CCProgressViewStyleDefault;
    _progressTintColor = kCCProgressTintColor;
    _trackTintColor = kCCTrackTintColor;
    _lineWidth = 10;
    
    _fillColor = kCCProgressFillColor;
    _clockwise = YES;
    _startAngle = - M_PI / 2.0;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.lineCap = kCALineCapButt;
    self.trackLayer.lineJoin = kCALineCapButt;
    self.trackLayer.lineWidth = _lineWidth;
    self.trackLayer.fillColor = nil;
    self.trackLayer.strokeColor = _trackTintColor.CGColor;
    self.trackLayer.frame = self.bounds;
    [self.layer addSublayer:self.trackLayer];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.lineCap = kCALineCapButt;
    self.progressLayer.lineJoin = kCALineCapButt;
    self.progressLayer.lineWidth = _lineWidth;
    self.progressLayer.fillColor = _fillColor.CGColor;
    self.progressLayer.strokeColor = _progressTintColor.CGColor;
    self.progressLayer.frame = self.bounds;
    [self.layer addSublayer:self.progressLayer];
    
    self.progressLayer.strokeEnd = 0.0;
    
    self.textLayer = [CATextLayer layer];
    self.textLayer.alignmentMode = kCATruncationMiddle;
    self.textLayer.hidden = YES;
    self.textLayer.fontSize = 14;
    self.textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    self.textLayer.wrapped = YES;
    self.textLayer.anchorPoint = CGPointMake(.5, .5);
    [self.layer addSublayer:self.textLayer];
    [self _setTextLayerString:@"0%"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _updateLayerPath];
}

#pragma mark - private
- (void)_updateLayerPath
{
    if (_progressViewStyle == CCProgressViewStyleCircle) {
        self.trackLayer.frame = self.bounds;
        self.progressLayer.frame = self.bounds;
        
        CGFloat radius = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ?
        (CGRectGetHeight(self.frame) - _lineWidth) / 2.0 : (CGRectGetWidth(self.frame) - _lineWidth) / 2.0;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:self.progressLayer.position radius:radius startAngle:_startAngle endAngle:_clockwise ? _startAngle + 2 * M_PI : _startAngle - 2 * M_PI clockwise:_clockwise];
        self.trackLayer.path = bezierPath.CGPath;
        self.progressLayer.path = bezierPath.CGPath;
    } else {
        self.trackLayer.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _lineWidth) / 2.0, CGRectGetWidth(self.frame), _lineWidth);
        self.progressLayer.frame = self.trackLayer.frame;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, self.progressLayer.position.y)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.progressLayer.position.y)];
        self.trackLayer.path = bezierPath.CGPath;
        self.progressLayer.path = bezierPath.CGPath;
    }
}

#pragma mark - setter
- (void)setProgressViewStyle:(CCProgressViewStyle)progressViewStyle
{
    _progressViewStyle = progressViewStyle;
    if (_progressViewStyle == CCProgressViewStyleCircle && self.showProgress) {
        self.textLayer.hidden = NO;
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    _trackTintColor = trackTintColor;
    self.trackLayer.strokeColor = trackTintColor.CGColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    self.progressLayer.strokeColor = progressTintColor.CGColor;
}

- (void)setProgressFullTintColor:(UIColor *)progressFullTintColor
{
    _progressFullTintColor = progressFullTintColor;
    if (self.progressLayer.strokeEnd >= 1.0) {
        self.progressLayer.strokeEnd = 1.0;
        self.progressLayer.strokeColor = _progressFullTintColor.CGColor;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    self.trackLayer.lineWidth = lineWidth;
    self.progressLayer.lineWidth = lineWidth;
    if (_progressViewStyle != CCProgressViewStyleCircle) {
        [self _updateLayerPath];
    }
}

#pragma mark - setter (CCProgressViewStyleCircle)
- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    self.progressLayer.fillColor = fillColor.CGColor;
}

- (void)setClockwise:(BOOL)clockwise
{
    _clockwise = clockwise;
    [self _updateLayerPath];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    [self _updateLayerPath];
}

- (void)setShowProgress:(BOOL)showProgress
{
    _showProgress = showProgress;
    if (_progressViewStyle == CCProgressViewStyleCircle && showProgress) {
//        self.textLayer.hidden = NO;
    }
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
//    self.textLayer.string = [NSString stringWithFormat:@"%.f%@", progress * 100, @"%"];
    if (animated) {
        POPBasicAnimation *basicAnim = [self.progressLayer pop_animationForKey:kPOPShapeLayerStrokeEnd];
        if (basicAnim) {
            basicAnim.duration = kAnimTimeInterval;
            basicAnim.fromValue = @(self.progressLayer.strokeEnd);
            basicAnim.toValue = @(progress);
        } else {
            basicAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
            basicAnim.duration = 2 * kAnimTimeInterval;
            basicAnim.toValue = @(progress);
            basicAnim.removedOnCompletion = NO;
        }
        @weakify(self);
        basicAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            @strongify(self);
            POPPropertyAnimation *basicAnim = (POPPropertyAnimation *)anim;
            self.progressLayer.strokeEnd = [basicAnim.toValue doubleValue];
            if (self.progressLayer.strokeEnd >= 1.0 && _progressFullTintColor) {
                self.progressLayer.strokeEnd = 1.0;
                self.progressLayer.strokeColor = _progressFullTintColor.CGColor;
            }
            
//            if (self.progressViewStyle == CCProgressViewStyleCircle && self.showProgress) {
//                [self _setTextLayerString:[NSString stringWithFormat:@"%.f%@", self.progressLayer.strokeEnd * 100, @"%"]];
//            }
        };
        [self.progressLayer pop_addAnimation:basicAnim forKey:kPOPShapeLayerStrokeEnd];
    } else {
        self.progressLayer.strokeEnd = progress;
        if (self.progressLayer.strokeEnd >= 1.0 && _progressFullTintColor) {
            self.progressLayer.strokeEnd = 1.0;
            self.progressLayer.strokeColor = _progressFullTintColor.CGColor;
        }
        
//        if (self.progressViewStyle == CCProgressViewStyleCircle && self.showProgress) {
//            [self _setTextLayerString:[NSString stringWithFormat:@"%.f%@", self.progressLayer.strokeEnd * 100, @"%"]];
//        }
    }
}

- (void)_setTextLayerString:(NSString *)string
{
    self.textLayer.string = string;
    
    CGSize size = [string textSizeWithFont:[UIFont systemFontOfSize:self.textLayer.fontSize] constrainedToSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) lineBreakMode:NSLineBreakByCharWrapping];
    self.textLayer.size = size;
    self.textLayer.position = CGPointMake((CGRectGetWidth(self.bounds) - size.width) / 2.0, (CGRectGetHeight(self.bounds) - size.height) / 2.0);
}

- (void)setLineCap:(NSString *)lineCap {
    _lineCap = lineCap;
    self.trackLayer.lineCap = lineCap;
    self.progressLayer.lineCap = lineCap;
}

- (void)setLineJoin:(NSString *)lineJoin {
    _lineJoin = lineJoin;
    self.trackLayer.lineJoin = lineJoin;
    self.progressLayer.lineJoin = lineJoin;
}

@end
