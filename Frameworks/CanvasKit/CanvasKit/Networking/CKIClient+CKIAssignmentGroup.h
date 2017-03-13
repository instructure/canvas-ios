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
