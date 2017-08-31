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
    
    

#import "CKRubricCriterionRating.h"
#import "CKRubricCriterion.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKRubricCriterionRating

- (id)initWithInfo:(NSDictionary *)info andRubricCriterion:(CKRubricCriterion *)aCriterion
{
    self = [super init];
    if (self) {
        self.identifier = info[@"id"];
        self.criterion = aCriterion;
        self.criterionId = aCriterion.identifier;
        [self updateWithInfo:info];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info andCriterionIdent:(NSString *)criterionIdent
{
    self = [super init];
    if (self) {
        self.identifier = criterionIdent;
        if (!self.criterionId) {
            self.criterionId = criterionIdent;
        }
        [self updateWithInfo:info];
    }
    return self;
}

- (id)initWithRubricCriterion:(CKRubricCriterion *)aCriterion
{
    self = [super init];
    if (self) {
        self.criterion = aCriterion;
        self.criterionId = aCriterion.identifier;
    }
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.ratingDescription = [info objectForKeyCheckingNull:@"description"];
    self.points = [info[@"points"] doubleValue];
    self.comments = [info objectForKeyCheckingNull:@"comments"];
    if (!self.comments) {
        self.comments = @"";
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    CKRubricCriterionRating *ratingCopy = [[CKRubricCriterionRating allocWithZone:zone] initWithRubricCriterion:self.criterion];
    ratingCopy.criterionId = [self.criterionId copy];
    ratingCopy.identifier = [self.identifier copy];
    ratingCopy.ratingDescription = [self.ratingDescription copy];
    ratingCopy.points = self.points;
    ratingCopy.comments = [self.comments copy];
    return ratingCopy;
}

- (NSString*)description
{
    NSString *description = [super description];
    description = [description stringByAppendingFormat:NSLocalizedString(@" Rating for %@, Score: %g",@"Description for rubric criterion rating object"), self.criterionId, self.points];
    return description;
}

- (NSUInteger)hash {
    return [self.identifier hash];
}


@end
