//
//  CCEmojiInputView.m
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCEmojiInputView.h"
#import "UIColor+CCCategory.h"
#import "CCSDKDefines.h"
#import "CCEmojiKeyboard.h"
#import "CCTextView.h"

// 键盘输入view 默认高度
#define kCCEmojiInputViewDHeight        44

#define kCCEmojiTextViewDHeight         34
#define kCCEmojiTextViewMaxHeight       80

#define kCCEmojiButtonWidth             40
#define kCCEmojiButtonHeight            26

@interface CCEmojiInputView () <UITextViewDelegate>

@property(nonatomic, strong) CCEmojiKeyboard *keyboard;
@property(nonatomic, strong) CCTextView *textView;
@property(nonatomic, strong) UIButton *keyboardTypeBtn;
@property(nonatomic, assign) CGRect originalFrame;

@end

@implementation CCEmojiInputView

+ (instancetype)emojiInputView
{
    return [self new];
}

- (instancetype)init
{
    return [[self.class alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, APP_WIDTH, kCCEmojiInputViewDHeight)];
    if (self) {
        [self _initSubviews];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (CGRectEqualToRect(CGRectZero, self.originalFrame)) {
        self.originalFrame = self.frame;
    }
}

- (void)_initSubviews
{
    self.backgroundColor = [UIColor colorWithRGBHexString:@"#F4F4F4"];
    
    self.textView = [[CCTextView alloc] initWithFrame:CGRectMake(5, (kCCEmojiInputViewDHeight - kCCEmojiTextViewDHeight) / 2.0, CGRectGetWidth(self.frame) - 20 - kCCEmojiButtonWidth, kCCEmojiTextViewDHeight)];
    [self addSubview:self.textView];
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    self.textView.tintColor = [UIColor whiteColor];
    self.textView.scrollEnabled = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.layer.cornerRadius = 5;
    [self addSubview:self.textView];
    
    self.keyboardTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.textView.frame) + CGRectGetMinX(self.textView.frame) + 8, (kCCEmojiInputViewDHeight - kCCEmojiButtonHeight) / 2.0, kCCEmojiButtonWidth, kCCEmojiButtonHeight)];
    UIImage *normalImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images/keyboard_btn_expression.png"]];
    UIImage *selectedImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images/keyboard_btn_keyboard.png"]];
    [self.keyboardTypeBtn setImage:normalImage forState:UIControlStateNormal];
    [self.keyboardTypeBtn setImage:selectedImage forState:UIControlStateSelected];
    [self addSubview:self.keyboardTypeBtn];
    
    self.keyboard = [CCEmojiKeyboard emojiKeyboard];
    
    @weakify(self);
    self.keyboardTypeBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *button) {
        @strongify(self);
        if (button.selected) {
            self.textView.inputView = nil;
        } else {
            [self.keyboard setTextView:self.textView];
        }
        [self.textView becomeFirstResponder];
        [self.textView reloadInputViews];
        button.selected = !button.selected;
        return [RACSignal empty];
    }];
}

// 重新布局子控件
- (void)_layout
{
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
    
    CGFloat offset = 10;
    self.textView.scrollEnabled = (textSize.height > kCCEmojiTextViewMaxHeight - offset);
    textViewFrame.size.height = MAX(kCCEmojiTextViewDHeight, MIN(kCCEmojiTextViewMaxHeight, textSize.height));
    self.textView.frame = textViewFrame;
    
    CGRect addBarFrame = self.frame;
    CGFloat maxY = CGRectGetMaxY(addBarFrame);
    addBarFrame.size.height = textViewFrame.size.height + offset;
    addBarFrame.origin.y = maxY - addBarFrame.size.height;
    self.frame = addBarFrame;
    
    self.keyboardTypeBtn.center = CGPointMake(CGRectGetMidX(self.keyboardTypeBtn.frame), CGRectGetHeight(addBarFrame) / 2.0f);
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.textView resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.textView becomeFirstResponder];
}

#pragma mark - notify
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([info[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{
                         CGRect newInputBarFrame = self.frame;
                         newInputBarFrame.origin.y = CGRectGetMinY(self.originalFrame) - (CGRectGetHeight(newInputBarFrame) - CGRectGetHeight(self.originalFrame)) - kbSize.height;
                         self.frame = newInputBarFrame;
                     }
                     completion:nil];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    [UIView animateWithDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([info[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{
//                         self.bottom = self.originalFrame.origin.y + self.originalFrame.size.height;
                         CGRect newInputBarFrame = self.frame;
                         newInputBarFrame.origin.y = CGRectGetMinY(self.originalFrame) - (CGRectGetHeight(newInputBarFrame) - CGRectGetHeight(self.originalFrame));
                         self.frame = newInputBarFrame;
                     }
                     completion:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (self.keyboardSend) {
            self.keyboardSend(self.textView.text);
        }
        return FALSE;
    }
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _layout];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

#pragma mark - public
- (void)setFitWhenKeyboardShowOrHide:(BOOL)fitWhenKeyboardShowOrHide
{
    if (fitWhenKeyboardShowOrHide) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    if (!fitWhenKeyboardShowOrHide && _fitWhenKeyboardShowOrHide){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _fitWhenKeyboardShowOrHide = fitWhenKeyboardShowOrHide;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    self.textView.placeholder = placeHolder;
}

- (void)setKeyboardSend:(block_keyboard_send)keyboardSend
{
    _keyboardSend = keyboardSend;
    self.keyboard.keyboardSend = keyboardSend;
}

- (void)clearText
{
    self.textView.text = @"";
    [self _layout];
}

@end
