//
//  CKIPoll.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIPoll.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIPoll

+ (NSString *)keyForJSONAPIContent
{
    return @"polls";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"created": @"created_at"
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

- (NSString *)path
{
    return [[self.context.path stringByAppendingPathComponent:@"polls"] stringByAppendingPathComponent:self.id];
}

@end
