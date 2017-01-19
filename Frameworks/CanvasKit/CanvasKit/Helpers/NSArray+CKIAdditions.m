//
//  NSArray+CKIAdditions.m
//  CanvasKit
//
//  Created by Ben Kraus on 12/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "NSArray+CKIAdditions.h"

@implementation NSArray (CKIAdditions)

- (NSArray *)arrayByMappingValues:(NSDictionary *)valueMapping
{
    NSMutableArray *array = [self mutableCopy];
    for (NSUInteger i = 0; i < array.count; ++i) {
        id item = array[i];
        id newValue = [valueMapping objectForKey:item];
        if (newValue != nil) {
            array[i] = newValue;
        }
    }
    return [array copy];
}

@end
