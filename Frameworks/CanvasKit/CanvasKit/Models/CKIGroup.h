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

extern NSString * const CKIGroupJoinLevelParentContextAutoJoin;
extern NSString * const CKIGroupJoinLevelParentContextRequest;
extern NSString * const CKIGroupJoinLevelInvitationOnly;

@interface CKIGroup : CKIModel

/**
 Plain text name of the group
 */
@property (nonatomic, copy) NSString *name;

/**
 Plain text description of the group.
 */
@property (nonatomic, copy) NSString *groupDescription;

/**
 The group is public. Only Community groups can be public.
 @warning Once made public, a group cannot be made private.
 */
@property (nonatomic) BOOL isPublic;

/**
 The current user is following this group.
 */
@property (nonatomic) BOOL followedByUser;

/**
 How people are allowed to join the group. For all groups
 except community groups, the user must share the group's
 parent course account.  For student organized or community
 groups, where a can be a member of as many or few as they
 want, the levels are "parent_context_auto_join", 
 "parent_context_request", "invitation_only".  For class
 groups, where students are divided and should only be part
 of one group of the category, this will always be 
 "invitation_only", and is not relevant.
 
 @see CKIGroupJoinLevelParentContextAutoJoin
 @see CKIGroupJoinLevelParentContextRequest
 @see CKIGroupJoinLevelInvitationOnly
 */
@property (nonatomic, copy) NSString *joinLevel;

/**
 The number of members in the group.
 */
@property (nonatomic) NSUInteger membersCount;

/**
 The URL of the group's avatar.
 */
@property (nonatomic, strong) NSURL *avatarURL;

/**
 The ID of the course this group belongs to.
 
 @note group can also belong to account, but this is not yet supported. TODO.
 */
@property (nonatomic, copy) NSString *courseID;

@end
