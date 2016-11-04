
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
    
    

#import "CKModule.h"

#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter.h"
#import "CKSafeDictionary.h"

@implementation CKModule

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        CKSafeDictionary *dict = [info safeCopy];
        
        _ident = [dict[@"id"] unsignedLongLongValue];
        _name = dict[@"name"];
        _requiresSequentialProgress = [dict[@"require_sequential_progress"] boolValue];
        _prerequisiteModuleIDs = dict[@"prerequisite_module_ids"];
        
        [self setupWorkflow:dict[@"workflow_state"]];
        [self setupState:dict[@"state"]];
        [self setupDatesWithInfo:dict];
    }
    return self;
}

+ (id)moduleWithInfo:(NSDictionary *)info
{
    return [[CKModule alloc] initWithInfo:info];
}

- (void)setupDatesWithInfo:(CKSafeDictionary *)dict
{
    ISO8601DateFormatter *formatter = [ISO8601DateFormatter new];
    NSString *dateString = dict[@"unlock_at"];
    if (dateString) {
        _unlockAt = [formatter dateFromString:dateString];
    }
    dateString = dict[@"completed_at"];
    if (dateString) {
        _completedAt = [formatter dateFromString:dateString];
    }
}

- (void)setupState:(NSString *)stateString
{
    if ([stateString isEqualToString:@"locked"]) {
        _state = CKModuleStateLocked;
    }
    else if ([stateString isEqualToString:@"unlocked"]) {
        _state = CKModuleStateUnlocked;
    }
    else if ([stateString isEqualToString:@"started"]) {
        _state = CKModuleStateStarted;
    }
    else if ([stateString isEqualToString:@"completed"]) {
        _state = CKModuleStateCompleted;
    }
    else { // state might be null... which means this is a teacher
        _state = CKModuleStateNone;
    }
}

- (void)setupWorkflow:(NSString *)workflowStateString
{
    if ([workflowStateString isEqualToString:@"active"]) {
        _workflowState = CKModuleWorkflowStateActive;
    }
    else if ([workflowStateString isEqualToString:@"deleted"]) {
        _workflowState = CKModuleWorkflowStateDeleted;
    }
}

- (NSUInteger)hash
{
    return _ident;
}

@end
