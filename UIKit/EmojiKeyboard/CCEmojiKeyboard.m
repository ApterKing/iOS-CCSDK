//
//  CCEmojiKeyboard.m
//  CCSDK
//
//  Created by wangcong on 15/10/6.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCEmojiKeyboard.h"
#import "CCSDKDefines.h"
#import "CCEmoji.h"
#import "CCEmojiKeyboardCell.h"
#import "CCEmojiKeyboardPreview.h"

#define kCCEmojiKeyboardHeight 262
#define kCCEmojiToolbarHeight  36

@interface CCEmojiKeyboard ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) CCEmojiKeyboardPreview *preview;

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *emojiArray;

@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) UIButton *delBtn;

@end

@implementation CCEmojiKeyboard

+ (instancetype)emojiKeyboard
{
    static dispatch_once_t onceToken;
    static CCEmojiKeyboard *instance;
    dispatch_once(&onceToken, ^{
        instance = [[CCEmojiKeyboard alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    return [[self.class alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, APP_WIDTH, kCCEmojiKeyboardHeight)];
    if (self) {
        [self _initSubviews];
    }
    return self;
}

#pragma mark - private
- (void)_initSubviews
{
    self.emojiArray = [CCEmoji allEmojis];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kCCEmojiKeyboardHeight - kCCEmojiToolbarHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[CCEmojiKeyboardCell class] forCellWithReuseIdentifier:NSStringFromClass([CCEmojiKeyboardCell class])];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];
    
    UIView *lineH = [[UIView alloc] initWithFrame:CGRectMake(0, kCCEmojiKeyboardHeight - kCCEmojiToolbarHeight, APP_WIDTH, 1)];
    lineH.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineH];
    
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kCCEmojiKeyboardHeight - kCCEmojiToolbarHeight - 1, APP_WIDTH - 60, kCCEmojiToolbarHeight - 1)];
    self.sendBtn.adjustsImageWhenHighlighted = NO;
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self addSubview:self.sendBtn];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.sendBtn.frame), CGRectGetMinY(self.sendBtn.frame) + 6, 1, CGRectGetHeight(self.sendBtn.frame) - 8)];
    lineV.backgroundColor = lineH.backgroundColor;
    [self addSubview:lineV];
    
    self.delBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.sendBtn.frame) + 11, CGRectGetMinY(self.sendBtn.frame) + (kCCEmojiToolbarHeight - 24) / 2.0, 38, 24)];
    UIImage *image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images/keyboard_btn_del_nor.png"]];
    UIImage *himage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccsdk.bundle/images/keyboard_btn_del_high.png"]];
    [self.delBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.delBtn setBackgroundImage:himage forState:UIControlStateHighlighted];
    [self addSubview:self.delBtn];
    
    self.preview = [[CCEmojiKeyboardPreview alloc] init];
    self.preview.hidden = YES;
    [self addSubview:self.preview];
    
    @weakify(self);
    self.sendBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NSString *text = @"";
        if ([self.textView isKindOfClass:[UITextView class]]) {
            UITextView *tmpTextView = (UITextView *) self.textView;
            text = tmpTextView.text;
        } else if ([self.textView isKindOfClass:[UITextField class]]) {
            UITextField *tmpTextField = (UITextField *) self.textView;
            text = tmpTextField.text;
        }
        if (self.keyboardSend) {
            self.keyboardSend(text);
        }
        return [RACSignal empty];
    }];
    
    self.delBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *button) {
        @strongify(self);
        [self _deletePressed];
        return [RACSignal empty];
    }];
}

- (void)_changeKeyboard
{
    [(UIControl *)self.textView resignFirstResponder];
    [(UITextView *)self.textView setInputView:nil];
    [(UIControl *)self.textView becomeFirstResponder];
}

- (void)_deletePressed
{
    [self.textView deleteBackward];
    [[UIDevice currentDevice] playInputClick];
    [self _textChanged];
}

- (void)_insertEmoji:(NSString *)emoji
{
    [[UIDevice currentDevice] playInputClick];
    [self.textView insertText:emoji];
    [self _textChanged];
}

- (void)_textChanged
{
    if ([self.textView isKindOfClass:[UITextView class]])
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self.textView];
    else if ([self.textView isKindOfClass:[UITextField class]])
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self.textView];
}

#pragma mark - setter
- (void)setTextView:(id<UITextInput>)textView
{
    if ([textView isKindOfClass:[UITextView class]]) {
        [(UITextView *)textView setInputView:self];
    }
    else if ([textView isKindOfClass:[UITextField class]]) {
        [(UITextField *)textView setInputView:self];
    }
    _textView = textView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CCEmoji *emoji = self.emojiArray[section];
    return emoji.emojis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCEmojiKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CCEmojiKeyboardCell class]) forIndexPath:indexPath];
    CCEmoji *emoji = self.emojiArray[indexPath.section];
    cell.emojiString = emoji.emojis[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.emojiArray.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    CCEmoji *emoji = self.emojiArray[indexPath.section];
    [self _insertEmoji:emoji.emojis[indexPath.row]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(APP_WIDTH / 7.0, (kCCEmojiKeyboardHeight - kCCEmojiToolbarHeight) / 6.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 5, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

@end
