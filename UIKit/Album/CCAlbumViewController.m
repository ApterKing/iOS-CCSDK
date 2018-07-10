//
//  CCAlbumViewController.m
//  CCSDK
//
//  Created by wangcong on 15/9/22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCAlbumViewController.h"
#import "CCAlbumCollectionViewCell.h"
#import "CCNavigationBarController.h"

@interface CCAlbumViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, copy) block_album_selected mSelectedBlock;
@property(nonatomic, copy) block_album_cancel mCancelBlock;

// 相册布局显示
@property(nonatomic, strong) UICollectionView *mCollectionView;
@property(nonatomic, strong) NSMutableArray *mAssetsOfGroups;       // 所有ALAssetsGroup下的 ALAssets
@property(nonatomic, strong) NSMutableArray *mSelectedArray;        // 选中的图片indexPath,按照选择的排序
@property(nonatomic, strong) UIButton *mSelectedButton;

@end

@implementation CCAlbumViewController

+ (ALAssetsLibrary *)defaultALAssetsLibrary
{
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (assetsLibrary == nil) {
            assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
    });
    return assetsLibrary;
}

- (void)showWithController:(UIViewController *)controller selectedBlock:(block_album_selected)selectedBlock cancel:(block_album_cancel)cancelBlock
{
    self.mSelectedBlock = selectedBlock;
    self.mCancelBlock = cancelBlock;
    CCNavigationBarController *albumNavc = [[CCNavigationBarController alloc] initWithRootViewController:self];
    [controller presentViewController:albumNavc animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _assetsFilter = [ALAssetsFilter allPhotos];
    self.mSelectedArray = [NSMutableArray array];
    
    [self _initSubviews];
    [self _setupAssert];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"相册";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"%@ --- dealloc", NSStringFromClass(self.class));
}

#pragma mark - private
- (void)_initSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    UIImage *norImg = [UIImage imageWithContentsOfFile:[resPath stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_navc_close_nor@2x.png"]];
    UIImage *highImg = [UIImage imageWithContentsOfFile:[resPath stringByAppendingPathComponent:@"ccsdk.bundle/images/icon_navc_close_high@2x.png"]];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    closeBtn.adjustsImageWhenHighlighted = NO;
    [closeBtn setBackgroundImage:norImg forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:highImg forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.mAssetsOfGroups = [NSMutableArray array];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.mCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.mCollectionView.backgroundColor = [UIColor clearColor];
    self.mCollectionView.delegate = self;
    self.mCollectionView.dataSource = self;
    self.mCollectionView.allowsMultipleSelection = YES;
    [self.mCollectionView registerClass:[CCAlbumCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CCAlbumCollectionViewCell class])];
    [self.view addSubview:self.mCollectionView];
    [self.mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).offset(-44);
        make.right.equalTo(self.view.mas_right);
    }];
    
    self.mSelectedButton = [[UIButton alloc] init];
    self.mSelectedButton.adjustsImageWhenHighlighted = NO;
    [self.mSelectedButton setTitle:@"完成（0）" forState:UIControlStateNormal];
    [self.mSelectedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.mSelectedButton setTitleColor:[UIColor colorWithRGBHexString:@"#7ABC24"] forState:UIControlStateNormal];
    self.mSelectedButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.mSelectedButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHexString:@"#F8F8F8"]] forState:UIControlStateNormal];
    [self.mSelectedButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHexString:@"#EFEFEF"]] forState:UIControlStateHighlighted];
    [self.view addSubview:self.mSelectedButton];
    [self.mSelectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mCollectionView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
    
    @weakify(self);
    closeBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.mCancelBlock) {
                self.mCancelBlock();
            }
        }];
        return [RACSignal empty];
    }];
    
    self.mSelectedButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NSArray *photoArray = [[self.mSelectedArray.rac_sequence
                                map:^id(NSIndexPath *indexPath) {
                                    return self.mAssetsOfGroups[indexPath.row];
                                }] array];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.mSelectedBlock) {
                self.mSelectedBlock(photoArray);
            }
        }];
        return [RACSignal empty];
    }];
    self.mSelectedButton.enabled = NO;
}

- (void)_setupAssert
{
    [self.mAssetsOfGroups removeAllObjects];
    
    @weakify(self);
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        @strongify(self);
        if (group) {
            [group setAssetsFilter:self.assetsFilter];
            if (group.numberOfAssets > 0) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    @strongify(self);
                    if (result) {
                        CCAlbumModel *model = [[CCAlbumModel alloc] init];
                        model.asset = result;
                        [self.mAssetsOfGroups addObject:model];
                    }
                }];
            }
        }  else {
            if (self.mAssetsOfGroups.count == 0) {
                [self _showToastBackgroundViewWithText:@"暂无照片"];
            }
            [self.mCollectionView reloadData];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [self _showToastBackgroundViewWithText:@"此应用无法使用您的照片"];
    };
    
    [[self.class defaultALAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultsBlock failureBlock:failureBlock];
}

/**
 *  无数据或者无法加载相册资源时显示提示
 *  @param toast 提示信息
 */
- (void)_showToastBackgroundViewWithText:(NSString *)toast
{
    CGSize size = [toast textSizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(APP_WIDTH - 20, APP_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((APP_WIDTH - size.width) / 2.0, 60, size.width, size.height)];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = toast;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    self.mCollectionView.backgroundView = label;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mAssetsOfGroups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CCAlbumCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.mAssetsOfGroups[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((APP_WIDTH - 16) / 4.0, (APP_WIDTH - 16) / 4.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.maxCount == 0) return YES;
    return [collectionView indexPathsForSelectedItems].count < self.maxCount;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedIndexPaths = [collectionView indexPathsForSelectedItems];
    self.mSelectedButton.enabled = selectedIndexPaths.count == 0 ? NO : YES;
    [self.mSelectedButton setTitle:[NSString stringWithFormat:@"完成（%lu）", selectedIndexPaths.count] forState:UIControlStateNormal];
    [self.mSelectedArray addObject:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedIndexPaths = [collectionView indexPathsForSelectedItems];
    self.mSelectedButton.enabled = selectedIndexPaths.count == 0 ? NO : YES;
    [self.mSelectedButton setTitle:[NSString stringWithFormat:@"完成（%lu）", selectedIndexPaths.count] forState:UIControlStateNormal];
    [self.mSelectedArray removeObject:indexPath];
}

@end
