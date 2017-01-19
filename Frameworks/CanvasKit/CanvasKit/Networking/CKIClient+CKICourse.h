//
//  CKIClient+CKICourse.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class RACSignal, CKICourse;

@interface CKIClient (CKICourse)

- (RACSignal *)fetchCoursesForCurrentUser;

- (RACSignal *)fetchCoursesForCurrentUserCurrentDomain;

- (RACSignal *)courseWithUpdatedPermissionsSignalForCourse:(CKICourse *)course;

- (RACSignal *)fetchCourseWithCourseID:(NSString *)courseID;

@end
