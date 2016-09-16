//
//  CKAssignmentGroup.m
//  CanvasKit
//
//  Created by Zach Wily on 7/8/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKAssignmentGroup.h"
#import "CKAssignment.h"

@implementation CKAssignmentGroup

@synthesize course, assignments, ident, name, position;

- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)aCourse
{
    self = [super init];
    if (self) {
        self.course = aCourse;
        self.assignments = [NSMutableArray array];
        [self updateWithInfo:info];
    }
    
    return self;
}


- (void)updateWithInfo:(NSDictionary *)info
{
    self.ident = [info[@"id"] unsignedLongLongValue];
    self.name = info[@"name"];
    self.position = [info[@"position"] intValue];
    [info[@"assignments"] enumerateObjectsUsingBlock:^(NSDictionary *assignmentInfo, NSUInteger idx, BOOL *stop) {
        [self addToGroup:[[CKAssignment alloc] initWithInfo:assignmentInfo]];
    }];
}

- (BOOL)addToGroup:(CKAssignment *)assignment
{
    BOOL exists = NO;
    for (CKAssignment *assignmentInGroup in self.assignments) {
        if (assignment.ident == assignmentInGroup.ident) {
            [self.assignments removeObject:assignmentInGroup];
            exists = YES;
            break;
        }
    }
    [self.assignments addObject:assignment];
    
    // Yeah, sorting every time we had kills our big-O, but we're not adding a lot here so it shouldn't matter.
    [self.assignments sortUsingSelector:@selector(comparePosition:)];
    return exists;
}

- (NSComparisonResult)comparePosition:(CKAssignmentGroup *)other
{
    if (self.position < other.position) {
        return NSOrderedAscending;
    }
    else if (self.position > other.position) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[ @"assignments" ];
}

- (NSUInteger)hash {
    return ident;
}

@end
