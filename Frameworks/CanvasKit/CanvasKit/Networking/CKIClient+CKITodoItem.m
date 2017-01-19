//
//  CKIClient+CKITodoItem.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
