# VerneRefreshTableViewByEgoRefresh

移除Ego原有的TotalRows，LoadedRows，CustomRows。
移除PageSize。
移除多余内部变量。
修改判断条件，但不影响本身的功能点。
移除多余判断代码。


加入isCompleted 控制是否可以加载更多。
加入isRemoveFootViewWhenLoadMoreCompleted 控制在加载完全之后是否删除底部View。
