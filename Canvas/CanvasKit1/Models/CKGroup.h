//
//  CKGroup.h
//  CanvasKit
//
//  Created by BJ Homer on 10/2/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
