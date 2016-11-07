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
