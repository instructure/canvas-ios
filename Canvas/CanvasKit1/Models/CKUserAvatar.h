
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

typedef enum {
    CKUserAvatarTypeNoPic       = 0,
    CKUserAvatarTypeTwitter     = 1,
    CKUserAvatarTypeLinkedIn    = 2,
    CKUserAvatarTypeAttachement = 3,
    CKUserAvatarTypeGravatar    = 4
} CKUserAvatarType;

@interface CKUserAvatar : CKModelObject

@property CKUserAvatarType type;
@property NSURL *URL;
@property NSString *token;
@property NSString *displayName;

- (id)initWithInfo:(NSDictionary *)info;

@end
