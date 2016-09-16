//
//  CKSafeDictionary.m
//  CanvasKit
//
//  Created by Jason Larsen on 3/19/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKSafeDictionary.h"
#import "NSDictionary+CKAdditions.h"

@interface CKSafeDictionary ()
@property NSDictionary *dictionary;
@end

@implementation CKSafeDictionary

- (id)objectForKeyedSubscript:(id)key
{
    return [self.dictionary objectForKeyCheckingNull:key];
}

- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (self) {
        self.dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

- (NSUInteger)count
{
    return self.dictionary.count;
}

- (id)objectForKey:(id)key
{
    return [self.dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.dictionary keyEnumerator];
}



@end
