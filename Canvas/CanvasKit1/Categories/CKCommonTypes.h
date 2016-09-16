//
//  CKCommonTypes.h
//  CanvasKit
//
//  Created by BJ Homer on 9/10/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CKContextTypeNone,
    CKContextTypeCourse,
    CKContextTypeGroup,
    CKContextTypeUser
} CKContextType;

CKContextType contextTypeFromString(NSString *contextString);


@interface NSObject (CKIdentity)
- (BOOL)hasSameIdentityAs:(NSObject *)object;
@end