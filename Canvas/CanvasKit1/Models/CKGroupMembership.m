//
//  CKGroupMembership.m
//  CanvasKit
//
//  Created by BJ Homer on 10/5/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKGroupMembership.h"
#import "NSDictionary+CKAdditions.h"

/*
 {
 // The id of the membership object
 id: 92
 
 // The id of the group object to which the membership belongs
 group_id: 17
 
 // The id of the user object to which the membership belongs
 user_id: 3
 
 // The current state of the membership. Current possible values are
 // "accepted", "invited", and "requested"
 workflow_state: "accepted"
 
 // Whether or not the user is a moderator of the group (the must also
 // be an active member of the group to moderate)
 moderator: true
 }
 */


@implementation CKGroupMembership

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];
        _groupIdent = [[info objectForKeyCheckingNull:@"group_id"] unsignedLongLongValue];
        _userIdent = [[info objectForKeyCheckingNull:@"user_id"] unsignedLongLongValue];
        
        NSString *workflowString = [info objectForKeyCheckingNull:@"workflow_state"];
        _groupMembershipState = stateForWorkflowString(workflowString);
        
        _isModerator = [[info objectForKeyCheckingNull:@"moderator"] boolValue];
    }
    return self;
}

static CKGroupMembershipState stateForWorkflowString(NSString *string) {
    CKGroupMembershipState state = CKGroupMembershipStateUnknown;
    
    if ([string isEqual:@"accepted"]) {
        state = CKGroupMembershipStateAccepted;
    }
    else if ([string isEqual:@"invited"]) {
        state = CKGroupMembershipStateInvited;
    }
    else if ([string isEqual:@"requested"]) {
        state = CKGroupMembershipStateRequested;
    }
    return state;
}

- (NSUInteger)hash {
    return self.ident;
}

@end
