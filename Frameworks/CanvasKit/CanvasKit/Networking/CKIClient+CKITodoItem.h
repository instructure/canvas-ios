//
//  CKIClient+CKITodoItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class RACSignal;

@interface CKIClient (CKITodoItem)

- (RACSignal *)fetchTodoItemsForCourse:(CKICourse *)course;

- (RACSignal *)fetchTodoItemsForCurrentUser;

@end
