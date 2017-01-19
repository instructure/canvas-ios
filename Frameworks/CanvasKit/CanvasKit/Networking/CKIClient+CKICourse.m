//
//  CKIClient+CKICourse.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
