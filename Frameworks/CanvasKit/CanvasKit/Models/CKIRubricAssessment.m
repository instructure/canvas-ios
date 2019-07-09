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

#import "CKIRubricAssessment.h"
#import "CKIRubricCriterionRating.h"

@implementation CKIRubricAssessment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"ratings": @"ratings",
                               };
    return keyPaths;
}

+ (NSValueTransformer *)ratingsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIRubricCriterionRating class]];
}

- (NSDictionary *)parametersDictionary {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self.ratings enumerateObjectsUsingBlock:^(CKIRubricCriterionRating *rating, NSUInteger idx, BOOL *stop) {
        
        NSMutableDictionary *ratingInfo = [NSMutableDictionary new];
        ratingInfo[@"points"] = [NSString stringWithFormat:@"%g", rating.points];
        
        NSString *comments = rating.comments ? rating.comments : @"";
        ratingInfo[@"comments"] = comments;
        [params setObject:ratingInfo forKey:rating.id];
    }];
    
    return params;
}

@end
