//
//  NSArray+CKAdditions.h
//  CanvasKit
//
//  Created by BJ Homer on 11/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKModelObject;

@interface NSArray (CKAdditions)
- (id)in_firstObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test;
- (NSUInteger)indexOfObjectWithSameIdentityAsObject:(CKModelObject *)object;
@end
