//
//  EGORefreshConstant.h
//  UITabViewDemo
//
//  Created by Bob on 14-4-23.
//  Copyright (c) 2014年 guobo. All rights reserved.
//

#ifndef UITabViewDemo_EGORefreshConstant_h
#define UITabViewDemo_EGORefreshConstant_h
#define TEXT_PULL_UP_TITLE @"下拉刷新"
#define TEXT_PULL_UP_RELEX @"松开即可刷新"
#define TEXT_PULL_LOADING @"加载中..."

//typedef enum
//{
//    EGOPULLHEADVIEW_STYLE_ROTATE_IMAGE=0,//旋转图片
//    EGOPULLHEADVIEW_STYLE_ACTIVITY_VIEW=1//UIActivityIndicatorView
//}EGOPULLHEADVIEW_STYLE;

typedef enum{
    /**
     *  正在拉动
     */
	EGOOPullRefreshPulling = 0,
    /**
     *  已经超出刷新offsetY的临界值
     */
	EGOOPullRefreshNormal,
    /**
     *  正在执行动画
     */
	EGOOPullRefreshLoading,
} EGOPullRefreshState;

#endif
