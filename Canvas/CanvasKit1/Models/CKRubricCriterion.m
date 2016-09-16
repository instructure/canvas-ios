//
//  CKRubricCriterion.m
//  CanvasKit
//
//  Created by Mark Suman on 11/29/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKRubricCriterion.h"
#import "CKRubricCriterionRating.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKRubricCriterion

@synthesize rubric, identifier, criterionDescription, longDescription, points, ratings;

- (id)initWithInfo:(NSDictionary *)info andRubric:(CKRubric *)aRubric
{
    self = [super init];
    if (self) {
        self.rubric = aRubric;
        self.identifier = info[@"id"];
        ratings = [[NSMutableArray alloc] init];
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.criterionDescription = [info objectForKeyCheckingNull:@"description"];
    self.longDescription = [info objectForKeyCheckingNull:@"long_description"];
    self.points = [info[@"points"] doubleValue];
    
    for (NSDictionary *ratingInfo in info[@"ratings"]) {
        NSString *ratingIdent = ratingInfo[@"id"];
        BOOL foundExisting = NO;
        for (CKRubricCriterionRating *existingRating in self.ratings) {
            if ([ratingIdent isEqualToString:existingRating.identifier]) {
                [existingRating updateWithInfo:ratingInfo];
                foundExisting = YES;
                break;
            }
        }
        
        if (!foundExisting) {
            CKRubricCriterionRating *rating = [[CKRubricCriterionRating alloc] initWithInfo:ratingInfo andRubricCriterion:self];
            [self.ratings addObject:rating];
        }
    }
}

- (NSUInteger)hash {
    return [self.identifier hash];
}


@end
