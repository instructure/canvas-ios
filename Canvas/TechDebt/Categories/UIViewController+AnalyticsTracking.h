//
//  UIViewController+AnalyticsTracking.h
//  iCanvas
//
//  Created by BJ Homer on 2/5/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAnalytics/GAI.h>

@interface UIViewController (AnalyticsTracking)

- (void)sendTrackingByClassName;
- (void)trackScreenViewWithScreenName:(NSString *)screenName;

@end
