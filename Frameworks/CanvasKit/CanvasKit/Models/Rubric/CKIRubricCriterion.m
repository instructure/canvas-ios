//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKIRubricCriterion.h"
#import "CKIRubricCriterionRating.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIRubricCriterion

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *keyPaths = @{
        @"points": @"points",
        @"criterionDescription": @"description",
        @"longDescription": @"long_description",
        @"ratings": @"ratings",
        @"useRange": @"criterion_use_range"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)ratingsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIRubricCriterionRating class]];
}

// the id value in the JSON for rating objects is already a string,
// so override the default number -> string transformer.
+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

#pragma mark - Other Methods

- (CKIRubricCriterionRating *)selectedRating
{
    CKIRubricCriterionRating *rating;
    
    NSUInteger index = [self.ratings indexOfObjectPassingTest:^BOOL(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
        return rating.points == self.points;
    }];
    
    if (index != NSNotFound) {
        rating = self.ratings[index];
    }
    
    return rating;
}

@end
