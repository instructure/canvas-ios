//
//  CKTodoItem.h
//  CanvasKit
//
//  Created by Mark Suman on 10/3/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKTodoItemTypeDefault,
    CKTodoItemTypeGrading,
    CKTodoItemTypeSubmitting
} CKTodoItemType;

typedef enum {
    CKTodoItemContextTypeNone,
    CKTodoItemContextTypeCourse,
    CKTodoItemContextTypeGroup
} CKTodoItemContextType;

@class CKCanvasAPI, CKAssignment,CKCourse;

@interface CKTodoItem : CKModelObject

@property (nonatomic, weak) CKCanvasAPI *api;
@property (nonatomic, assign) CKTodoItemType type;
@property (nonatomic, strong) NSURL *ignoreURL;
@property (nonatomic, strong) NSURL *ignorePermanentlyURL;
@property (nonatomic, strong) CKAssignment *assignment;

// Derived information
@property (readonly, strong) NSString *title;
@property (readonly, strong) NSDate *dueDate;

// Context information
@property (nonatomic, assign) CKTodoItemContextType contextType;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, assign) uint64_t groupId;
@property (nonatomic, weak) CKCourse *course;
@property (nonatomic, strong) NSArray *actionPath;

// TypeGrading
@property (nonatomic, assign) int needsGradingCount;

- (id)initWithInfo:(NSDictionary *)info api:(CKCanvasAPI *)theAPI;
- (void)populateActionPath;

+ (CKTodoItemType)typeForString:(NSString *)typeString;
+ (CKTodoItemContextType)contextTypeForString:(NSString *)contextTypeString;

@end
