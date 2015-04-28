//
//  ViewController.m
//  VerneRefreshTableView
//
//  Created by verne on 15/4/23.
//  Copyright (c) 2015年 verne. All rights reserved.
//

#import "ViewController.h"
#import "IUEGORefreshTableView.h"

@interface ViewController ()<IUEGORefreshTableViewDelegate>
{
    IUEGORefreshTableView *_tableView;
}
@property (nonatomic,assign) NSInteger maxPages;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) NSInteger listCount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _maxPages = 3;
    _currentPage = 1;
    _listCount = _currentPage * 20;
    
    _tableView = [[IUEGORefreshTableView alloc]initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64) withEgoRefreshHeadView:YES withEgoRefreshFootView:YES];
    _tableView.delegate = self;
    
    _tableView.isCompleted = NO;
    
    _tableView.isRemoveFootViewWhenLoadMoreCompleted = NO;
    
    [self.view addSubview:_tableView];
}

-(void)refresh
{
    _currentPage = 1;
    _listCount =_currentPage * 20;
    _tableView.isCompleted = NO;
    [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:3.0f];
}

-(void)loadMore
{
    _currentPage ++;
    _listCount =_currentPage * 20;
    if(_currentPage == _maxPages)
        _tableView.isCompleted = YES;
    [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:3.0f];
    
}

-(UITableViewCell *)egoRefreshTableView:(IUEGORefreshTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello"];
    cell.textLabel.text = [NSString stringWithFormat:@"hello row:%zd",indexPath.row];
    return cell;
}

-(CGFloat)egoRefreshTableView:(IUEGORefreshTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


-(NSInteger)egoRefreshTableView:(IUEGORefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listCount;
}

-(void)egoRefreshTableView:(IUEGORefreshTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView stopPullDownEgoRefresh];
}

-(void)pullUpEgoRefreshTableView:(IUEGORefreshTableView *)tableView
{
    [self loadMore];
}

-(void)pullDownEgoRefreshTableView:(IUEGORefreshTableView *)tableView
{
    [self refresh];
}

















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
