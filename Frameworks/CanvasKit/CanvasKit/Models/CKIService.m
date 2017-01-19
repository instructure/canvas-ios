//
//  CKIService.m
//  CanvasKit
//
//  Created by Miles Wright on 10/14/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIService.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIService

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"partnerID": @"partner_id",
                               @"resourceDomain": @"resource_domain",
                               @"rtmp": @"rtmp_domain"
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)domainJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)resourceDomainJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)rtmpJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
