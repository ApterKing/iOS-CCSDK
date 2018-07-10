//
//  CCTextField.m
//  CCSDK
//
//  Created by wangcong on 15/6/30.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCTextField.h"

@implementation CCTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
        self.font = [UIFont systemFontOfSize:15];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,
                       self.paddingX == 0.0f ? kTextFieldPaddingWidth : self.paddingX,
                       self.paddingY == 0.0f ? kTextFieldPaddingHeight : self.paddingY);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,
                       self.paddingX == 0.0f ? kTextFieldPaddingWidth : self.paddingX,
                       self.paddingY == 0.0f ? kTextFieldPaddingHeight : self.paddingY);
}

- (void)setPaddingX:(CGFloat)paddingX
{
    self.paddingX = paddingX;
    [self setNeedsDisplay];
}

- (void)setPaddingY:(CGFloat)paddingY
{
    self.paddingY = paddingY;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
}

- (void)textChanged:(NSNotification *)notification
{
    if (self.limitLength != 0) {
        UITextRange *markedTextRange = self.markedTextRange;
        NSString *text = self.text;
        if (markedTextRange == nil && text.length && text.length >= self.limitLength) {
            self.text = [text substringToIndex:self.limitLength];
        }
    }
}

@end
