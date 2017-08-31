//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    return (NSUInteger)ident;
}

@end
