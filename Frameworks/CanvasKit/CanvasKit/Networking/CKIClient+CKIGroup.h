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

#import "CKIClient.h"

@class CKIGroup;
@class CKIGroupCategory;
@class CKICourse;
@class RACSignal;

@interface CKIClient (CKIGroup)

- (RACSignal *)fetchGroup:(NSString *)groupID;

- (RACSignal *)fetchGroupsForLocalUser;

- (RACSignal *)fetchGroupsForAccount:(NSString *)accountID;

- (RACSignal *)fetchGroup:(NSString *)groupID forContext:(id<CKIContext>)context;

- (RACSignal *)fetchGroupsForContext:(id <CKIContext>)context;

- (RACSignal *)fetchGroupsForGroupCategory:(CKIGroupCategory *)category;

- (RACSignal *)fetchGroupUsersForContext:(id <CKIContext>)context;

- (RACSignal *)deleteGroup:(CKIGroup *)group;

- (RACSignal *)createGroup:(CKIGroup *)group;

- (RACSignal *)createGroup:(CKIGroup *)group category:(CKIGroupCategory *)category;

- (RACSignal *)inviteUser:(NSString *)userEmail toGroup:(CKIGroup *)group;

- (RACSignal *)createGroupMemebershipForUser:(NSString *)userID inGroup:(CKIGroup *)group;

- (RACSignal *)removeGroupMemebershipForUser:(NSString *)userID inGroup:(CKIGroup *)group;

@end
