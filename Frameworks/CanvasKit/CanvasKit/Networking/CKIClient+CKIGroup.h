//
//  CKIClient+CKIGroup.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
