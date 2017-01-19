//
//  CKIClient+CKIAssignmentGroup.h
//  CanvasKit
//
//  Created by Miles Wright on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class RACSignal;

@interface CKIClient (CKIAssignmentGroup)

/**
 Fetches the assignment groups for the given context.

 @param gradingPeriodID the id of the desired grading period. Pass nil for all.
 */
- (RACSignal *)fetchAssignmentGroupsForContext:(id <CKIContext>)context gradingPeriodID:(NSString *)gradingPeriodID scopeAssignmentsToStudent:(BOOL)scopeAssignmentsToStudent;

- (RACSignal *)fetchAssignmentGroupsForContext:(id <CKIContext>)context includeAssignments:(BOOL)includeAssignments gradingPeriodID:(NSString *)gradingPeriodID includeSubmissions:(BOOL)includeSubmissions scopeAssignmentsToStudent:(BOOL)scopeAssignmentsToStudent;

@end
