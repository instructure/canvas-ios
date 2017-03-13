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
