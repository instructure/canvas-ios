//
//  CKILiveAssessmentResult.m
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKILiveAssessmentResult.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "CKILiveAssessment.h"

@implementation CKILiveAssessmentResult

+ (NSString *)keyForJSONAPIContent
{
    return @"results";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
        @"assessedAt": @"assessed_at",
        @"assessedUserID": @"links.user",
        @"assessorUserID": @"links.assessor",
        @"context": [NSNull null],
    };
    
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"results"] stringByAppendingPathComponent:self.id];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(id value) {
        return value;
    }];
}

+ (NSValueTransformer *)assessedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

@end
