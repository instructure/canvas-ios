//
//  CKIClient+CKIAssignment.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIAssignment.h"
#import "CKIAssignment.h"
#import "CKICourse.h"

static const NSString *CKIAssignmentPutParameter = @"assignment";
static const NSString *CKIAssignmentMutedParameter = @"muted";

@implementation CKIClient (CKIAssignment)

- (RACSignal *)fetchAssignmentsForContext:(id<CKIContext>)context
{
    return [self fetchAssignmentsForContext:context includeSubmissions:YES];
}

- (RACSignal *)fetchAssignmentsForContext:(id<CKIContext>)context includeSubmissions:(BOOL)includeSubmissions
{
    NSString *path = [[context path] stringByAppendingPathComponent:@"assignments"];
    NSDictionary *params = nil;
    if (includeSubmissions) {
        params = @{@"include": @[@"submission", @"needs_grading_count", @"observed_users"], @"needs_grading_count_by_section":@"true"};
    } else {
        params = @{@"include": @[@"needs_grading_count"], @"needs_grading_count_by_section": @"true"};
    }
    
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIAssignment class] context:context];
}

- (RACSignal *)updateMutedForAssignment:(CKIAssignment *)assignment
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[CKIAssignmentPutParameter] = @{CKIAssignmentMutedParameter:@(assignment.muted)};
    
    return [self updateModel:assignment parameters:parameters];
}

@end
