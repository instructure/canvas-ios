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
