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

#import "CKIClient+CKITodoItem.h"
#import "CKITodoItem.h"
#import "CKICourse.h"
#import "CKIAssignment.h"
@import ReactiveObjC;

@implementation CKIClient (CKITodoItem)

- (RACSignal *)fetchTodoItemsForCourse:(CKICourse *)course
{
    NSString *path = [[course path] stringByAppendingPathComponent:@"todo"];
    return [[self fetchResponseAtPath:path parameters:nil modelClass:[CKITodoItem class] context:course] map:^(NSArray  *value) {
        for (CKITodoItem *item in value) {
            item.assignment.context = course;
        }
        return value;
    }];
    
}

- (RACSignal *)fetchTodoItemsForCurrentUser
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users/self/todo"];
    return [[self fetchResponseAtPath:path parameters:nil modelClass:[CKITodoItem class] context:nil] map:^(NSArray  *value) {
        for (CKITodoItem *item in value) {
            item.assignment.context = [CKICourse modelWithID:item.assignment.courseID];
        }
        return value;
    }];
}

@end
