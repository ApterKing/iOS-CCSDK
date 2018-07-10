//
//  CCTextView.m
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCTextView.h"

@interface CCTextView ()

@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation CCTextView


- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubview];
    }
    return self;
}

- (void)awakeFromNib

{
    [super awakeFromNib];
    [self _initSubview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.placeholderLabel.frame = CGRectMake(5, 6, CGRectGetWidth(self.frame) - 10, 20);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_initSubview
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, CGRectGetWidth(self.frame) - 10, 20)];
    self.placeholderLabel.textAlignment = NSTextAlignmentLeft;
    self.placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.placeholderLabel.adjustsFontSizeToFitWidth = YES;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0) {
        return;
    }
    if([[self text] length] == 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;
    }
    
    if (self.limitLength != 0) {
        UITextRange *markedTextRange = self.markedTextRange;
        NSString *text = self.text;
        if (markedTextRange == nil && text.length && text.length > self.limitLength) {
            self.text = [text substringToIndex:self.limitLength];
        }
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textChanged:nil];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeholderLabel.font = font;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self textChanged:nil];
}

@end
