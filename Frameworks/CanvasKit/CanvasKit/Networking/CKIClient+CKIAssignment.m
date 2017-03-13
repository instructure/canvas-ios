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
