//
//  CKILockableModel.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKILockableModel.h"
#import "CKILockInfo.h"

@implementation CKILockableModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPaths = [@{
        @"lockedForUser": @"locked_for_user",
        @"lockExplanation": @"lock_explanation",
        @"lockInfo": @"lock_info"
    } mutableCopy];
    [keyPaths addEntriesFromDictionary:[super JSONKeyPathsByPropertyKey]];
    return keyPaths;
}

+ (NSValueTransformer *)lockInfoJSONTransformer
{
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKILockInfo class]];
}

@end
