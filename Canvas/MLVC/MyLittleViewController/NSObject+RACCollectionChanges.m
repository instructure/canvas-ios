//
//  NSObject+RACCollectionChanges.m
//  MyLittleViewController
//
//  Created by derrick on 10/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "NSObject+RACCollectionChanges.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation NSObject (RACCollectionChanges)
- (RACSignal *)rac_filteredIndexSetsForChangeType:(NSKeyValueChange)type forCollectionForKeyPath:(NSString *)collectionKeyPath {
    return [[[[self rac_valuesAndChangesForKeyPath:collectionKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:nil] map:^id(RACTuple *value) {
        NSAssert([value.second isKindOfClass:[NSDictionary class]], @"Expecting a dictionary of changes");
        return value.second;
    }] filter:^BOOL(NSDictionary *value) {
        return [value[NSKeyValueChangeKindKey] unsignedIntegerValue] == type;
    }] map:^id(id value) {
        return value[NSKeyValueChangeIndexesKey];
    }];
}
@end
