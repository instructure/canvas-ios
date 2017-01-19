//
//  CKILockableModel.h
//  CanvasKit
//
//  Created by Jason Larsen on 8/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKILockInfo;

/**
 A base class adding functionality for models that require locking.
 */
@interface CKILockableModel : CKIModel

/**
 Model is in a locked state for this user.
 */
@property (nonatomic) BOOL lockedForUser;

/**
 An explanation of why this is locked for the user.
 Present when lockedForUser is true.
 */
@property (nonatomic, copy) NSString *lockExplanation;

/**
 Information for the user about the lock. Present when 
 lockedForUser is true.
 */
@property (nonatomic, strong) CKILockInfo *lockInfo;
@end
