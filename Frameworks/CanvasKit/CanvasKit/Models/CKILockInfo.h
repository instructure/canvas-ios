//
//  CKILockInfo.h
//  CanvasKit
//
//  Created by Jason Larsen on 8/28/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CKILockInfo : MTLModel <MTLJSONSerializing>

/**
 Asset string for the object causing the lock.
 */
@property (nonatomic, copy) NSString *assetString;

/**
 Date when object unlocks.
 
 @note Optional
 */
@property (nonatomic, strong) NSDate *unlockAt;

/**
 Date when module starts.
 
 @note Optional
 */
@property (nonatomic, strong) NSDate *startAt;


/**
 Date when module ends.
 
 @note Optional
 */
@property (nonatomic, strong) NSDate *endAt;

/**
 The ID of the module causing the lock.
 
 @note Only available if a module is causing the lock.
 */
@property (nonatomic, copy) NSString *moduleID;

/**
 The name of the module causing the object lock.
 
 @note Only available if a module is causing the lock.
 */
@property (nonatomic, copy) NSString *moduleName;

/**
 The ID of the course the module belongs to.
 
 @note Only available if a module is causing the lock.
 */
@property (nonatomic, copy) NSString *moduleCourseID;

/**
 Prerequisites for unlocking the module causing the lock,
 if any.
 
 @note Only available if a module is causing the lock. Also,
 the lock may be caused by a lockAt date—there may be no
 prerequisites even if the module is locked.
 */
@property (nonatomic, copy) NSString *modulePrerequisites;


@end
