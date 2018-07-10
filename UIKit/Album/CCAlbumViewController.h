//
//  CCAlbumViewController.h
//  CCSDK
//
//  Created by wangcong on 15/9/22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 *  选中图片
 *  @param albumModel
 */
typedef void(^block_album_selected)(NSArray *assets);

/**
 *  去选选择
 */
typedef void(^block_album_cancel)();

@interface CCAlbumViewController : UIViewController

// 最多选择的图片数量
@property(nonatomic, assign) NSInteger maxCount;

// 默认为图片
@property(nonatomic, strong) ALAssetsFilter *assetsFilter;

- (void)showWithController:(UIViewController *)controller selectedBlock:(block_album_selected)selectedBlock cancel:(block_album_cancel)cancelBlock;

@end
