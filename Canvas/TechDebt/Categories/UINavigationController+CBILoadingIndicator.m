
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
