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
    
    

#import "CKGroup.h"


/*
 
 {
 // The ID of the group.
 id: 17,
 
 // The display name of the group.
 name: "Math Group 1",
 
 // A description of the group. This is plain text.
 description: null,
 
 // Whether or not the group is public.  Currently only community groups
 // can be made public.  Also, once a group has been set to public, it
 // cannot be changed back to private.
 is_public: false,
 
 // Whether or not the current user is following this group.
 followed_by_user: false,
 
 // How people are allowed to join the group.  For all groups except for
 // community groups, the user must share the group's parent course or
 // account.  For student organized or community groups, where a user
 // can be a member of as many or few as they want, the applicable
 // levels are "parent_context_auto_join", "parent_context_request", and
 // "invitation_only".  For class groups, where students are divided up
 // and should only be part of one group of the category, this value
 // will always be "invitation_only", and is not relevant.
 //
 // * If "parent_context_auto_join", anyone can join and will be
 //   automatically accepted.
 // * If "parent_context_request", anyone  can request to join, which
 //   must be approved by a group moderator.
 // * If "invitation_only", only those how have received an
 //   invitation my join the group, by accepting that invitation.
 join_level: "invitation_only",
 
 // The number of members currently in the group
 members_count: 0,
 
 // The url of the group's avatar
 avatar_url: "https://<canvas>/files/avatar_image.png",
 
 // The course or account that the group belongs to. The pattern here is
 // that whatever the context_type is, there will be an _id field named
 // after that type. So if instead context_type was "account", the
 // course_id field would be replaced by an account_id field.
 context_type: "Course",
 course_id: 3,
 
 // Certain types of groups have special role designations. Currently,
 // these include: "communities", "student_organized", and "imported".
 // Regular course/account groups have a role of null.
 role: null,
 
 // The ID of the group's category.
 group_category_id: 4,
 }
 
 */

#import "NSDictionary+CKAdditions.h"


@implementation CKGroup

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];
        _name = [info objectForKeyCheckingNull:@"name"];
        _groupDescription = [info objectForKeyCheckingNull:@"description"];
        _isPublic = [[info objectForKeyCheckingNull:@"is_public"] boolValue];
        _followedByUser = [[info objectForKeyCheckingNull:@"followed_by_user"] boolValue];
        _joinLevel = joinLevelFromString([info objectForKeyCheckingNull:@"join_level"]);
        _memberCount = [[info objectForKeyCheckingNull:@"members_count"] unsignedIntegerValue];
        _avatarURL = [NSURL URLWithString:[info objectForKeyCheckingNull:@"avatar_url"]];
        
        NSString *contextTypeStr = [info objectForKeyCheckingNull:@"context_type"];
        _contextType = contextTypeFromString(contextTypeStr);
        NSString *contextIdentKey = [NSString stringWithFormat:@"%@_id", [contextTypeStr lowercaseString]];
        _contextIdent = [[info objectForKeyCheckingNull:contextIdentKey] unsignedLongLongValue];
        
        _groupRole = groupRoleFromString([info objectForKeyCheckingNull:@"role"]);
        _groupCategoryIdent = [[info objectForKeyCheckingNull:@"group_category_id"] unsignedLongLongValue];
    }
    return self;
}

static CKGroupJoinLevel joinLevelFromString(NSString *string) {
    if ([string isEqualToString:@"parent_context_auto_join"]) {
        return CKGroupJoinLevelParentContextAutoJoin;
    }
    else if ([string isEqualToString:@"parent_context_request"]) {
        return CKGroupJoinLevelParentContextRequestToJoin;
    }
    else if ([string isEqualToString:@"invitation_only"]) {
        return CKGroupJoinLevelInvitationOnly;
    }
    else {
        NSLog(@"Warning: Unexpected join level returned from API: %@", string);
        return CKGroupJoinLevelInvalid;
    }
}

static CKGroupRole groupRoleFromString(NSString *string) {
    if ([string isEqualToString:@"communities"]) {
        return CKGroupRoleCommunities;
    }
    else if ([string isEqualToString:@"student_organized"]) {
        return CKGroupRoleStudentOrganized;
    }
    else if ([string isEqualToString:@"imported"]) {
        return CKGroupRoleImported;
    }
    else if (string != nil) {
        NSLog(@"Unexpected group role string: %@", string);
    }
    return CKGroupRoleNone;
}

- (NSUInteger)hash {
    return (NSUInteger)self.ident;
}

@end
