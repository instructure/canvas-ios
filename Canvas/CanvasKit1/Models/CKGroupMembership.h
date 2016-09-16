//
//  CKGroupMembership.h
//  CanvasKit
//
//  Created by BJ Homer on 10/5/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum : unsigned char {
    CKGroupMembershipStateUnknown,
    CKGroupMembershipStateRequested,
    CKGroupMembershipStateInvited,
    CKGroupMembershipStateAccepted
} CKGroupMembershipState;

@interface CKGroupMembership : CKModelObject

- (id)initWithInfo:(NSDictionary *)info;

@property (readonly) uint64_t ident;
@property (readonly) uint64_t groupIdent;
@property (readonly) uint64_t userIdent;
@property (readonly) CKGroupMembershipState groupMembershipState;
@property (readonly) BOOL isModerator;

@end
