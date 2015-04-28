//
//  LSEGORefreshTableView.m
//  UITabViewDemo
//
//  Created by Bob on 14-4-23.
//  Copyright (c) 2014年 guobo. All rights reserved.
//

#import "IUEGORefreshTableView.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface IUEGORefreshTableView()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    UITableView*                            _pullTableView;
    EGORefreshTableHeaderView*              _egoHeadView;
    EGORefreshTableFooterView*              _egoFootView;
    BOOL                                    _isHeadRefreshViewLoading;
    BOOL                                    _isFootRefreshViewLoading;
    /**
     *  点击了外部按钮来刷新
     */
    BOOL                                    _isOutRefreshViewLoading;
    BOOL                                    _isHeadRefreshViewExsit;
    BOOL                                    _isFootRefreshViewExsit;
}

@end

@implementation IUEGORefreshTableView

#pragma mark lifecycle method
-(void)dealloc
{
    _delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[[self class]alloc]initWithFrame:frame withEgoRefreshHeadView:NO withEgoRefreshFootView:NO];
    return self;
}

- (id)initWithFrame:(CGRect)frame withEgoRefreshHeadView:(BOOL)isHeadRefreshViewExsit withEgoRefreshFootView:(BOOL)isFootRefreshViewExsit
{
    self = [super initWithFrame:frame];
    _loadMorePostion = 200;
    
    if (self)
    {
        _pullTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        
        _pullTableView.delegate = self;
        _pullTableView.dataSource = self;
        
        [self addSubview:_pullTableView];
        
        self.autoresizingMask = _pullTableView.autoresizingMask;
        
        _pullTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        _pullTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
        [self showHeadRefreshView:isHeadRefreshViewExsit];
        [self showFootRefreshView:isFootRefreshViewExsit];
        if(_egoHeadView)
        {
            [_egoHeadView refreshLastUpdatedDate];
        }
    }
    return self;
}

- (CGFloat)getOffsetY
{
    return _pullTableView.contentOffset.y;
}


#pragma mark public method
-(UITableView*)getTableView
{
    return _pullTableView;
}

-(void)showHeadRefreshView:(BOOL)isExist
{
    _isHeadRefreshViewExsit = isExist;
    if (_isHeadRefreshViewExsit)
    {
        _egoHeadView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        _egoHeadView.delegate = self;
        [_pullTableView addSubview:_egoHeadView];
    }
}

-(void)showFootRefreshView:(BOOL)isExist
{
    _isFootRefreshViewExsit = isExist;
    if (_isFootRefreshViewExsit)
    {
        _egoFootView = [EGORefreshTableFooterView loadFromXib];
        _pullTableView.tableFooterView = _egoFootView;
        _pullTableView.tableFooterView.alpha = 0;
    }
}

-(void)refreshView
{
    [UIView animateWithDuration:0.3 animations:^{
        _pullTableView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
    }completion:^(BOOL finished) {
        if ([self getOffsetY]<=0 && _egoHeadView)
        {
            return [_egoHeadView egoRefreshScrollViewDidEndDragging:_pullTableView];
        }
    }];
}

-(void)reloadData
{
    if (_isHeadRefreshViewLoading)
    {
        [_pullTableView reloadData];
        [_egoHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:_pullTableView];
    }
    else
    {
        [_pullTableView reloadData];
    }
    _isHeadRefreshViewLoading = NO;
    _isFootRefreshViewLoading = NO;
    _isOutRefreshViewLoading = NO;
}
-(void)stopPullDownEgoRefresh
{
    if (_isHeadRefreshViewLoading)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_egoHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:_pullTableView];
        });
    }
    
    _isHeadRefreshViewLoading = NO;
    _isFootRefreshViewLoading = NO;
    _isOutRefreshViewLoading = NO;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [_pullTableView dequeueReusableCellWithIdentifier:identifier];
}

-(void)setSeperatorLine:(UITableViewCellSeparatorStyle)style
{
    _pullTableView.separatorStyle = style;
}

-(void)setTableHeadView:(UIView*)headView
{
    _pullTableView.tableHeaderView = headView;
    [_pullTableView bringSubviewToFront:_egoHeadView];
}

-(void)setTableFootView:(UIView*)footView
{
    _pullTableView.tableFooterView = footView;
}

-(void)refreshData
{
    _isFootRefreshViewLoading = NO;
    _isHeadRefreshViewLoading = NO;
    _isOutRefreshViewLoading = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(manualEgoRefreshTableView:)]) {
        [_delegate manualEgoRefreshTableView:self];
    }
}
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //  是否有外部按钮刷
    if (_isOutRefreshViewLoading)
    {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(egoScrollViewDidScroll:)]) {
        [_delegate egoScrollViewDidScroll:_pullTableView];
    }
    //  下拉
    if ([self getOffsetY]<=0 && _egoHeadView)
    {
        [_egoHeadView egoRefreshScrollViewDidScroll:scrollView];
    }
    //  上拉，且还有没加载的数据
    else if(_isFootRefreshViewExsit)
    {
        // load more
        if(!_isCompleted && [self getOffsetY] + _pullTableView.frame.size.height + _loadMorePostion >= _pullTableView.contentSize.height)
        {
            if (!_isFootRefreshViewLoading && !_isHeadRefreshViewLoading)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(pullUpEgoRefreshTableView:)])
                {
                    if (_pullTableView.contentSize.height>_pullTableView.frame.size.height)
                    {
                        _isFootRefreshViewLoading = YES;
                        _pullTableView.tableFooterView = _egoFootView;
                        _pullTableView.tableFooterView.alpha = 1;
                        [_delegate pullUpEgoRefreshTableView:self];
                    }
                }
            }
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y<=0 && _egoHeadView)
    {
        return [_egoHeadView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark UITableViewDelegate & UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate egoRefreshTableView:self cellForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate egoRefreshTableView:self heightForRowAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_pullTableView.numberOfSections == section + 1)
    {
        if (_egoFootView)
        {
            if (!_isCompleted)
            {
                [_egoFootView viewLayoutWithStype:LS_EGOFOOT_VIEW_TYPE_LOADING];
            }
            else
            {
                if(!_isRemoveFootViewWhenLoadMoreCompleted)
                {
                    [_egoFootView viewLayoutWithStype:LS_EGOFOOT_VIEW_TYPE_NO_MORE];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        _pullTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
                    });
                }
            }
        }
    }
    return [_delegate egoRefreshTableView:self numberOfRowsInSection:section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfSectionsInEgoRefreshTableView:)])
    {
        return [_delegate numberOfSectionsInEgoRefreshTableView:self];
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:didSelectRowAtIndexPath:)])
    {
        [_delegate egoRefreshTableView:self didSelectRowAtIndexPath:indexPath];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:heightForHeaderInSection:)])
    {
        return [_delegate egoRefreshTableView:self heightForHeaderInSection:section];
    }
    return 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:viewForHeaderInSection:)])
    {
        return [_delegate egoRefreshTableView:self viewForHeaderInSection:section];
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:viewForFooterInSection:)])
    {
        return [_delegate egoRefreshTableView:self viewForFooterInSection:section];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:heightForFooterInSection:)])
    {
        return [_delegate egoRefreshTableView:self heightForFooterInSection:section];
    }
    return 0;
}

/*
 *删除 编辑
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:canEditRowAtIndexPath:)])
    {
        return [_delegate egoRefreshTableView:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:editingStyleForRowAtIndexPath:)])
    {
        return [_delegate egoRefreshTableView:self editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
    {
        return [_delegate egoRefreshTableView:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(IUEGORefreshTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:commitEditingStyle:forRowAtIndexPath:)])
    {
        [_delegate egoRefreshTableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(egoRefreshTableView:didDeselectRowAtIndexPath:)])
    {
        [_delegate egoRefreshTableView:self didDeselectRowAtIndexPath:indexPath];
    }
}

-(void)reloadSections:(NSIndexPath*)indexPath
{
    [_pullTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    _isHeadRefreshViewLoading = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(pullDownEgoRefreshTableView:)])
    {
        [_delegate pullDownEgoRefreshTableView:self];
    }
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _isHeadRefreshViewLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}


#pragma mark private method


@end
