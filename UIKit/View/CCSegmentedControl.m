//
//  CCSegmentedControl.m
//  CCSDK
//
//  Created by wangcong on 16/1/12.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import "CCSegmentedControl.h"
#import "UIColor+CCCategory.h"
#import "UIFont+CCCategory.h"
#import "NSString+CCCategory.h"
#import "CCSDKDefines.h"

#define kSegmentedMarginLR (IS_IPHONE_5_OR_LESS ? 5 : 7)

@interface CCSegmentedControl ()<UIScrollViewDelegate>

// 标题
@property (nonatomic, strong) NSMutableArray *items;

// 标题的UILabel
@property (nonatomic, strong) NSMutableArray *itemButtons;

// scrollView
@property (nonatomic, strong) UIScrollView *scrollView;

// 左右遮罩
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *rightMaskView;

@end

@implementation CCSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = [NSMutableArray arrayWithArray:[items copy]];
        
        [self _initSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
//    [self _applyGradient];
    [self _applyItems];
    [self setSelectedIndex:self.selectedIndex];
    
    CGFloat maxX = 0;
    for (UIButton *button in self.scrollView.subviews) {
        if (![button isKindOfClass:[UIButton class]]) continue;
        if (CGRectGetMaxX(button.frame) > maxX) {
            maxX = CGRectGetMaxX(button.frame);
        }
    }
    
    if (maxX < self.frame.size.width) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, (self.frame.size.width - maxX) / 2, 0, 0);
    }
}

- (void)_initSubviews {
    _gradientOffset = CGRectGetHeight(self.frame);
    _gradientPercentage = 0.3;
    _gradientColor = [UIColor whiteColor];
    _font = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 18 : 19.5];
    _scaleSelectedItemFont = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 21.5 : 23];
    _textColor = [UIColor colorWithRGBHexString:@"#a0a0a0"];
    _highlightedTextColor = [UIColor colorWithRGBHexString:@"#fb5f46"];
    self.edgeMargin = 0;
    self.selectedIndex = 0;
    
    // 添加控件
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
}

#pragma mark - setter
- (void)setGradientColor:(UIColor *)gradientColor {
    _gradientColor = gradientColor;
    [self _applyGradient];
}

- (void)setGradientPercentage:(CGFloat)gradientPercentage {
    _gradientPercentage  = gradientPercentage;
    [self _applyGradient];
}

- (void)setEdgeMargin:(CGFloat)edgeMargin {
    NSMutableString *itemString = [NSMutableString string];
    for (NSString *item in self.items) {
        [itemString appendString:item];
    }
    
    CGSize size = [itemString textSizeWithFont:self.font constrainedToSize:CGSizeMake(APP_WIDTH * 3, CGRectGetHeight(self.frame)) lineBreakMode:NSLineBreakByCharWrapping];
    _edgeMargin = size.width + (self.items.count - 1) * edgeMargin - 2 * kSegmentedMarginLR < CGRectGetWidth(self.frame) ? (CGRectGetWidth(self.frame) - size.width - 2 * kSegmentedMarginLR) / (self.items.count - 1) : edgeMargin;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    for (UIButton *button in self.itemButtons) {
        if (button.selected) {   // 如果上次选中是放大了文字则改为正常大小
            [UIView animateWithDuration:.25f animations:^{
                button.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            }];
        }
        button.selected = _selectedIndex == button.tag;
        if (button.selected) {
            [self _scrollItemVisible:button];
            [UIView animateWithDuration:.25f animations:^{
                button.transform = CGAffineTransformMakeScale(self.scaleSelectedItemFont.pointSize / self.font.pointSize, self.scaleSelectedItemFont.pointSize / self.font.pointSize);
            }];
        }
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (UIButton *button in self.itemButtons) {
        [button setTitleColor:textColor forState:UIControlStateNormal];
    }
    [self _applyItems];
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor {
    _highlightedTextColor = highlightedTextColor;
    for (UIButton *button in self.itemButtons) {
        [button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
        [button setTitleColor:highlightedTextColor forState:UIControlStateSelected];
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    for (UIButton *button in self.itemButtons) {
        button.titleLabel.font = font;
    }
    [self _applyItems];
}

- (void)setScaleSelectedItemFont:(UIFont *)scaleSelectedItemFont {
    _scaleSelectedItemFont = scaleSelectedItemFont;
    for (UIButton *button in self.itemButtons) {
        button.titleLabel.font = self.font;
        if (button.isSelected) {
            [UIView animateWithDuration:.25f animations:^{
                button.transform = CGAffineTransformMakeScale(self.scaleSelectedItemFont.pointSize / self.font.pointSize, self.scaleSelectedItemFont.pointSize / self.font.pointSize);
            }];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UIButton *button in self.itemButtons) {
        if (button.selected) {
            [self _scrollItemVisible:button];
            break;
        }
    }
}

// 滑动到课件的item位置处
- (void)_scrollItemVisible:(UIButton *)item {
    CGRect frame = item.frame;
    if (item != self.scrollView.subviews.firstObject && item != self.scrollView.subviews.lastObject) {
        CGFloat min = CGRectGetMinX(item.frame);
        CGFloat max = CGRectGetMaxX(item.frame);
        
        if (min < self.scrollView.contentOffset.x) {
            frame = (CGRect){{item.frame.origin.x - 25, item.frame.origin.y}, item.frame.size};
        } else if (max > self.scrollView.contentOffset.x + self.scrollView.frame.size.width) {
            frame = (CGRect){{item.frame.origin.x + 25, item.frame.origin.y}, item.frame.size};
        }
    }
    
    [self.scrollView scrollRectToVisible:frame animated:YES];
//    [self _updateGradientsItem:item];
}

// 更新左右maskView透明度
- (void)_updateGradientsItem:(UIButton *)item {
    CGRect frame = [item convertRect:item.frame toView:self];
    CGFloat x = CGRectGetMinX(frame);
    self.leftMaskView.alpha = x < _gradientOffset ? 0.0 : 1.0;
    self.rightMaskView.alpha = x > CGRectGetWidth(self.frame) - _gradientOffset ? 0.0 : 1.0;
}

// items
- (void)_applyItems {
    if (self.items == nil) return;
    if (!self.itemButtons) {
        // 添加对应的item控件
        self.itemButtons = [NSMutableArray arrayWithCapacity:self.items.count];
        for (int i = 0; i < self.items.count; i++) {
            UIButton *button = [[UIButton alloc] init];
            button.tag = i;
            [button addTarget:self action:@selector(_didSelectedIndex:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            [self.itemButtons addObject:button];
        }
    }
    
    // 设置frame
    CGFloat x = kSegmentedMarginLR;
    for (NSInteger i = 0; i < self.itemButtons.count; i++) {
        UIButton *button = self.itemButtons[i];
        [button setTitle:self.items[i] forState:UIControlStateNormal];
        [button setTitleColor:_textColor forState:UIControlStateNormal];
        [button setTitleColor:_highlightedTextColor forState:UIControlStateHighlighted];
        [button setTitleColor:_highlightedTextColor forState:UIControlStateSelected];
        button.titleLabel.font = self.font;
        
        NSString *title = self.items[i];
        CGSize size = [title textSizeWithFont:self.font constrainedToSize:CGSizeMake(APP_WIDTH, APP_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
        button.frame = CGRectMake(x, 0, size.width, CGRectGetHeight(self.frame));
        x += size.width + self.edgeMargin;
    }
    
    self.scrollView.contentSize = CGSizeMake(x - self.edgeMargin + kSegmentedMarginLR, CGRectGetHeight(self.frame));
    if (x <= self.frame.size.width) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, (self.frame.size.width - x) / 2, 0, 0);
    } else {
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
}
         
// 选中
- (void)_didSelectedIndex:(UIButton *)item {
    [self setSelectedIndex:item.tag];
    if (_didSelectedIndex) {
        _didSelectedIndex(self, item.tag);
    }
}

// 设置左右边缘
- (void)_applyGradient {
    CGFloat leftAlpha = 0.7;
    if (self.leftMaskView) {
        leftAlpha = self.leftMaskView.alpha;
        [self.leftMaskView removeFromSuperview];
        self.leftMaskView = nil;
    }
    
    CGFloat rightAlpha = 0.7;
    if (self.rightMaskView) {
        rightAlpha = self.rightMaskView.alpha;
        [self.rightMaskView removeFromSuperview];
        self.rightMaskView = nil;
    }
    
    self.leftMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame))];
    self.leftMaskView.userInteractionEnabled = NO;
    self.leftMaskView.alpha = leftAlpha;
    self.leftMaskView.backgroundColor = _gradientColor;
    self.leftMaskView.layer.mask = [self _gradientLayerForBounds:self.leftMaskView.bounds inVector:CGVectorMake(0.0, _gradientPercentage) withColors:@[_gradientColor, [UIColor clearColor]]];
    [self insertSubview:self.leftMaskView aboveSubview:self.scrollView];
    
    self.rightMaskView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2.0, 0, CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame))];
    self.rightMaskView.userInteractionEnabled = NO;
    self.rightMaskView.alpha = rightAlpha;
    self.rightMaskView.backgroundColor = self.gradientColor;
    self.rightMaskView.layer.mask = [self _gradientLayerForBounds:self.rightMaskView.bounds inVector:CGVectorMake(1.0 - _gradientPercentage, 1.0) withColors:@[[UIColor clearColor], _gradientColor]];
    [self insertSubview:self.rightMaskView aboveSubview:self.scrollView];
}

// gradient maskView
- (CAGradientLayer *)_gradientLayerForBounds:(CGRect)bounds inVector:(CGVector)vector withColors:(NSArray *)colors {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = [NSArray arrayWithObjects:
                      [NSNumber numberWithFloat:vector.dx],
                      [NSNumber numberWithFloat:vector.dy],
                      nil];
    
    mask.colors = [NSArray arrayWithObjects:
                   (__bridge id)((UIColor *)colors.firstObject).CGColor,
                   (__bridge id)((UIColor *)colors.lastObject).CGColor,
                   nil];
    
    mask.frame = bounds;
    mask.startPoint = CGPointMake(0, 0);
    mask.endPoint = CGPointMake(1, 0);
    return mask;
}

@end
