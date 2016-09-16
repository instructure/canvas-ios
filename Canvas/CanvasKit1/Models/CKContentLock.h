//
//  CKContentLock.h
//  CanvasKit
//
//  Created by Jason Larsen on 5/8/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKContentLock : NSObject
@property (readonly) NSString *explanation; // html string explanation of the reason for the lock if lockedForUser
@property (readonly) NSArray *prerequisites; // empty if only locked until date
@property (readonly) NSDate *startDate;
@property (readonly) NSDate *unlockDate; // nil if only locked due to prerequisites
@property (readonly) NSDate *lockDate;
@property (readonly) NSString *moduleName;

// The info being passed into this object is the whole
// dictionary of the JSON response for the assignment, etc.
// If the object is not locked, returns nil.
+ (id)contentLockWithInfo:(NSDictionary *)info;
- (id)initWithInfo:(NSDictionary *)info;

- (NSArray *)prerequisiteNames;

@end
