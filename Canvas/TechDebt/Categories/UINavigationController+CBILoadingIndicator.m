//
//  UINavigationController+CBILoadingIndicator.m
//  iCanvas
//
//  Created by rroberts on 12/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UINavigationController+CBILoadingIndicator.h"

NSInteger const CBILoadingViewTagID = 100001;
CGFloat const CBILoadingViewHeight = 2.5;

@implementation UINavigationController (CBILoadingIndicator)


- (void)showInfiniteLoadingIndicator
{
    UIView *indicatorView = [self setupLoadingSubview];
    
    float maxWidth = self.navigationBar.frame.size.width;
	
	[UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		CGRect progressFrame = indicatorView.frame;
		progressFrame.size.width = maxWidth;
        progressFrame.origin.x = 0;
		indicatorView.frame = progressFrame;
		
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			indicatorView.alpha = 0;
		} completion:^(BOOL finished) {
			[indicatorView removeFromSuperview];
		}];
	}];
}

- (void)hideInfiniteLoadingIndicator
{
    
}
                             
- (UIView *)setupLoadingSubview
{
    float y = self.navigationBar.frame.size.height - CBILoadingViewHeight;
    
    UIView *progressView;
    for (UIView *subview in [self.navigationBar subviews])
    {
        if (subview.tag == CBILoadingViewTagID)
        {
            progressView = subview;
        }
    }
    
    if(!progressView)
    {
        progressView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationBar.frame.size.width * 0.5, y, 0, CBILoadingViewHeight)];
        progressView.tag = CBILoadingViewTagID;
        progressView.backgroundColor = [UIColor blueColor];
        [self.navigationBar addSubview:progressView];
    }
    else
    {
        CGRect progressFrame = progressView.frame;
        progressFrame.origin.y = y;
        progressFrame.origin.x = self.navigationBar.frame.size.width * 0.5;
        progressView.frame = progressFrame;
    }
    
    return progressView;
}


@end
