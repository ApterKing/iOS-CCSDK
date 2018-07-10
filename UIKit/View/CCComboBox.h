//
//  CCComboBox.h
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import <UIKit/UIKit.h>

//设置代理
@class CCComboBox;
@protocol CCComboBoxDelegate <NSObject>

@optional
- (void)comboBoxSelected:(CCComboBox *)comboBox atIndex:(NSUInteger)index;

@end

@interface CCComboBox : UIView<UITableViewDataSource, UITableViewDelegate>
{
@private
    UIButton *_button;
    UITableView *_tableView;
    NSUInteger _currentRow;
    NSUInteger _rowMaxLines;
    UIControl *_overlayView;
    NSMutableArray *_dataArray;
}
@property (assign, nonatomic) id<CCComboBoxDelegate> delegate;

- (id)initWithButton:(UIButton *)button;
- (void)setDataArray:(NSArray *)dataArray;
- (NSArray *)getDataArray;
@end

@interface CCComboBox (UIButton)
- (id)getComboBoxSelectedItem;
- (void)setComboBoxSelected:(NSUInteger)index;
- (void)setComboBoxSelected:(NSUInteger)index delegate:(BOOL)isDoDelegate;

@end

@interface CCComboBox (UITableView)
- (void)setComboBoxShowMaxLine:(NSUInteger)count;

@end
