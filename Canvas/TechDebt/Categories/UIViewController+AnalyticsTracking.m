//
//  UIViewController+AnalyticsTracking.m
//  iCanvas
//
//  Created by BJ Homer on 2/5/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UIViewController+AnalyticsTracking.h"
#import <GoogleAnalytics/GAIFields.h>
#import "Analytics.h"

@implementation UIViewController (AnalyticsTracking)

- (void)sendTrackingByClassName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    NSString *className = NSStringFromClass([self class]);
    NSString *viewName = [className stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    
    [Analytics logScreenView:viewName];
}

- (void)trackScreenViewWithScreenName:(NSString *)screenName
{
    
    [Analytics logScreenView:screenName];
}


@end
