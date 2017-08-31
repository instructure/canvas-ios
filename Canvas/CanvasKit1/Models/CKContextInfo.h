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
#import "CKCommonTypes.h"

@class CKCourse, CKGroup, CKUser;

@interface CKContextInfo : NSObject <NSCopying>

+ (CKContextInfo *)contextInfoFromCourse:(CKCourse *)course;
+ (CKContextInfo *)contextInfoFromCourseIdent:(uint64_t)courseIdent;
+ (CKContextInfo *)contextInfoFromGroup:(CKGroup *)group;
+ (CKContextInfo *)contextInfoFromGroupIdent:(uint64_t)groupIdent;
+ (CKContextInfo *)contextInfoFromUser:(CKUser *)user;
+ (CKContextInfo *)contextInfoFromUserIdent:(uint64_t)userIdent;

- (id)initWithContextType:(CKContextType)type ident:(uint64_t)ident;

@property (readonly) CKContextType contextType;
@property (readonly) uint64_t ident;

@end
