//
//  CCPBLoadingView.m
//  CCSDK
//
//  Created by wangcong on 15/9/30.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCPBLoadingView.h"

#define kCCProgressFillColor                [UIColor clearColor]
#define kCCProgressTintColor                [UIColor colorWithRGBHexString:@"#F8F8F8"]
#define kCCTrackTintColor                   [UIColor colorWithRGBHexString:@"#708090"]

#define kAnimTimeInterval 0.35

@interface CCPBLoadingView ()

@property(nonatomic, strong) CAShapeLayer *trackLayer;
@property(nonatomic, strong) CAShapeLayer *progressLayer;
@property(nonatomic, strong) UILabel *textLabel;

@property(nonatomic, assign) BOOL clockwise;
@property(nonatomic, assign) CGFloat startAngle;

@end

@implementation CCPBLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _progressTintColor = kCCProgressTintColor;
        _trackTintColor = kCCTrackTintColor;
        _textColor = [UIColor whiteColor];
        _lineWidth = 2;
        
        _clockwise = YES;
        _startAngle = - M_PI / 2.0;
        
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
    self.backgroundColor = [UIColor clearColor];
    
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.lineCap = kCALineCapButt;
    self.trackLayer.lineJoin = kCALineCapButt;
    self.trackLayer.lineWidth = _lineWidth;
    self.trackLayer.fillColor = kCCProgressFillColor.CGColor;
    self.trackLayer.strokeColor = _trackTintColor.CGColor;
    self.trackLayer.frame = self.bounds;
    [self.layer addSublayer:self.trackLayer];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.lineCap = kCALineCapButt;
    self.progressLayer.lineJoin = kCALineCapButt;
    self.progressLayer.lineWidth = _lineWidth;
    self.progressLayer.fillColor = kCCProgressFillColor.CGColor;
    self.progressLayer.strokeColor = _progressTintColor.CGColor;
    self.progressLayer.frame = self.bounds;
    [self.layer addSublayer:self.progressLayer];
    self.progressLayer.strokeEnd = 0.0;
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:IS_IPHONE_5_OR_LESS ? 15 : 16];
    self.textLabel.textColor = _textColor;
    self.textLabel.text = @"0%";
    self.textLabel.frame = self.bounds;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.textLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
    [self _updateLayerPath];
}

#pragma mark - private
- (void)_updateLayerPath
{
    self.trackLayer.frame = self.bounds;
    self.progressLayer.frame = self.bounds;
    
    CGFloat radius = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ?
    (CGRectGetHeight(self.frame) - _lineWidth) / 2.0 : (CGRectGetWidth(self.frame) - _lineWidth) / 2.0;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:self.progressLayer.position radius:radius startAngle:_startAngle endAngle:_clockwise ? _startAngle + 2 * M_PI : _startAngle - 2 * M_PI clockwise:_clockwise];
    self.trackLayer.path = bezierPath.CGPath;
    self.progressLayer.path = bezierPath.CGPath;
}

#pragma mark - setter
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

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    self.trackLayer.lineWidth = lineWidth;
    self.progressLayer.lineWidth = lineWidth;
    [self _updateLayerPath];
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        POPBasicAnimation *basicAnim = [self.progressLayer pop_animationForKey:kPOPShapeLayerStrokeEnd];
        if (basicAnim) {
            basicAnim.duration = kAnimTimeInterval;
            basicAnim.fromValue = @(self.progressLayer.strokeEnd);
            basicAnim.toValue = @(progress);
        } else {
            basicAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
            basicAnim.duration = 4 * kAnimTimeInterval;
            basicAnim.toValue = @(progress);
            basicAnim.removedOnCompletion = NO;
        }
        @weakify(self);
        basicAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            @strongify(self);
            POPPropertyAnimation *basicAnim = (POPPropertyAnimation *)anim;
            self.progressLayer.strokeEnd = [basicAnim.toValue doubleValue];
            if (self.progressLayer.strokeEnd >= 1.0) {
                self.progressLayer.strokeEnd = 1.0;
            }
            self.textLabel.text = [NSString stringWithFormat:@"%.f%@", self.progressLayer.strokeEnd * 100, @"%"];
        };
        [self.progressLayer pop_addAnimation:basicAnim forKey:kPOPShapeLayerStrokeEnd];
    } else {
        self.progressLayer.strokeEnd = progress;
        if (self.progressLayer.strokeEnd >= 1.0) {
            self.progressLayer.strokeEnd = 1.0;
        }
        self.textLabel.text = [NSString stringWithFormat:@"%.f%@", self.progressLayer.strokeEnd * 100, @"%"];
    }
}

@end
