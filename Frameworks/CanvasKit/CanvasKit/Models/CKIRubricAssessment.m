//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
