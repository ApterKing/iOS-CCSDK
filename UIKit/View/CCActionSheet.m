//
//  CCActionSheet.m
//  CCSDK
//
//  Created by wangcong on 16/1/25.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import "CCActionSheet.h"
#import "UIView+CCCategory.h"
#import "UIColor+CCCategory.h"
#import "UIFont+CCCategory.h"
#import "CCSDKDefines.h"

#pragma mark - title
@interface CCActionSheetHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *label;

@end

@implementation CCActionSheetHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

@end

#pragma mark - item
@interface CCActionSheetTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation CCActionSheetTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.adjustsFontSizeToFitWidth = YES;
        self.label.highlightedTextColor = [UIColor colorWithRGBHexString:@"#9b9b9b"];
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

@end

@interface CCActionSheet ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *maskView;     // 遮罩
@property (nonatomic, strong) UITableView *tableView;

// 标题、取消
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, copy) NSString *cancelButtonTitle;

// 回调
@property (nonatomic, copy) didSelectedItemAtIndex selected;

@end

@implementation CCActionSheet

- (instancetype)initWithTitle:(NSString *)title delegate:(didSelectedItemAtIndex)selected cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...  NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.") {
    self = [super init];
    if (self) {
        self.title = title;
        self.selected = selected;
        self.cancelButtonTitle = cancelButtonTitle;
        self.itemArray = [NSMutableArray array];
        if (otherButtonTitles) {
            [self.itemArray addObject:otherButtonTitles];
            id eachObject;
            va_list args;
            va_start(args, otherButtonTitles);
            while ((eachObject = va_arg(args, id))) {
                [self.itemArray addObject:eachObject];
            }
            va_end(args);
        }
        
        [self _initSubviews];
    }
    return self;
}

- (void)_initSubviews {
    _titleHeight = IS_IPHONE_5_OR_LESS ? 38 : 42;
    _titleFont = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 13 : 14];
    _titleTextColor = [UIColor colorWithRGBHexString:@"#9b9b9b"];
    
    _itemHeight = IS_IPHONE_5_OR_LESS ? 40 : 44;
    _itemFont = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 16.5 : 17.5];
    _itemTextColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    
    // 背景
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.maskView.backgroundColor = [UIColor blackColor];
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    
    // UITableView
    CGFloat tableViewHeight = (self.title ? self.titleHeight : 0) + self.itemArray.count * self.itemHeight + (self.cancelButtonTitle ? (10 + self.itemHeight) : 0);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, SCREEN_WIDTH, tableViewHeight) style:UITableViewStylePlain];
    [self.tableView registerClass:[CCActionSheetHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([CCActionSheetHeaderView class])];
    [self.tableView registerClass:[CCActionSheetTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CCActionSheetTableViewCell class])];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor colorWithRGBHexString:@"#e8e8e8"];
    self.tableView.tableFooterView = [[UIView alloc] init];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 8, 0, 8);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.itemArray.count : (self.cancelButtonTitle ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCActionSheetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CCActionSheetTableViewCell class])];
    cell.label.text = indexPath.section == 0 ? self.itemArray[indexPath.row] : self.cancelButtonTitle;
    cell.label.textColor = self.itemTextColor;
    cell.label.font = self.itemFont;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cancelButtonTitle ? 2 : 1;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        CCActionSheetHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([CCActionSheetHeaderView class])];
        headerView.label.text = self.title;
        headerView.label.font = self.titleFont;
        headerView.label.textColor = self.titleTextColor;
        return headerView;
    } else {
        if (self.cancelButtonTitle) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor lightGrayColor];
            view.alpha = .3f;
            return view;
        }
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? (self.title ? self.titleHeight : 0) : (self.cancelButtonTitle ? 10 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger index = indexPath.section == 1 ? self.itemArray.count : indexPath.row;
    if (self.selected) {
        self.selected(self, index);
    }
    [self hide];
}

#pragma mark - setter
- (void)setTitleHeight:(CGFloat)titleHeight {
    _titleHeight = titleHeight <= 0 ? (IS_IPHONE_5_OR_LESS ? 38 : 42) : titleHeight;
    CGFloat tableViewHeight = (self.title ? self.titleHeight : 0) + self.itemArray.count * self.itemHeight + (self.cancelButtonTitle ? (10 + self.itemHeight) : 0);
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, APP_WIDTH, tableViewHeight);
    [self.tableView reloadData];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont == nil ? [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 13 : 14] : titleFont;
    [self.tableView reloadData];
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor == nil ? [UIColor colorWithRGBHexString:@"#9b9b9b"] : titleTextColor;
    [self.tableView reloadData];
}

- (void)setItemHeight:(CGFloat)itemHeight {
    _itemHeight = itemHeight <= 0 ? (IS_IPHONE_5_OR_LESS ? 28 : 42) : itemHeight;
    CGFloat tableViewHeight = (self.title ? self.titleHeight : 0) + self.itemArray.count * self.itemHeight + (self.cancelButtonTitle ? (10 + self.itemHeight) : 0);
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, APP_WIDTH, tableViewHeight);
    [self.tableView reloadData];
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont == nil ? [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 15 : 16] : itemFont;
    [self.tableView reloadData];
}

- (void)setItemTextColor:(UIColor *)itemTextColor {
    _itemTextColor = itemTextColor == nil ? [UIColor colorWithRGBHexString:@"#4a4a4a"] : itemTextColor;
    [self.tableView reloadData];
}

#pragma mark - public
- (void)setTitle:(NSString *)title {
    _title = title;
    [self.tableView reloadData];
}

- (void)addButtonTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.itemArray insertObject:title atIndex:index];
    CGFloat tableViewHeight = (self.title ? self.titleHeight : 0) + self.itemArray.count * self.itemHeight + (self.cancelButtonTitle ? (10 + self.itemHeight) : 0);
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, APP_WIDTH, tableViewHeight);
    [self.tableView reloadData];
}

- (void)addButtontitles:(NSArray *)titles atIndex:(NSIndexSet *)indexSet {
    [self.itemArray insertObjects:titles atIndexes:indexSet];
    CGFloat tableViewHeight = (self.title ? self.titleHeight : 0) + self.itemArray.count * self.itemHeight + (self.cancelButtonTitle ? (10 + self.itemHeight) : 0);
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT - tableViewHeight, APP_WIDTH, tableViewHeight);
    [self.tableView reloadData];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.tableView];
    self.maskView.alpha = 0;
    self.tableView.top = SCREEN_HEIGHT;      // 从屏幕最低端
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.2;
        self.tableView.bottom = SCREEN_HEIGHT;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.tableView.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.tableView removeFromSuperview];
    }];
}

@end
