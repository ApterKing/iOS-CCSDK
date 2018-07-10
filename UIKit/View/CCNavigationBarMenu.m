//
//  CCNavigationBarMenu.m
//  CCSDK
//
//  Created by wangcong on 16/1/19.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import "CCNavigationBarMenu.h"
#import "UIColor+CCCategory.h"
#import "UIFont+CCCategory.h"
#import "CCSDKDefines.h"

#define ITEM_IMAGE_SIZE CGSizeMake(IS_IPHONE_5_OR_LESS ? 20 : 22, IS_IPHONE_5_OR_LESS ? 20 : 22)

#pragma mark - model
@implementation CCNavigationBarMenuItem

+ (instancetype)navigationBarMenuItemWithImage:(UIImage *)image title:(NSString *)title {
    return [[CCNavigationBarMenuItem alloc] initWithImage:image title:title];
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.titleColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
        self.titleFont = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 15.5 : 17];
    }
    return self;
}

@end

#pragma mark - cell
@interface CCNavigationBarMenuTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView             *itemImageView;
@property (nonatomic, strong) UILabel                 *itemTitleLabel;

@property (nonatomic, strong) CCNavigationBarMenuItem *model;

// 根据文字宽度重置图标及文字
- (void)resetCellItemPosition:(CGFloat)width;

@end

@implementation CCNavigationBarMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initSubviews];
    }
    return self;
}

- (void)_initSubviews {
    self.itemTitleLabel = [[UILabel alloc] init];
    self.itemTitleLabel.font = [UIFont appFontOfSize:17];
    self.itemTitleLabel.textColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    [self.contentView addSubview:self.itemTitleLabel];
    [self.itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView).offset(10 + ITEM_IMAGE_SIZE.width / 2.0);
        make.centerY.equalTo(self.contentView);
    }];
    
    self.itemImageView = [[UIImageView alloc] init];
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.itemImageView];
    [self.itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.itemTitleLabel.mas_left).offset(-14);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(ITEM_IMAGE_SIZE);
    }];
}

#pragma mark - setter
- (void)setModel:(CCNavigationBarMenuItem *)model {
    self.itemImageView.image = model.image;
    self.itemTitleLabel.text = model.title;
    self.itemTitleLabel.font = model.titleFont;
    self.itemTitleLabel.textColor = model.titleColor;
}

- (void)resetCellItemPosition:(CGFloat)width {
    [self.itemTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView).offset(7 + ITEM_IMAGE_SIZE.width / 2.0);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(width);
    }];
}

@end


@interface CCNavigationBarMenu ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) CGPoint     origin;
@property (nonatomic, assign) CGFloat     width;

// 遮罩
@property (nonatomic, strong) UIView      *maskView;

// 内容
@property (nonatomic, strong) UIView      *contentView;
@property (nonatomic, strong) UIView      *triangleView;
@property (nonatomic, strong) UITableView *tableView;

// 文字最大宽度
@property (nonatomic, assign) CGFloat     maxItemLabelWidth;

@end

@implementation CCNavigationBarMenu

- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width {
    self = [super init];
    if (self) {
        _items = [NSArray array];
        _separatorColor = [UIColor colorWithRGBHexString:@"#e8e8e8"];
        _rowHeight = ITEM_IMAGE_SIZE.height + (IS_IPHONE_5_OR_LESS ? 20 : 26);
        _triangleFrame = CGRectMake(width - 25, 0, IS_IPHONE_5_OR_LESS ? 16 : 18, IS_IPHONE_5_OR_LESS ? 12 : 14);
        
        // 背景
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = .2f;
        [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        
        // 内容
        self.origin = origin;
        self.width = width;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, self.rowHeight * self.items.count + CGRectGetHeight(self.triangleFrame) + 5)];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // 三角形
        [self _applytriangleView];
        
        // item
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.triangleFrame) + 5, width, self.rowHeight * self.items.count) style:UITableViewStylePlain];
        [self.tableView registerClass:[CCNavigationBarMenuTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CCNavigationBarMenuTableViewCell class])];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.bounces = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorColor = self.separatorColor;
        self.tableView.layer.cornerRadius = 2;
        self.tableView.tableFooterView = [[UIView alloc] init];
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        }
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
        }
        [self.contentView addSubview:self.tableView];
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCNavigationBarMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CCNavigationBarMenuTableViewCell class])];
    if (cell.selectedBackgroundView == nil) {
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRGBHexString:@"#eeeeee"];
        cell.selectedBackgroundView = selectedBackgroundView;
    }
    cell.model = self.items[indexPath.row];
    [cell resetCellItemPosition:self.maxItemLabelWidth];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismiss];
    if (self.didSelectMenuItem) {
        self.didSelectMenuItem(self, self.items[indexPath.row]);
    }
}

- (void)_applytriangleView {
    if (self.triangleView == nil) {
        self.triangleView = [[UIView alloc] init];
        self.triangleView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.triangleView];
    }
    self.triangleFrame = CGRectMake(CGRectGetMinX(self.triangleFrame), 5, CGRectGetWidth(self.triangleFrame), CGRectGetHeight(self.triangleFrame));
    self.triangleView.frame = self.triangleFrame;
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, CGRectGetWidth(self.triangleFrame) / 2.0, 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, 0, CGRectGetHeight(self.triangleFrame));
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, CGRectGetWidth(self.triangleFrame), CGRectGetHeight(self.triangleFrame));
    shaperLayer.path = path;
    self.triangleView.layer.mask = shaperLayer;
}

#pragma mark - setter
- (void)setItems:(NSArray *)items {
    _items = items;
    self.maxItemLabelWidth = 0;
    for (CCNavigationBarMenuItem *item in self.items) {
        CGSize size = [item.title textSizeWithFont:item.titleFont constrainedToSize:CGSizeMake(APP_WIDTH, APP_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
        if (size.width > self.maxItemLabelWidth) {
            self.maxItemLabelWidth = size.width;
        }
    }
    self.contentView.height = self.rowHeight * self.items.count + CGRectGetHeight(self.triangleFrame) + 5;
    self.tableView.height = self.rowHeight * self.items.count;
    [self.tableView reloadData];
}

- (void)settriangleFrame:(CGRect)triangleFrame {
    _triangleFrame = triangleFrame;
    self.contentView.height = self.rowHeight * self.items.count + CGRectGetHeight(self.triangleFrame) + 5;
    self.tableView.height = self.rowHeight * self.items.count;
    [self _applytriangleView];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    self.tableView.separatorColor = separatorColor;
}

- (void)setRowHeight:(CGFloat)rowHeight {
    _rowHeight = rowHeight;
    self.contentView.height = self.rowHeight * self.items.count + CGRectGetHeight(self.triangleFrame) + 5;
    self.tableView.height = self.rowHeight * self.items.count;
    [self.tableView reloadData];
}

#pragma mark - public
- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.maskView];
    [window addSubview:self.contentView];
//    self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0f, 0.0f);
    self.contentView.alpha = 0.0f;
    self.maskView.alpha = .0f;
    [UIView animateWithDuration:.25f animations:^{
        self.contentView.alpha = 1.0f;
//        self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        self.maskView.alpha = .2f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:.15f animations:^{
//        self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, .5f, .5f);
        self.contentView.alpha = 0.0f;
        self.maskView.alpha = .0f;
    } completion:^(BOOL finished) {
//        self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        if (finished) {
            [self.maskView removeFromSuperview];
            [self.contentView removeFromSuperview];
        }
    }];
}

@end
