//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
