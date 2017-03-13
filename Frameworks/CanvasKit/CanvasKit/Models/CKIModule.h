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

#import "CKIModel.h"

/**
 The module is locked due to module dependencies
 and/or until a further date.
 */
extern NSString * const CKIModuleStateLocked;
/**
 The module is in an unlocked, but not yet started state.
 */
extern NSString * const CKIModuleStateUnlocked;
/**
 The module is unlocked and some progress has been made.
 */
extern NSString * const CKIModuleStateStarted;
/**
 All requirements in the module have been completed.
 */
extern NSString * const CKIModuleStateCompleted;

/**
 The current workflow of the module is active.
 */
extern NSString * const CKIModuleWorkflowStateActive;
/**
  The current workflow of the module is deleted.
 */
extern NSString * const CKIModuleWorkflowStateDeleted;

@interface CKIModule : CKIModel

/**
 The state of this Module for the calling user: locked,
 unlocked, started, or completed.
 
 @see
 */
@property (nonatomic, copy) NSString *state;

/**
 The state of the module: active or deleted.
 
 @see CKIModuleWorkflowStateActive, CKIModuleWorkflowStateDeleted
 */
@property (nonatomic, copy) NSString *workflowState;

/**
 The name of the module.
 */
@property (nonatomic, copy) NSString *name;

/**
 The date at which the module unlocks, if it locked till a certain
 date.
 */
@property (nonatomic, strong) NSDate *unlockAt;

/**
 Items in the module must be unlocked in sequential order.
 */
@property (nonatomic) BOOL requireSequentialProgress;

/**
 The number of module items in the module.
 */
@property (nonatomic) NSUInteger itemsCount;

/**
 The module's items. An array of CKIModuleItem.
 
 @see CKIModuleItem
 @warning The count of this array may not match match itemsCount.
 If this is the case, you have not loaded all the items yet.
 */
@property (nonatomic, copy) NSArray *items;

/**
 The API URL of the module items for the module.
 */
@property (nonatomic, strong) NSURL *itemsAPIURL;

/**
 The date the module was completed on, if completed.
 */
@property (nonatomic, strong) NSDate *completedAt;

/**
 IDs of Modules that must be completed before this one is unlocked
 */
@property (nonatomic, copy) NSArray *prerequisiteModuleIDs;

@end
