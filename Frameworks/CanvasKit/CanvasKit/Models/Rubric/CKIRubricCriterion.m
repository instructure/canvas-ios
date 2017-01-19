//
//  CKIRubricCriterion.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/29/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
        @"ratings": @"ratings"
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
