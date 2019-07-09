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
