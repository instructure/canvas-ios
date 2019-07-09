//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import <Foundation/Foundation.h>
#import "CKCommonTypes.h"
#import "CKModelObject.h"


typedef enum : unsigned char {
    CKGroupJoinLevelInvalid,
    CKGroupJoinLevelParentContextAutoJoin,
    CKGroupJoinLevelParentContextRequestToJoin,
    CKGroupJoinLevelInvitationOnly
} CKGroupJoinLevel;

typedef enum : unsigned char {
    CKGroupRoleNone,
    CKGroupRoleCommunities,
    CKGroupRoleStudentOrganized,
    CKGroupRoleImported,
} CKGroupRole;




@interface CKGroup : CKModelObject

- (id)initWithInfo:(NSDictionary *)info;

@property (readonly) uint64_t ident;
@property (readonly) NSString *name;
@property (readonly) NSString *groupDescription;
@property (readonly) BOOL isPublic;
@property (readonly) BOOL followedByUser;
@property (readonly) CKGroupJoinLevel joinLevel;
@property (readonly) NSUInteger memberCount;
@property (readonly) NSURL *avatarURL;
@property (readonly) CKContextType contextType;
@property (readonly) uint64_t contextIdent;
@property (readonly) CKGroupRole groupRole;
@property (readonly) uint64_t groupCategoryIdent;


@end
