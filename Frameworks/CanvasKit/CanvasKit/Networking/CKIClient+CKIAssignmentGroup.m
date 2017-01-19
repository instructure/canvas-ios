//
//  CKIClient+CKIAssignmentGroup.m
//  CanvasKit
//
//  Created by Miles Wright on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIAssignmentGroup.h"
#import "CKIAssignmentGroup.h"
#import "CKIAssignment.h"
#import "CKICourse.h"
#import "CKIRubricCriterion.h"
#import "CKIRubricCriterionRating.h"
#import "CKIEnrollment.h"

@implementation CKIClient (CKIAssignmentGroup)

- (RACSignal *)fetchAssignmentGroupsForContext:(id <CKIContext>)context gradingPeriodID:(NSString *)gradingPeriodID scopeAssignmentsToStudent:(BOOL)scopeAssignmentsToStudent
{
    return [self fetchAssignmentGroupsForContext:context includeAssignments:YES gradingPeriodID:gradingPeriodID includeSubmissions:YES scopeAssignmentsToStudent:scopeAssignmentsToStudent];
}

- (RACSignal *)fetchAssignmentGroupsForContext:(id <CKIContext>)context includeAssignments:(BOOL)includeAssignments gradingPeriodID:(NSString *)gradingPeriodID includeSubmissions:(BOOL)includeSubmissions scopeAssignmentsToStudent:(BOOL)scopeAssignmentsToStudent
{
    NSString *path = [[context path] stringByAppendingPathComponent:@"assignment_groups"];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:@"override_assignment_dates"];
    NSMutableArray *include = [NSMutableArray arrayWithObjects:@"discussion_topic", nil];
    if (includeAssignments) {
        [include addObject:@"assignments"];
    }
    if (includeSubmissions) {
        [include addObject:@"submission"];
    }
    if (gradingPeriodID) {
        [parameters setObject:gradingPeriodID forKey:@"grading_period_id"];
        [parameters setObject:@(scopeAssignmentsToStudent) forKey:@"scope_assignments_to_student"];
    }
    [parameters setObject:include forKey:@"include"];

    return [[self fetchResponseAtPath:path parameters:parameters modelClass:[CKIAssignmentGroup class] context:context] map:^id(NSArray *assignmentGroups) {
        if (!includeAssignments) {
            return assignmentGroups;
        }
        
        for (CKIAssignmentGroup *group in assignmentGroups) {
            for (CKIAssignment *assignment in group.assignments) {
                assignment.context = context;
                
                // set properties on rubricCriterionRating for easy sorting/retrieval
                [assignment.rubricCriterion enumerateObjectsUsingBlock:^(CKIRubricCriterion *criterion, NSUInteger idx, BOOL *stop) {
                    criterion.position = idx;
                }];
            }
        }
        return assignmentGroups;
    }];
}

@end
