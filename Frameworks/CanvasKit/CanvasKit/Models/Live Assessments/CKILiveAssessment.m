//
//  CKILiveAssessment.m
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKILiveAssessment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKILiveAssessment

+ (NSString *)keyForJSONAPIContent
{
    return @"assessments";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *pathsByProperty = @{
        @"context": [NSNull null],
        @"outcomeID": @"links.outcome",
    };
    
    return [[super JSONKeyPathsByPropertyKey] dictionaryByAddingObjectsFromDictionary:pathsByProperty];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(id value) {
        return value;
    }];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"live_assessments"] stringByAppendingPathComponent:self.id];
}
@end
