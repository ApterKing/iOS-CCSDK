//
//  CCComboBox.m
//  CCSDK
//
//  Created by wangcong on 15-1-22.
//  Copyright (c) 2015年 wangcong. All rights reserved.
//

#import "CCComboBox.h"

#define ROW_HEIGHT 30  //每行显示高
#define ROWLINE 6      //显示最大行数，可以自行设定

@interface CCComboBox (Private)

- (void)fadeIn;
- (void)fadeOut;

@end

@implementation CCComboBox

- (id)initWithButton:(UIButton *)button
{
    self = [super initWithFrame:button.frame];
    if (self) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
        _currentRow = 0;
        _button = button;
        _button.frame = button.bounds;
        [_button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void) setDataArray:(NSArray *)dataArray
{
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:dataArray];
    if (_dataArray.count > 0) {
        [_button setTitle:[_dataArray objectAtIndex:0] forState:UIControlStateNormal];
        if (_delegate && [_delegate respondsToSelector:@selector(comboBoxSelected:atIndex:)]) {
            [_delegate comboBoxSelected:self atIndex:0];
        }
    }
    if (_tableView) {
        [_tableView reloadData];
        CGRect originalFrame = _tableView.frame;
        _tableView.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, _dataArray.count > _rowMaxLines ? ROW_HEIGHT *_rowMaxLines : ROW_HEIGHT * _dataArray.count);
    }
}

- (NSArray *)getDataArray
{
    return _dataArray;
}

#pragma mark - UIButton
- (void)setComboBoxBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [_button setBackgroundImage:image forState:state];
}

- (void)setComboBoxFrame:(CGRect)frame
{
    self.frame = frame;
    _button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (id)getComboBoxSelectedItem
{
    return _button.titleLabel.text;
}

- (void)setComboBoxSelected:(NSUInteger)index
{
    [self setComboBoxSelected:index delegate:YES];
}

- (void)setComboBoxSelected:(NSUInteger)index delegate:(BOOL)isDoDelegate
{
    if (index < _dataArray.count) {
        _currentRow = index;
        [_button setTitle:[_dataArray objectAtIndex:index] forState:UIControlStateNormal];
        if (isDoDelegate && _delegate && [_delegate respondsToSelector:@selector(comboBoxSelected:atIndex:)]) {
            [_delegate comboBoxSelected:self atIndex:index];
        }
    } else {
        //        @throw <#expression#>
    }
}

#pragma mark - UITableView
- (void)setComboBoxShowMaxLine:(NSUInteger)count
{
    _rowMaxLines = count;
    if (_tableView) {
        CGRect originalFrame = _tableView.frame;
        _tableView.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, _dataArray.count > _rowMaxLines ? ROW_HEIGHT *_rowMaxLines : ROW_HEIGHT * _dataArray.count);
    }
}

- (void)clickAction:(id)sender
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.layer.borderWidth = 1;
        _tableView.layer.borderColor = [[UIColor grayColor] CGColor];
        //        _tableView.layer.cornerRadius = 5;
        
        _overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _overlayView.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.1];
        [_overlayView addTarget:self action:@selector(fadeOut) forControlEvents:UIControlEventTouchUpInside];
    }
    CGRect buttonRect = [_button convertRect:_button.bounds toView:[[UIApplication sharedApplication] keyWindow]];
    _rowMaxLines = _rowMaxLines == 0 ? ROWLINE : _rowMaxLines;
    _tableView.frame = CGRectMake(buttonRect.origin.x, buttonRect.origin.y + buttonRect.size.height + 1, buttonRect.size.width, _dataArray.count > _rowMaxLines ? ROW_HEIGHT * _rowMaxLines : ROW_HEIGHT * _dataArray.count);
    if (_dataArray.count != 0) {
        [self fadeIn];
    }
}

#pragma mark - UITableViewDataDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [_dataArray objectAtIndex:[indexPath row]];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_button setTitle:[_dataArray objectAtIndex:[indexPath row]] forState:UIControlStateNormal];
    if (_delegate && _currentRow != [indexPath row]) {
        [_delegate comboBoxSelected:self atIndex:indexPath.row];
    }
    _currentRow = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self fadeOut];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % 1 == 0) {
        //cell.backgroundColor = [UIColor grayColor];
    }
}
#pragma mark - private

- (void)fadeIn
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:_overlayView];
    [window addSubview:_tableView];
    _tableView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    _tableView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        _tableView.alpha = 1;
        _tableView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.15 animations:^{
        _tableView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        _tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            _tableView.transform = CGAffineTransformMakeScale(1, 1);
            [_overlayView removeFromSuperview];
            [_tableView removeFromSuperview];
        }
    }];
}

@end
