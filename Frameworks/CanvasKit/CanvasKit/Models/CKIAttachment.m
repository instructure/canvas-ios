//
//  CKIAttachment.m
//  CanvasKit
//
//  Created by derrick on 11/26/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIAttachment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIAttachment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"contentType": @"content-type",
                               @"displayName": @"display_name",
                               @"fileName": @"filename",
                               @"URL": @"url",
                               @"createdAt": @"created_at",
                               @"updatedAt": @"updated_at",
                               @"unlockAt": @"unlock_at",
                               @"hiddenForUser": @"hidden_for_user",
                               @"lockedForUser": @"locked_for_user",
                               @"thumbnailURL": @"thumbnail_url",
                               @"context": [NSNull null]
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)unlockAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}
@end
