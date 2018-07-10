//
//  ALAssetsLibrary+CCCategory.h
//  CCSDK
//
//  Created by wangcong on 16/4/12.
//  Copyright © 2016年 wangcong. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary (CCCategory)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

@end
