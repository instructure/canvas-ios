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
    
    

#import "CKRubric.h"
#import "CKAssignment.h"
#import "CKRubricCriterion.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKRubric

@synthesize criteria, freeFormComments, assignment;

- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment
{
    self = [super init];
    if (self) {
        self.assignment = anAssignment;
        criteria = [[NSMutableArray alloc] init];
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    for (NSDictionary *criterionInfo in info[@"rubric"]) {
        NSString *criterionIdent = criterionInfo[@"id"];
        BOOL foundExisting = NO;
        for (CKRubricCriterion *existingCriterion in self.criteria) {
            if ([criterionIdent isEqualToString:existingCriterion.identifier]) {
                [existingCriterion updateWithInfo:criterionInfo];
                foundExisting = YES;
                break;
            }
        }
        
        if (!foundExisting) {
            CKRubricCriterion *criterion = [[CKRubricCriterion alloc] initWithInfo:criterionInfo andRubric:self];
            [self.criteria addObject:criterion];
        }
    }
    
    self.freeFormComments = [[info objectForKeyCheckingNull:@"free_form_criterion_comments"] boolValue];
}

- (NSUInteger)hash {
    return self.criteria.hash + freeFormComments;
}


@end
