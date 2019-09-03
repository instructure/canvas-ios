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

#import "CKIClient+CKIAssignment.h"
#import "CKIAssignment.h"
#import "CKICourse.h"

static const NSString *CKIAssignmentPutParameter = @"assignment";

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

@end
