//
//  NSDictionary+DictionaryByAddingObjectsFromDictionary.m
//  CanvasKit
//
//  Created by Jason Larsen on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation NSDictionary (DictionaryByAddingObjectsFromDictionary)

- (NSDictionary *)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *mutableCopy = [self mutableCopy];
    [mutableCopy addEntriesFromDictionary:dictionary];
    return [mutableCopy copy];
}

@end
