//
//  CSGFlyingPandaRefreshControl.h
//  SpeedGrader
//
//  Created by Ben Kraus on 12/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaRefreshControl : CSGFlyingPandaAnimationView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView target:(id)target action:(SEL)action;

// Call these in the associated delegate methods in the scrollView.
- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

// Use this to kick off a refresh/loading programmatically only. It will call the action established
// in the initializer immediately, and adjust the contentInset of the scrollView accordingly.
- (void)startLoading;

// Call this whenever the data has been fetched and the refresh animation should be done.
- (void)finishLoading;

@end
