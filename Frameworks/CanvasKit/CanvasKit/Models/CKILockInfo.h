//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

/**
 Locked but user can still view content

 @note Optional
 */
@property (nonatomic, copy) NSNumber *canView;


@end
