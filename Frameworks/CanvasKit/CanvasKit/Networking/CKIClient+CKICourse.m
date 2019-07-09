//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@import ReactiveObjC;

#import "CKIClient+CKIModel.h"
#import "CKIClient+CKICourse.h"
#import "CKICourse.h"
#import "CKIEnrollment.h"

@implementation CKIClient (CKICourse)

- (NSDictionary *)parametersForFetchingCourses
{
    return @{@"include": @[@"needs_grading_count", @"syllabus_body", @"total_scores", @"term", @"permissions", @"current_grading_period_scores"]};
}

- (RACSignal *)fetchCoursesForCurrentUser
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"courses"];
    
    return [[self fetchResponseAtPath:path parameters:[self parametersForFetchingCourses] modelClass:[CKICourse class] context:nil] map:^id(NSArray *courses) {
        [courses enumerateObjectsUsingBlock:^(CKICourse *course, NSUInteger idx, BOOL *stop) {
            [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                enrollment.id = [NSString stringWithFormat:@"%@-c-%@", @(idx), course.id];
                enrollment.context = course;
            }];
        }];
        return courses;
    }];
}

- (NSDictionary *)parametersForFetchingCoursesCurrentDomain
{
    return @{@"include": @[@"needs_grading_count", @"syllabus_body", @"total_scores", @"term", @"permissions", @"current_grading_period_scores"],
             @"current_domain_only": @"true"};
}

- (RACSignal *)fetchCoursesForCurrentUserCurrentDomain
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"courses"];
    
    return [[self fetchResponseAtPath:path parameters:[self parametersForFetchingCoursesCurrentDomain] modelClass:[CKICourse class] context:nil] map:^id(NSArray *courses) {
        [courses enumerateObjectsUsingBlock:^(CKICourse *course, NSUInteger idx, BOOL *stop) {
            [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
                enrollment.id = [NSString stringWithFormat:@"%@-c-%@", @(idx), course.id];
                enrollment.context = course;
            }];
        }];
        return courses;
    }];
}

- (RACSignal *)fetchCourseWithCourseID:(NSString *)courseID
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"courses"] stringByAppendingPathComponent:courseID];
    return [[self fetchResponseAtPath:path parameters:[self parametersForFetchingCourses] modelClass:[CKICourse class] context:nil] map:^id(CKICourse *course) {
        CKICourse *courseCopy = [course copy];
        
        [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
            enrollment.id = [NSString stringWithFormat:@"%@-c-%@", @(idx), course.id];
            enrollment.context = courseCopy;
        }];
        return course;
    }];
}

- (RACSignal *)courseWithUpdatedPermissionsSignalForCourse:(CKICourse *)course
{
    return [self refreshModel:course parameters:[self parametersForFetchingCourses]];
}

@end
