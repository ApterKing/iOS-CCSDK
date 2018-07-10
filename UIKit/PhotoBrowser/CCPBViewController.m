//
//  CCPBViewController.m
//  DYSport
//
//  Created by wangcong on 15/9/23.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCPBViewController.h"
#import "CCPBPhotoModel.h"
#import "CCPBPageView.h"
#import "CCPBImageView.h"
#import "CCPBScrollView.h"
#import "CALayer+CCCategory.h"

@interface CCPBViewController ()<UIScrollViewDelegate>

@property(nonatomic, strong) CCPBScrollView *scrollView;
@property(nonatomic, strong) UILabel *pageCountToastLabel;
@property(nonatomic, strong) UIButton *saveButton;

@property(nonatomic, strong) UIViewController *viewController;
@property(nonatomic, strong) NSArray *photoModels;
@property(nonatomic, assign) CCPBVCShowType showType;

// 初始化显示的图片位置
@property(nonatomic, assign) NSUInteger index;

/** 总页数 */
@property (nonatomic,assign) NSUInteger pageCount;

/** page */
@property (nonatomic,assign) NSUInteger page;


/** 上一个页码 */
@property (nonatomic,assign) NSUInteger lastPage;

/** 可重用集合 */
@property (nonatomic,strong) NSMutableSet *reusablePageViewSet;

/** 显示中视图字典 */
@property (nonatomic,strong) NSMutableDictionary *visiblePageViewDict;

/** 要显示的下一页 */
@property (nonatomic,assign) NSUInteger nextPage;

/** drag时的page */
@property (nonatomic,assign) NSUInteger dragPage;

@end

@implementation CCPBViewController

+ (void)showWithViewController:(UIViewController *)viewController photos:(NSArray *(^)())photoModelBlock type:(CCPBVCShowType)showType atIndex:(NSUInteger)index
{
    //取出相册数组
    NSArray *photoModels = photoModelBlock();
    
    if(photoModels == nil || photoModels.count == 0) return;
    
    
    if(index >= photoModels.count) {
        NSLog(@"index 越界，默认从 0 位置开始显示");
        index = 0;
    }
    
    if (viewController.navigationController == nil && showType != CCPBVCShowTypeModal) {
        NSLog(@"不存在UINavigationController，采用默认Modal方式显示图片");
        showType = CCPBVCShowTypeModal;
    }
    
    //记录
    CCPBViewController *pbVC = [[CCPBViewController alloc] init];
    pbVC.viewController = viewController;
    pbVC.photoModels = photoModels;
    pbVC.showType = showType;
    pbVC.index = index;
    
    [pbVC show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.visiblePageViewDict = [NSMutableDictionary dictionary];
    self.reusablePageViewSet =[NSMutableSet set];
    [self _initSuviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
- (void)show
{
    switch (self.showType) {
        case CCPBVCShowTypeModal:
            [self.viewController presentViewController:self animated:YES completion:nil];
            break;
        case CCPBVCShowTypePush:
            [self.viewController.navigationController pushViewController:self animated:YES];
            break;
        case CCPBVCShowTypeTransition:
            [self.viewController.navigationController pushViewController:self animated:NO];
            [self.viewController.navigationController.view.layer transitionWithAnimType:TransitionAnimTypeReveal subType:TransitionSubtypesFromRight curve:TransitionCurveEaseIn duration:0.35f];
            break;
        default:
            break;
    }
}

- (void)dismiss
{
    switch (self.showType) {
        case CCPBVCShowTypeModal:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case CCPBVCShowTypePush:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case CCPBVCShowTypeTransition:
            [self.navigationController.view.layer transitionWithAnimType:TransitionAnimTypeReveal subType:TransitionSubtypesFromLeft curve:TransitionCurveEaseInEaseOut duration:0.35f];
            [self.navigationController popViewControllerAnimated:NO];
            break;
        default:
            break;
    }
}

- (void)_initSuviews
{
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[CCPBScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right).offset(10);
    }];
    
    self.pageCountToastLabel = [[UILabel alloc] init];
    self.pageCountToastLabel.adjustsFontSizeToFitWidth = YES;
    self.pageCountToastLabel.text = @"0 / 0";
    self.pageCountToastLabel.backgroundColor = [UIColor blackColor];
    self.pageCountToastLabel.alpha = 0.6;
    self.pageCountToastLabel.textAlignment = NSTextAlignmentCenter;
    self.pageCountToastLabel.layer.cornerRadius = 4;
    self.pageCountToastLabel.layer.masksToBounds = YES;
    self.pageCountToastLabel.textColor = [UIColor whiteColor];
    self.pageCountToastLabel.font = [UIFont systemFontOfSize:15];
    self.pageCountToastLabel.hidden = self.photoModels.count <= 1;
    [self.view addSubview:self.pageCountToastLabel];
    [self.pageCountToastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 22));
    }];
    
    self.saveButton = [[UIButton alloc] init];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor colorWithRGBHexString:@"#eeeeee"] forState:UIControlStateHighlighted];
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveImageToAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    
    __block CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat widthEachPage = frame.size.width + 10;
    
    //展示页码对应的页面
    [self showWithPage:self.index];
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(widthEachPage * self.photoModels.count, 0);
    
    self.scrollView.index = _index;
    
    UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] init];
    singleGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleGesture];
    
    @weakify(self);
    [singleGesture.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self);
        [self dismiss];
    }];
}

#pragma mark -
- (void)saveImageToAlbum:(UIButton *)button {
    [self.scrollView saveImageToAlbum];
}

/*
 *  展示页码对应的页面
 */
- (void)showWithPage:(NSUInteger)page {
    //如果对应页码对应的视图正在显示中，就不用再显示了
    if([self.visiblePageViewDict objectForKey:@(page)] != nil) return;
    
    //取出重用photoItemView
    CCPBPageView *pageView = [self dequeReusablePageView];
    
    // 重新创建
    if(pageView == nil) {
        pageView = [[CCPBPageView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT)];
    }
    
    //加入到当前显示中的字典
    [self.visiblePageViewDict setObject:pageView forKey:@(page)];
    
    //传递数据
    //设置页标
    pageView.pageIndex = page;
    pageView.photoModel = self.photoModels[page];
    
    [self.scrollView addSubview:pageView];
    
    pageView.hidden=YES;
    [UIView animateWithDuration:.01 animations:^{
        pageView.alpha=1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pageView.hidden=NO;
        });
    }];
}

- (void)reuseAndVisibleHandle:(NSUInteger)page {
    //遍历可视视图字典，除了page之外的所有视图全部移除，并加入重用集合
    [self.visiblePageViewDict enumerateKeysAndObjectsUsingBlock:^(NSValue *key, CCPBPageView *pageView, BOOL *stop) {
        
        if(![key isEqualToValue:@(page)]){
            pageView.zoomScale = 1.0f;
            pageView.alpha = 0;
            [self.reusablePageViewSet addObject:pageView];
            [self.visiblePageViewDict removeObjectForKey:key];
        }
    }];
}

/**
 *  计算当前页面
 *
 *  @param scrollView
 *  @return
 */
- (NSUInteger)pageCalculateWithScrollView:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width + .5f;
    return page;
}

- (void)setPhotoModels:(NSArray *)photoModels {
    _photoModels = photoModels;
    
    self.pageCount = photoModels.count;
    self.pageCountToastLabel.hidden = photoModels.count <= 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        self.page = _index;
    });
}

- (void)setPage:(NSUInteger)page {
    if(_page != 0 && _page == page) return;
    _lastPage = page;
    _page = page;
    
    //设置标题
    NSString *text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.pageCount)];
    self.pageCountToastLabel.text = text;
    [self showWithPage:page];
}

- (void)setIndex:(NSUInteger)index {
    _index = index ;
}

/** 取出可重用照片视图 */
- (CCPBPageView *)dequeReusablePageView {
    CCPBPageView *pageView = [self.reusablePageViewSet anyObject];
    if(pageView != nil) {
        //从可重用集合中移除
        [self.reusablePageViewSet removeObject:pageView];
        [pageView reset];
    }
    return pageView;
}

- (void)setNextPage:(NSUInteger)nextPage {
    if(_nextPage == nextPage) return;
    _nextPage = nextPage;
    [self showWithPage:nextPage];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger page = [self pageCalculateWithScrollView:scrollView];
    
    //记录dragPage
    if(self.dragPage == 0) self.dragPage = page;
    
    self.page = page;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat pageOffsetX = self.dragPage * scrollView.bounds.size.width;
    
    if(offsetX > pageOffsetX) { //正在向左滑动，展示右边的页面
        if(page >= self.pageCount - 1) return;
        self.nextPage = page + 1;
    } else if (offsetX < pageOffsetX) { //正在向右滑动，展示左边的页面
        if(page == 0) return;
        self.nextPage = page - 1;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = [self pageCalculateWithScrollView:scrollView];
    [self reuseAndVisibleHandle:page];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.dragPage = 0;
}

@end
