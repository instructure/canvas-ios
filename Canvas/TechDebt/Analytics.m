//
//  Analytics.m
//  Canvas
//
//  Created by Derrick Hathaway on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "Analytics.h"
#import <Google/Analytics.h>

@implementation Analytics

+ (void)prepare {
    // Configure tracker from GoogleService-Info.plist. (included in Canvas Target)
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
}

+ (void)logScreenView:(NSString*)screenName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
@end

