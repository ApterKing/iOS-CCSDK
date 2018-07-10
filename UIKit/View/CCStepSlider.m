//
//  CCStepSlider.m
//  CCSDK
//
//  Created by wangcong on 15-1-23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCStepSlider.h"

#define LEFT_OFFSET 25
#define RIGHT_OFFSET 25
#define TITLE_SELECTED_DISTANCE 5
#define TITLE_FADE_ALPHA .5f
#define TITLE_FONT [UIFont fontWithName:@"Optima" size:14]
#define TITLE_SHADOW_COLOR [UIColor lightGrayColor]
#define TITLE_COLOR [UIColor blackColor]

@interface CCStepSliderThumb : UIButton

@property(nonatomic, retain) UIColor *thumbColor;
@property(nonatomic, assign) CGFloat thumbRadius;

@end

@implementation CCStepSliderThumb

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbRadius = 10;
        [self setThumbColor:[UIColor colorWithRed:230 / 255.f green:230 / 255.f blue:230 / 255.f alpha:1.0f]];
    }
    return self;
}

- (void)setThumbColor:(UIColor *)thumbColor
{
    _thumbColor = nil;
    _thumbColor = thumbColor;
    [self setNeedsDisplay];
}

- (void)setThumbRadius:(CGFloat)thumbRadius
{
    _thumbRadius = thumbRadius;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画圆
    CGContextSaveGState(context);
    CGColorRef shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4f].CGColor;
    CGContextSetShadowWithColor(context, CGSizeMake(0, 7), _thumbRadius, shadowColor);
    
    CGContextSetStrokeColorWithColor(context, _thumbColor.CGColor);
    CGContextSetLineWidth(context, _thumbRadius / 2.0);
    CGContextStrokeEllipseInRect(context, CGRectMake(9.0f, 13, _thumbRadius, _thumbRadius));
    
    CGContextRestoreGState(context);
}

@end

@interface CCStepSlider ()
{
    CCStepSliderThumb *_sliderThumb;
    CGPoint diffPoint;
    NSArray *_titleArray;
    float oneSlotSize;
}

@end

@implementation CCStepSlider

- (CGPoint)getCenterPointForIndex:(int)index
{
    return CGPointMake((index/(float)(_titleArray.count - 1)) * (self.frame.size.width - RIGHT_OFFSET - LEFT_OFFSET) + LEFT_OFFSET, index==0 ? self.frame.size.height - 47 - TITLE_SELECTED_DISTANCE:self.frame.size.height - 47);
}

- (CGPoint)fixFinalPoint:(CGPoint)pnt
{
    if (pnt.x < LEFT_OFFSET - (_sliderThumb.frame.size.width/2.f)) {
        pnt.x = LEFT_OFFSET - (_sliderThumb.frame.size.width/2.f);
    } else if (pnt.x+(_sliderThumb.frame.size.width/2.f) > self.frame.size.width-RIGHT_OFFSET){
        pnt.x = self.frame.size.width-RIGHT_OFFSET- (_sliderThumb.frame.size.width/2.f);
    }
    return pnt;
}

- (instancetype) initWithFrame:(CGRect)frame titles:(NSArray *)titles
{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 70)]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _titleArray = [[NSArray alloc] initWithArray:titles];
        
        [self setSliderColor:[UIColor colorWithRed:103/255.f green:173/255.f blue:202/255.f alpha:1]];
        
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ItemSelected:)];
        [self addGestureRecognizer:gest];
        
        _sliderThumb = [CCStepSliderThumb buttonWithType:UIButtonTypeCustom];
        [_sliderThumb setFrame:CGRectMake(LEFT_OFFSET, 10, 35, 50)];
        [_sliderThumb setAdjustsImageWhenHighlighted:NO];
        [_sliderThumb setCenter:CGPointMake(_sliderThumb.center.x-(_sliderThumb.frame.size.width/2.f), self.frame.size.height-22.5f)];
        [_sliderThumb addTarget:self action:@selector(TouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_sliderThumb addTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_sliderThumb addTarget:self action:@selector(TouchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
        [self addSubview:_sliderThumb];
        
        int i;
        NSString *title;
        UILabel *lbl;
        
        oneSlotSize = 1.f*(self.frame.size.width-LEFT_OFFSET-RIGHT_OFFSET-1)/(_titleArray.count-1);
        for (i = 0; i < _titleArray.count; i++) {
            title = [_titleArray objectAtIndex:i];
            lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, oneSlotSize, 40)];
            [lbl setText:title];
            [lbl setFont:TITLE_FONT];
            [lbl setShadowColor:TITLE_SHADOW_COLOR];
            [lbl setTextColor:TITLE_COLOR];
            [lbl setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [lbl setAdjustsFontSizeToFitWidth:YES];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setShadowOffset:CGSizeMake(0, 1)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTag:i+50];
            
            if (i) {
                [lbl setAlpha:TITLE_FADE_ALPHA];
            }
            
            [lbl setCenter:[self getCenterPointForIndex:i]];
            
            
            [self addSubview:lbl];
            
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //填充路径
    
    CGContextSetFillColorWithColor(context, self.sliderColor.CGColor);
    
    CGContextFillRect(context, CGRectMake(LEFT_OFFSET, rect.size.height-32, rect.size.width-RIGHT_OFFSET-LEFT_OFFSET, 5));
    
    CGContextSaveGState(context);
    
    CGPoint centerPoint;
    int i;
    for (i = 0; i < _titleArray.count; i++) {
        centerPoint = [self getCenterPointForIndex:i];
        
        //画中间圆形
        
        CGContextSetFillColorWithColor(context, self.sliderColor.CGColor);
        
        CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x-8, rect.size.height/2, _sliderThumb.thumbRadius, _sliderThumb.thumbRadius));
        
    }
}

- (void)setThumbColor:(UIColor *)color
{
    [_sliderThumb setThumbColor:color];
}

- (void)setThumbRadius:(CGFloat)radius
{
    [_sliderThumb setThumbRadius:radius];
}

- (void)setTitleColor:(UIColor *)color
{
    int i;
    UILabel *lbl;
    for (i = 0; i < _titleArray.count; i++) {
        lbl = (UILabel *)[self viewWithTag:i+50];
        [lbl setTextColor:color];
    }
}

- (void)setTitleFont:(UIFont *)font
{
    int i;
    UILabel *lbl;
    for (i = 0; i < _titleArray.count; i++) {
        lbl = (UILabel *)[self viewWithTag:i+50];
        [lbl setFont:font];
    }
}

- (void) animateTitlesToIndex:(int) index
{
    int i;
    UILabel *lbl;
    for (i = 0; i < _titleArray.count; i++) {
        lbl = (UILabel *)[self viewWithTag:i+50];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        if (i == index) {
            [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height-47-TITLE_SELECTED_DISTANCE)];
            [lbl setAlpha:1];
        }else{
            [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height-47)];
            [lbl setAlpha:TITLE_FADE_ALPHA];
        }
        [UIView commitAnimations];
    }
}

- (void) animateHandlerToIndex:(int) index
{
    _selectedIndex = index;
    CGPoint toPoint = [self getCenterPointForIndex:index];
    toPoint = CGPointMake(toPoint.x-(_sliderThumb.frame.size.width/2.f), _sliderThumb.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    
    [UIView beginAnimations:nil context:nil];
    [_sliderThumb setFrame:CGRectMake(toPoint.x, toPoint.y, _sliderThumb.frame.size.width, _sliderThumb.frame.size.height)];
    [UIView commitAnimations];
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self animateTitlesToIndex:selectedIndex];
    [self animateHandlerToIndex:selectedIndex];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (int)getSelectedTitleInPoint:(CGPoint)pnt
{
    return round((pnt.x-LEFT_OFFSET)/oneSlotSize);
}

- (void) ItemSelected: (UITapGestureRecognizer *) tap
{
    [self setSelectedIndex:[self getSelectedTitleInPoint:[tap locationInView:self]]];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)TouchUp: (UIButton*) btn
{
    [self animateHandlerToIndex:[self getSelectedTitleInPoint:btn.center]];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (void) TouchDown: (UIButton *) btn withEvent: (UIEvent *) ev
{
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    diffPoint = CGPointMake(currPoint.x - btn.frame.origin.x, currPoint.y - btn.frame.origin.y);
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}


- (void)TouchMove: (UIButton *) btn withEvent: (UIEvent *)ev
{
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    
    CGPoint toPoint = CGPointMake(currPoint.x-diffPoint.x, _sliderThumb.frame.origin.y);
    
    toPoint = [self fixFinalPoint:toPoint];
    
    [_sliderThumb setFrame:CGRectMake(toPoint.x, toPoint.y, _sliderThumb.frame.size.width, _sliderThumb.frame.size.height)];
    
    _selectedIndex = [self getSelectedTitleInPoint:btn.center];
    
    [self animateTitlesToIndex:_selectedIndex];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

- (void)dealloc
{
    [_sliderThumb removeTarget:self action:@selector(TouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [_sliderThumb removeTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_sliderThumb removeTarget:self action:@selector(TouchMove:withEvent: ) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
}

@end
