//
//  CCAlbumCollectionViewCell.m
//  CCSDK
//
//  Created by wangcong on 15/9/22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCAlbumCollectionViewCell.h"

@interface CCAlbumCollectionViewCell ()

@property(nonatomic, strong) UIImageView *imgv;
@property(nonatomic, strong) UIImageView *checkImgv;

@end

@implementation CCAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubviews];
        
        @weakify(self);
        [[RACObserve(self, model) ignore:nil] subscribeNext:^(id x) {
            @strongify(self);
            [self _configWithModel:x];
        }];
    }
    return self;
}

- (void)_initSubviews
{
    self.imgv = [[UIImageView alloc] init];
    self.imgv.layer.masksToBounds = YES;
    self.imgv.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.imgv];
    [self.imgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
    
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    self.checkImgv = [[UIImageView alloc] init];
    self.checkImgv.image = [UIImage imageWithContentsOfFile:[resPath stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_album_no_select@2x.png"]];
    self.checkImgv.highlightedImage = [UIImage imageWithContentsOfFile:[resPath stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_album_selected@2x.png"]];
    [self.contentView addSubview:self.checkImgv];
    [self.checkImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)_configWithModel:(CCAlbumModel *)model
{
    self.imgv.image = [UIImage imageWithCGImage:model.asset.aspectRatioThumbnail];
}

@end
