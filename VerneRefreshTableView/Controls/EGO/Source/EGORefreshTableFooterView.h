//
//  EGORefreshTableFooterView.h
//  UITabViewDemo
//
//  Created by Bob on 14-4-24.
//  Copyright (c) 2014年 guobo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    LS_EGOFOOT_VIEW_TYPE_LOADING=0,
    LS_EGOFOOT_VIEW_TYPE_NO_MORE
}LS_EGOFOOT_VIEW_TYPE;
@interface EGORefreshTableFooterView : UIView

-(void)viewLayoutWithStype:(LS_EGOFOOT_VIEW_TYPE)type;
+(id)loadFromXib;
@end
