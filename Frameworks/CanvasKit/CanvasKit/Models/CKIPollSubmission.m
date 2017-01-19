//
//  CKIPollSubmission.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIPollSubmission.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIPollSubmission

+ (NSString *)keyForJSONAPIContent
{
    return @"poll_submissions";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"pollChoiceID": @"poll_choice_id",
                               @"created": @"created_at",
                               @"userID": @"user_id",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)createdJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)userIDJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)pollChoiceIDJSONTransformer
{
    return nil;
}

- (NSString *)path 
{
    return [[self.context.path stringByAppendingPathComponent:@"poll_submissions"] stringByAppendingPathComponent:self.id];
}

@end
