//
//  NSDictionary+CKAdditions.m
//  Speed Grader
//
//  Created by Zach Wily on 7/9/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "NSDictionary+CKAdditions.h"
#import "CKSafeDictionary.h"


@implementation NSDictionary (CKAdditions)

+ (id)safeDictionaryWithDictionary:(NSDictionary *)dictionary
{
    return [CKSafeDictionary dictionaryWithDictionary:dictionary];
}

- (id)safeCopy
{
    return [CKSafeDictionary dictionaryWithDictionary:self];
}

- (id)objectForKeyCheckingNull:(id)aKey
{
    id obj = self[aKey];
    if (obj == [NSNull null]) {
        return nil;
    }
    return obj;
}

@end
