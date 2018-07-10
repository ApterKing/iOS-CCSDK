#OC-CCSdk 以下对部分功能介绍
依赖 [MBProgressHUD提示](https://github.com/jdg/MBProgressHUD) 、[Masonry AutoLayout](https://github.com/SnapKit/Masonry) 、[SDWebImage图片加载](https://github.com/rs/SDWebImage) 、[pop动画处理](https://github.com/facebook/pop)

**Cache 缓存**

处理内存缓存及本地NSData缓存，支持清空缓存回调

**Category**

_ALAssetsLibrary+CCCategory_： 用于保存图片到指定的相册下

_NSDate+CCCategory_： 时间格式化等

_NSString+CCCategory_： 字符串Base64处理及其他正则表达式判定

_UIColor+CCCategory_： 16进制颜色转换，如[UIColor colorWithRGBHexString:@"#ffd3f1"]

**Core**

_CCSDKCore_：  初始化框架，用于网络监听、缓存处理

_CCSDKDefines_：  常用宏定义!

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/095943_3a37df23_767740.png "在这里输入图片标题")

**Media** 音乐播放，录音，短音频播放

**Network 轻量级Http请求**
 
_CCHttpClient_： HTTP访问客户端(支持同步和异步请求)，初始化客户端发起http请求; 编码方式、cookie、userAgent等；支持（POST/GET/PUT/HEAD/DELETE）方式访问服务器端；支持取消操作，支持下载进度等；捕获出错原因.

**POST请求**

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/101450_5aeac1b8_767740.png "在这里输入图片标题")

**GET请求**

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/101306_bbae2f32_767740.png "在这里输入图片标题")

**Sensor**

_CCHighMeter_： 通过手机测试跳高距离

_CCPedometer_： iOS计步

_CCSensorMeterManager_： 统一管理跳高、挥拳测试

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/102018_b7054aca_767740.png "在这里输入图片标题")

**Utils**

_CCGTMBase64_： Google提供的Base64编码处理，用于对接Android

_CCEncryptUtil_： MD5加密   BASE(HMAC_SHA1)

_CCCrc32_： 文件crc32校验

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/102734_f2a8b6f5_767740.png "在这里输入图片标题")

**UIKit**

_CCImageCropViewController_： 图片裁剪

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/104013_24363f59_767740.png "在这里输入图片标题")

_CCAlbumViewController_：图片选择

    CCAlbumViewController *albumVC = [[CCAlbumViewController alloc] init];
    albumVC.maxCount = 9;
    [albumVC showWithController:self selectedBlock:^(NSArray *assets) {
        // 处理选中的图片
        
    } cancel:^{
        // 取消选择
    }];

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/104812_964ef0dc_767740.png "在这里输入图片标题")

_PhotoBrowser_: 图片浏览器，支持图片拉伸缩放，长途浏览，图片保存

    [CCPBViewController showWithViewController:UIViewControlle photos:^NSArray *{
            CCPBPhotoModel *netModel = [[CCPBPhotoModel alloc] init];
            netModel.netUrl = @"http://图片地址";
            
            CCPBPhotoModel *localModel = [[CCPBPhotoModel alloc] init];
            localModel.image = image;
            return @[netModel, localModel];
    } type:CCPBVCShowTypeTransition atIndex:0];

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/110040_f432b3df_767740.png "在这里输入图片标题")

**自定义控件介绍**

_CCSegmentedControl_：类似于UISegmentedControl控件

    self.segmentedControl = [[CCSegmentedControl alloc] initWithFrame:CGRectMake(IS_IPHONE_5_OR_LESS ? 45 : 60, 0, APP_WIDTH - (IS_IPHONE_5_OR_LESS ? 90 : 120), 44) items:@[@"同城", @"健身房", @"关注"]];
    [self.navigationBarView addSubview:self.segmentedControl];

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/110542_7e256d6d_767740.png "在这里输入图片标题")

_CCNavigationBarMenu_：显示在Navigationbar上的下拉菜单

    self.menuItemsThree = [NSMutableArray array];
    menuImages = @[@"icon_menu_venue", @"icon_menu_map", @"icon_menu_search", @"icon_menu_scan"];
    menuTitles = @[@"场馆资料", @"地图查找", @"搜索", @"扫一扫"];
    for (int i = 0; i < menuImages.count; i++) {
        CCNavigationBarMenuItem *item = [CCNavigationBarMenuItem navigationBarMenuItemWithImage:[UIImage imageNamed:menuImages[i]] title:menuTitles[i]];
        [self.menuItemsThree addObject:item];
    }
    
    self.menu = [[CCNavigationBarMenu alloc] initWithOrigin:CGPointMake(APP_WIDTH - (IS_IPHONE_5_OR_LESS ? 150 : 170), 64) width:IS_IPHONE_5_OR_LESS ? 140 : 160];
    self.menu.items = self.menuItemsOne;
    [self.menu show];

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/110839_b1ef1a04_767740.png "在这里输入图片标题")

CCActionSheet：类似于UIActionSheet

    self.actionSheet = [[CCActionSheet alloc] initWithTitle:nil delegate:^(CCActionSheet * _Nonnull actionSheet, NSInteger index) {
                 if (index == 0) {
                     [self _deleteWithRow:button.tag];
                 }
             } cancelButtonTitle:@"取消" otherButtonTitles:@"举报", @"收藏", nil];

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/111128_7fcc6469_767740.png "在这里输入图片标题")

_CCStackMenu_：可伸缩Menu，支持设置展开方向、文字方向

    if (self.stackMenu == nil) {
            CCStackMenuItem *albumMenuItem = [CCStackMenuItem stackMenuItemWithImage:[UIImage imageNamed:@"icon_dy_publish_album"] highlightedImage:nil title:@"相册" titlePosition:CCStackMenuItemTitlePositionRight];
            CCStackMenuItem *cameraMenuItem = [CCStackMenuItem stackMenuItemWithImage:[UIImage imageNamed:@"icon_dy_publish_camera"] highlightedImage:nil title:@"拍照" titlePosition:CCStackMenuItemTitlePositionRight];
            self.stackMenu = [[CCStackMenu alloc] initWithItems:@[albumMenuItem, cameraMenuItem]];
            self.stackMenu.delegate = self;
            self.stackMenu.itemsSpacing = 0;
            self.stackMenu.itemsSize = CGSizeMake(FLOAT_BUTTON_WIDTH, FLOAT_BUTTON_WIDTH);
        }
        if (self.stackMenu.isShow) {
            [self.stackMenu dismiss];
        } else {
            [self.stackMenu showInView:self.floatingButton.superview append:self.floatingButton];
        }

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/111500_1ebec9cc_767740.png "在这里输入图片标题")

_CCSpecialTextView_：支持@ #tag# 自定义文字高亮显示

    // 初始化控件
    self.specialTextView = [[CCSpecialTextView alloc] init];
    self.specialTextView.limitLength = 200;
    self.specialTextView.font = [UIFont systemFontOfSize:IS_IPHONE_5_OR_LESS ? 15 : 16];
    self.specialTextView.textColor = [UIColor darkTextColor];
    self.specialTextView.placeholder = @"说点什么呢？";
    [self.view addSubview:self.specialTextView];
    [self.specialTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.mas_equalTo(IS_IPHONE_5_OR_LESS ? 100 : 120);
    }];

    // 新增标签
    TagModel *model = self.allTagArray[indexPath.row];
    NSString *tagPattern = [NSString stringWithFormat:@"#%@#", model.tagName];
    for (TagModel *tmpModel in self.selectedTagArray) {
        if ([tmpModel.tagId isEqualToString:model.tagId]) return;
    }
    _[self.specialTextView addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRGBHexString:@"#fb5f46"]} forPattern:tagPattern]_;
    self.specialTextView.text = [NSString stringWithFormat:@"%@%@ ", self.specialTextView.text, tagPattern];    

    // 标签回调
    self.specialTextView.deleteHandler = ^(CCSpecialTextView *textView, NSString *string, NSRange range) {
        // 处理标签删除
    };

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/113235_309bdeb7_767740.png "在这里输入图片标题")

_CCLabel_：高亮显示@ #tag# 自定义文字，并且添加点击事件

    // 初始化控件
    self.contentLabel = [[CCLabel alloc] init];
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.linkTypeOptions = CCLinkTypeOptionCustom;
    [self.contentLabel setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRGBHexString:@"#fb5f46"], NSForegroundColorAttributeName, nil] forLinkType:CCLinkTypeCustom];
    self.contentLabel.font = [UIFont appFontOfSize:IS_IPHONE_5_OR_LESS ? 15 : 15.5];
    self.contentLabel.textColor = [UIColor colorWithRGBHexString:@"#4a4a4a"];
    self.contentLabel.text = @"干你妹儿的，fuck";
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_bottom).offset(IS_IPHONE_5_OR_LESS ? 8 : 10);
        make.left.equalTo(self.headImageView.mas_left);
        make.right.equalTo(self.timeLabel.mas_right);
    }];

    // 为控件设置自定义高亮文字
    NSMutableString *regexPattern = [NSMutableString string];
    for (TagModel *tagModel in model.tags) {
        if ([regexPattern isEqualToString:@""]) {
            [regexPattern appendString:[NSString stringWithFormat:@"#%@#", tagModel.tagName]];
        } else {
            [regexPattern appendFormat:@"|#%@#", tagModel.tagName];
        }
    }
    self.contentLabel.regexPattern = regexPattern;
    self.contentLabel.text = model.content;

    // 高亮文字点击回调
    self.contentLabel.customLinkTapHandler = ^(CCLabel *label, NSString *string, NSRange range) {
        // 处理点击事件
    };

![输入图片说明](http://git.oschina.net/uploads/images/2016/0522/112231_264744ca_767740.png "在这里输入图片标题")