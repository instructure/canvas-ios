//
//  NSArray+CKAdditions.m
//  CanvasKit
//
//  Created by BJ Homer on 11/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "NSArray+CKAdditions.h"
#import "CKCommonTypes.h"
#import "CKModelObject.h"

@implementation NSArray (CKAdditions)

- (id)in_firstObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test {
    NSUInteger index = [self indexOfObjectPassingTest:test];
    
    if (index != NSNotFound) {
        return self[index];
    }
    else {
        return nil;
    }
}

- (NSUInteger)indexOfObjectWithSameIdentityAsObject:(CKModelObject *)object {
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(CKModelObject *obj, NSUInteger idx, BOOL *stop) {
        return [object hasSameIdentityAs:obj];
    }];
    return index;
}


@end
