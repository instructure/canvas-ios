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
