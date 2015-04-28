//
//  LSEGORefreshTableView.h
//  UITabViewDemo
//
//  Created by Bob on 14-4-23.
//  Copyright (c) 2014年 guobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshConstant.h"
@protocol IUEGORefreshTableViewDelegate;

@interface IUEGORefreshTableView : UIView

@property (weak,nonatomic) id<IUEGORefreshTableViewDelegate> delegate;

/**
 *  y到达多少之后开始加载更多
 *  默认：200
 */
@property (assign,nonatomic) NSInteger loadMorePostion;

/**
 *  是否没有更多
 */
@property (assign,nonatomic) BOOL isCompleted;
/**
 *  加载全部完成后是否移除底部View
 */
@property (assign,nonatomic) BOOL isRemoveFootViewWhenLoadMoreCompleted;

- (id)initWithFrame:(CGRect)frame withEgoRefreshHeadView:(BOOL)isHeadRefreshViewExsit withEgoRefreshFootView:(BOOL)isFootRefreshViewExsit;
/**
 *  获取当前View中的UITableView
 *
 *  @return UITableView
 */
-(UITableView*)getTableView;
/**
 *  设置下拉刷新是否存在
 *
 *  @param isExist
 */
-(void)showHeadRefreshView:(BOOL)isExist;
/**
 *  设置上拉刷新是否存在
 *
 *  @param isExist
 */
-(void)showFootRefreshView:(BOOL)isExist;
/**
 *  刷新UITableView的数据（注：不能直接使用UITableview的reloadData直接去刷新数据）
 */
-(void)reloadData;

/**
 *  重用Cell
 *
 *  @param identifier cell的标志
 *
 *  @return cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**
 *  设置分割线
 *
 *  @param style UITableViewCellSeparatorStyle
 */
-(void)setSeperatorLine:(UITableViewCellSeparatorStyle)style;

-(void)setTableHeadView:(UIView*)headView;
-(void)setTableFootView:(UIView*)footView;
/**
 *  手动点击刷新按钮时调用
 */
-(void)refreshData;
/**
 *  第一次加载网络请求时调用
 */
-(void)refreshView;
/*
 *@note 当数据加载失败时候，使用此方法使下拉界面恢复原状。不必调用reloadData。
 */
-(void)stopPullDownEgoRefresh;
@end

@protocol IUEGORefreshTableViewDelegate <NSObject>
@required

-(UITableViewCell *)egoRefreshTableView:(IUEGORefreshTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)egoRefreshTableView:(IUEGORefreshTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)egoRefreshTableView:(IUEGORefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
@optional
-(void)egoRefreshTableView:(IUEGORefreshTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)egoRefreshTableView:(IUEGORefreshTableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView*)egoRefreshTableView:(IUEGORefreshTableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)egoRefreshTableView:(IUEGORefreshTableView *)tableView heightForFooterInSection:(NSInteger)section;
-(UIView*)egoRefreshTableView:(IUEGORefreshTableView *)tableView viewForFooterInSection:(NSInteger)section;
-(NSInteger)numberOfSectionsInEgoRefreshTableView:(IUEGORefreshTableView *)tableView;
/*
 *删除 编辑
 */
- (BOOL)egoRefreshTableView:(IUEGORefreshTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)egoRefreshTableView:(IUEGORefreshTableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)egoRefreshTableView:(IUEGORefreshTableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)egoRefreshTableView:(IUEGORefreshTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)egoRefreshTableView:(IUEGORefreshTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)egoScrollViewDidScroll:(UITableView*)tableView;
-(void)reloadSections:(NSIndexPath*)indexPath;
/**
 *  下拉刷新数据代理方法
 */
-(void)pullDownEgoRefreshTableView:(IUEGORefreshTableView*)tableView;
/**
 *  上拉刷新数据代理方法
 */
-(void)pullUpEgoRefreshTableView:(IUEGORefreshTableView*)tableView;
/**
 *  手动点击刷新按钮的代理方法
 *
 */
-(void)manualEgoRefreshTableView:(IUEGORefreshTableView*)tableView;
-(void)autoLoadMoreRefreshEgoRefreshTableView:(IUEGORefreshTableView*)tableView;

@end