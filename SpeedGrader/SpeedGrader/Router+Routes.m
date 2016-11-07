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