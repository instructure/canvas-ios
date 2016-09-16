//
//  CKCommonTypes.m
//  CanvasKit
//
//  Created by BJ Homer on 10/2/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#include "CKCommonTypes.h"

CKContextType contextTypeFromString(NSString *contextString) {
    contextString = [contextString lowercaseString];
    if ([@"course" isEqualToString:contextString]) {
        return CKContextTypeCourse;
    }
    else if ([@"group" isEqualToString:contextString]) {
        return CKContextTypeGroup;
    }
    else if ([@"user" isEqualToString:contextString]) {
        return CKContextTypeUser;
    }
    else {
        return CKContextTypeNone;
    }
}



// This category isn't actually implemented anywhere; it's just declared here
// so that the compiler will know how to call -ident
@interface NSObject (CKIdentity_Internal)
- (uint64_t)ident;
@end

@implementation NSObject (CKIdentity)

- (BOOL)hasSameIdentityAs:(id)object {

    if ([self respondsToSelector:@selector(ident)] && [object respondsToSelector:@selector(ident)]) {
        return [self ident] == [object ident];
    }
    else {
        return [self isEqual:object];
    }
}

@end