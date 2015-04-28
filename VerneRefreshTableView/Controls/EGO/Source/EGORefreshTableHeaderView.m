//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


//#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

#define TEXT_COLOR	 [UIColor lightGrayColor]

#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView
static const CGFloat kMaxOffsetYToFrefresh = 65.0f;
@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor
{
    if((self = [super initWithFrame:frame]))
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.hidden = YES;
        [self addSubview:label];
        _lastUpdatedLabel=label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 36.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = [UIColor lightGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(self.frame.size.width/2-65, frame.size.height - 32.25f, 9, 12.5);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        
        [[self layer] addSublayer:layer];
        _arrowImage=layer;
        
        [self setState:EGOOPullRefreshNormal];
        
        _statusImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"load_refresh_rotate.png"]];
        [self addSubview:_statusImageView];
        _statusImageView.frame = CGRectMake(self.frame.size.width/2-65, frame.size.height - 33.0f, 14, 14);
        _statusImageView.hidden = YES;
        [self startImageViewAnimation];
    }
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame arrowImageName:@"blueArrow.png" textColor:TEXT_COLOR];
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate
{
    
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
        
        NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
        
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [LSTimeHelper formatTime:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else
    {
        _lastUpdatedLabel.text = nil;
    }
    
}

- (void)setState:(EGOPullRefreshState)aState
{
    switch (aState)
    {
        case EGOOPullRefreshPulling:
            _statusLabel.text = TEXT_PULL_UP_RELEX;
            _arrowImage.hidden = NO;
            _statusImageView.hidden = YES;
            break;
        case EGOOPullRefreshNormal:
            _arrowImage.hidden = NO;
            _statusImageView.hidden = YES;
            [_activityView stopAnimating];
            _statusLabel.text = TEXT_PULL_UP_TITLE;
            [self refreshLastUpdatedDate];
            break;
        case EGOOPullRefreshLoading:
            _statusImageView.hidden = NO;
            _statusLabel.text = TEXT_PULL_LOADING;
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            // 让剪头朝下
            _arrowImage.transform = CATransform3DMakeRotation(0, 0, 0, 1);
            break;
    }
    _state = aState;
}

- (void)startImageViewAnimation
{
    if (_statusImageView.layer.animationKeys) {
        return;
    }
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: (-1 * M_PI * 2.0) ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration = .5f;
    rotationAnimation.repeatCount = MAXFLOAT;//你可以设置到最大的整数值
    rotationAnimation.cumulative = YES;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeBackwards;
    [_statusImageView.layer addAnimation:rotationAnimation forKey:@"Rotation"];
}

- (void)stopAnimatingView:(UIView*)animatingView
{
    [animatingView.layer removeAllAnimations];
    animatingView.hidden = YES;
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_state == EGOOPullRefreshLoading)
    {
        CGFloat offset = MAX(offsetY * -1, 0);
        offset = MIN(offset, kMaxOffsetYToFrefresh);
        // 正在刷新的时候，把Scrollview固定
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    }
    else if (scrollView.isDragging)
    {
        BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
        }
        
        if (_state == EGOOPullRefreshPulling && offsetY > -kMaxOffsetYToFrefresh && offsetY < 0.0f && !_loading)
        {
            [self setState:EGOOPullRefreshNormal];
        }
        else if (_state == EGOOPullRefreshNormal && offsetY < -kMaxOffsetYToFrefresh && !_loading)
        {
            [self setState:EGOOPullRefreshPulling];
        }
        if(!_loading)
        {
            _arrowImage.hidden = NO;
            offsetY = MAX(-kMaxOffsetYToFrefresh, offsetY);
            _arrowImage.transform = CATransform3DMakeRotation(offsetY / kMaxOffsetYToFrefresh * M_PI, 0, 0, 1);
        }
        
        if (scrollView.contentInset.top != 0)
        {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.y <= -kMaxOffsetYToFrefresh && !_loading)
    {
        [self setState:EGOOPullRefreshLoading];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [scrollView setContentOffset:CGPointMake(0, -kMaxOffsetYToFrefresh) animated:NO];
            }completion:^(BOOL finished) {
                if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
                    [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
                }
            }];
        });
        
    }
    
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    [self setState:EGOOPullRefreshNormal];
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
    _delegate=nil;
    _activityView = nil;
    _statusLabel = nil;
    _arrowImage = nil;
    _lastUpdatedLabel = nil;
}
@end
