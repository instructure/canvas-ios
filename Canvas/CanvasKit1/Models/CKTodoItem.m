//
//  CKTodoItem.m
//  CanvasKit
//
//  Created by Mark Suman on 10/3/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKTodoItem.h"
#import "CKAssignment.h"
#import "NSDictionary+CKAdditions.h"
#import "CKCourse.h"

@implementation CKTodoItem

@synthesize api, type, ignoreURL, ignorePermanentlyURL, assignment, contextType, courseId, groupId, course, actionPath, needsGradingCount;

- (id)initWithInfo:(NSDictionary *)info api:(CKCanvasAPI *)theAPI
{
    self = [super init];
    if (self) {
        type = [CKTodoItem typeForString:[info objectForKeyCheckingNull:@"type"]];
        NSString *ignoreURLString = [info objectForKeyCheckingNull:@"ignore"];
        if (ignoreURLString) {
            ignoreURL = [NSURL URLWithString:ignoreURLString];
        }
        NSString *ignorePermantentlyURLString = [info objectForKeyCheckingNull:@"ignore_permanently"];
        if (ignorePermantentlyURLString) {
            ignorePermanentlyURL = [NSURL URLWithString:ignorePermantentlyURLString];
        }
        assignment = [[CKAssignment alloc] initWithInfo:[info objectForKeyCheckingNull:@"assignment"]];
        contextType = [CKTodoItem contextTypeForString:[info objectForKeyCheckingNull:@"context_type"]];
        courseId = [info[@"course_id"] unsignedLongLongValue];
        
        if (type == CKTodoItemTypeGrading) {
            needsGradingCount = [info[@"needs_grading_count"] intValue];
        }
    }
    
    return self;
}


- (NSString *)title
{
    if (CKTodoItemTypeGrading == type) {
        return [NSString stringWithFormat:NSLocalizedString(@"Grade %@", @"Tells the user to grade an assignment called something like 'Biology Assignment'"),assignment.name];
    }
    else if (CKTodoItemTypeSubmitting == type) {
        return [NSString stringWithFormat:NSLocalizedString(@"Turn in %@", @"Tells the user to turn in an assignment called something like 'Biology Assignment'"),assignment.name];
    }
    else {
        return @"";
    }
}

- (NSDate *)dueDate
{
    return assignment.dueDate;
}

- (void)populateActionPath
{
    if (self.actionPath || !self.course) {
        return;
    }
    
    if (self.assignment.ident > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(self.assignment.ident)];
    }
}

#pragma mark - Detemining object type

+ (CKTodoItemType)typeForString:(NSString *)typeString
{
    if ([@"grading" isEqualToString:typeString]) {
        return CKTodoItemTypeGrading;
    }
    else if ([@"submitting" isEqualToString:typeString]) {
        return CKTodoItemTypeSubmitting;
    }
    else {
        return CKTodoItemTypeDefault;
    }
}

+ (CKTodoItemContextType)contextTypeForString:(NSString *)contextTypeString
{
    if ([@"Course" isEqualToString:contextTypeString]) {
        return CKTodoItemContextTypeCourse;
    }
    // TODO: add group support here when the API supports it
    else {
        return CKTodoItemContextTypeNone;
    }
}

- (NSUInteger)hash {
    return self.ignoreURL.hash;
}

@end
