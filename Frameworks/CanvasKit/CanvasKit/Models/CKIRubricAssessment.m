//
//  CKIRubricAssessment.m
//  CanvasKit
//
//  Created by Brandon Pluim on 8/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
