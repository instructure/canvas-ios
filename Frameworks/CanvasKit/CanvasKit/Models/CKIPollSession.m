//
//  CKIPollSession.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIPollSession.h"
#import "CKIPollSubmission.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIPollSession

+ (NSString *)keyForJSONAPIContent
{
    return @"poll_sessions";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"submissions": @"poll_submissions",
                               @"hasSubmitted":@"has_submitted",
                               @"courseID": @"course_id",
                               @"sectionID": @"course_section_id",
                               @"isPublished": @"is_published",
                               @"hasPublicResults": @"has_public_results",
                               @"pollID": @"poll_id",
                               @"created": @"created_at",
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)idJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)submissionsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CKIPollSubmission class]];
}

+ (NSValueTransformer *)createdJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)courseIDJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)pollIDJSONTransformer
{
    return nil;
}

+ (NSValueTransformer *)sectionIDJSONTransformer
{
    return nil;
}

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"poll_sessions"] stringByAppendingPathComponent:self.id];
}

@end
