//
//  CCSpecialTextView.m
//  CCSDK
//
//  Created by wangcong on 15/11/12.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCSpecialTextView.h"

#pragma mark 自定义NSTextStorage
@interface CCTextStorage : NSTextStorage
{
    NSMutableAttributedString *_storingText;    // 存储的文字
    BOOL _dynamicTextNeedsUpdate;               // 文字是否需要更新
}

@property(nonatomic, strong) NSMutableDictionary *attributes;

// 需要高亮标识的正则表达式
@property(nonatomic, strong) NSString *regexPattern;

@end

@implementation CCTextStorage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _storingText = [[NSMutableAttributedString alloc] init];
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

// 返回保存的文字
- (NSString *)string
{
    return [_storingText string];
}

// 获取指定范围内的文字属性
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_storingText attributesAtIndex:location effectiveRange:range];
}

// override 设置指定范围内的文字属性
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_storingText setAttributes:attrs range:range];
    // Notifies and records a recent change.  If there are no outstanding -beginEditing calls, this method calls -processEditing to trigger post-editing processes.  This method has to be called by the primitives after changes are made if subclassed and overridden.  editedRange is the range in the original string (before the edit).
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

// 修改指定范围内的文字
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_storingText replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedAttributes | NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
    [self endEditing];
}

#pragma mark - Syntax Highlighting
- (void)processEditing
{
    if (_dynamicTextNeedsUpdate && self.regexPattern && ![self.regexPattern isEqualToString:@""]) {
        _dynamicTextNeedsUpdate = NO;
        NSRegularExpression *regExpression = [NSRegularExpression regularExpressionWithPattern:self.regexPattern options:NSRegularExpressionCaseInsensitive error:NULL];
        
        NSRange paragaphRange = [self.string paragraphRangeForRange:self.editedRange];
        [self removeAttribute:NSForegroundColorAttributeName range:paragaphRange];
        
        [regExpression enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString *resultString = [self.string substringWithRange:result.range];
            
            NSArray *attributeKeys = [self.attributes allKeys];
            for (NSString *string in attributeKeys) {
                if ([string isEqualToString:resultString]) {
                    [self addAttributes:[self.attributes objectForKey:string] range:result.range];
                    break;
                }
            }
        }];
    }
    [super processEditing];
}

@end

@interface CCSpecialTextView ()<UITextViewDelegate>

@property(nonatomic, strong) NSTextContainer *textContainer;
@property(nonatomic, strong) CCTextStorage *textStorage;

// 提示Label
@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation CCSpecialTextView

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
    self.textContainer.size = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
    self.textView.frame = self.bounds;
    self.placeholderLabel.frame = CGRectMake(5, 5, CGRectGetWidth(self.frame) - 10, 20);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_initSubview
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    // 初始化NSTextContainer new in IOS7.0
    self.textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX)];
    self.textContainer.widthTracksTextView = YES;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:self.textContainer];
    self.textStorage = [[CCTextStorage alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    _textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:self.textContainer];
    _textView.delegate = self;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _textView.scrollEnabled = YES;
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textColor = [UIColor darkTextColor];
    [self addSubview:_textView];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.frame) - 10, 20)];
    self.placeholderLabel.textAlignment = NSTextAlignmentLeft;
    self.placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.placeholderLabel.adjustsFontSizeToFitWidth = YES;
    self.placeholderLabel.font = [UIFont systemFontOfSize:14];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
}

#pragma mark - private
- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0) return;
    
    if([_textView.text length] == 0 && self.textStorage.string.length == 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;
    }
    
    if (self.limitLength != 0) {
        UITextRange *markedTextRange = _textView.markedTextRange;
        NSString *text = _textView.text;
        if (markedTextRange == nil && text.length && text.length > self.limitLength) {
            _textView.text = [text substringToIndex:self.limitLength];
        }
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""]) {   // 退格键
        NSRange selectionRange = textView.selectedRange;
        
        // 处理相关字符串数据
        NSArray *attributekeys = [self.textStorage.attributes allKeys];
        for (NSString *string in attributekeys) {
            NSRange range = [self.textStorage.string rangeOfString:string];
            if (range.location < selectionRange.location && range.location + range.length + 1 > selectionRange.location) {
                [self _delAttributesForPattern:string inRange:range byHand:YES];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - public setter
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self textChanged:nil];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.textView.font = font;
    self.placeholderLabel.font = font;
    
    // force
    _textView.text = _textView.text;
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
    
    [self textChanged:nil];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textView.textColor = textColor;
    
    // force
    _textView.text = _textView.text;
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes
{
    _dataDetectorTypes = dataDetectorTypes;
    self.textView.dataDetectorTypes = dataDetectorTypes;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView
{
    _inputAccessoryView = inputAccessoryView;
    self.textView.inputAccessoryView = inputAccessoryView;
}

#pragma mark - public getter
- (NSString *)text {
    return self.textView.text;
}

#pragma mark - public string pattern
- (NSDictionary *)attributesForPattern:(NSString *)pattern
{
    return [self.textStorage.attributes objectForKey:pattern];
}

- (void)addAttributes:(NSDictionary *)attributes forPattern:(NSString *)pattern
{
    [self.textStorage.attributes setObject:attributes forKey:pattern];
    NSArray *attributeKeys = [self.textStorage.attributes allKeys];
    self.textStorage.regexPattern = [attributeKeys.rac_sequence foldLeftWithStart:@"" reduce:^id(id accumulator, id value) {
        return [NSString stringWithFormat:@"%@%@%@", accumulator, [accumulator isEqualToString:@""] ? @"" : @"|", value];
    }];
}

- (void)delAttributesForPattern:(NSString *)pattern {
    NSRange range = [self.textStorage.string rangeOfString:pattern];
    [self _delAttributesForPattern:pattern inRange:range byHand:NO];
}

#pragma mark - private
- (void)_delAttributesForPattern:(NSString *)regexPattern inRange:(NSRange)range byHand:(BOOL)byHand
{
    NSArray *attributeKeys = [self.textStorage.attributes allKeys];
    for (NSString *string in attributeKeys) {
        if ([string isEqualToString:regexPattern]) {
            [self.textStorage.attributes removeObjectForKey:string];
            break;
        }
    }
    self.textStorage.regexPattern = [[self.textStorage.attributes allKeys].rac_sequence foldLeftWithStart:@"" reduce:^id(id accumulator, id value) {
        return [NSString stringWithFormat:@"%@%@%@", accumulator, [accumulator isEqualToString:@""] ? @"" : @"|", value];
    }];
    
    [self.textStorage replaceCharactersInRange:range withString:@""];
    if (self.deleteHandler && byHand) {
        self.deleteHandler(self, regexPattern, range);
    }
}

@end
