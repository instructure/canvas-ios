//
//  CKIRubricCriterionRating.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/29/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIRubricCriterionRating.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIRubricCriterionRating

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"points": @"points",
                               @"comments": @"comments",
                               @"ratingDescription": @"description"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

@end
