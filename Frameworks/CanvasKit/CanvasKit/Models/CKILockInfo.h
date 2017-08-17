//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
