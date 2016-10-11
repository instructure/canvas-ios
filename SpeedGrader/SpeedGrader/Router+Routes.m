//
//  Router+Routes.m
//  iCanvas
//
//  Created by Nathan Lambson on 5/19/15.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "Router+Routes.h"

#import "CSGGradingViewController.h"
#import "CSGUnsupportedDocumentViewController.h"
#import <CanvasKit/CanvasKit.h>
#import "CSGAppDataSource.h"

typedef UIViewController *(^ViewControllerRouteBlock)(NSDictionary *params);

@implementation Router (Routes)

- (void)configureInitialRoutes {
    [self addRoutes];
}

#pragma mark - iPad Routes
- (void)addRoutes {
    [self addRoutesWithDictionary:@{
        @"/courses/:courseID/assignments/:assignmentID" : ^(NSDictionary *params) {
            CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
            CKIAssignment *assignment = [CKIAssignment modelWithID:[params[@"assignmentID"] description] context:course];
        
            CSGGradingViewController *VC = [CSGGradingViewController instantiateFromStoryboard];
            [VC fetchDataForAssignment:assignment forCourse:course];
            return VC;
        }
    }];
}

BOOL waitForBlock(NSTimeInterval timeout, BOOL (^condition)(void)) {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    BOOL val = condition();
    while ( val == NO && [timeoutDate timeIntervalSinceNow] > 0 ) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        val = condition();
    }
    return val;
}

@end