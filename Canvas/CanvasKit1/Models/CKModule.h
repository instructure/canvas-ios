//
//  CKModule.h
//  CanvasKit
//
//  Created by Jason Larsen on 3/19/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKModelObject.h"

typedef enum CKModuleWorkflowState {
    CKModuleWorkflowStateActive,
    CKModuleWorkflowStateDeleted
} CKModuleWorkflowState;

typedef enum CKModuleState {
    CKModuleStateNone,
    CKModuleStateUnlocked,
    CKModuleStateLocked,
    CKModuleStateStarted,
    CKModuleStateCompleted
} CKModuleState;

@interface CKModule : CKModelObject

@property (readonly) uint64_t ident;
@property (readonly) CKModuleWorkflowState workflowState;
@property (readonly) NSString *name;
@property (readonly) NSDate *unlockAt;
@property (readonly) BOOL requiresSequentialProgress;
@property (readonly) NSArray *prerequisiteModuleIDs;
@property (readonly) CKModuleState state;
@property (readonly) NSDate *completedAt;

- (id)initWithInfo:(NSDictionary *)info;
+ (id)moduleWithInfo:(NSDictionary *)info;

@end
