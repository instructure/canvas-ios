//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
