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
    self.useRange = [info[@"criterion_use_range"] boolValue];
    
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
