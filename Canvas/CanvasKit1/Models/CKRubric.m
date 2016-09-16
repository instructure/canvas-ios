//
//  CKRubric.m
//  CanvasKit
//
//  Created by Zach Wily on 7/9/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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
