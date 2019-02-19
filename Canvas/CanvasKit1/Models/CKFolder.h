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
#import "CKModelObject.h"



@interface CKFolder : CKModelObject <NSCopying>

- (id)initWithInfo:(NSDictionary *)info;

@property (assign) uint64_t ident;
@property (copy) NSString *contextIdent;
@property (assign) CKContextType contextType;
@property (assign, getter = isLocked) BOOL locked;
@property (assign, getter = isLockedForUser) BOOL lockedForUser;
@property (assign) unsigned int filesCount;
@property (assign) unsigned int foldersCount;
@property (copy) NSURL *foldersURL;
@property (copy) NSURL *filesURL;
@property (assign) unsigned int sortingPosition;
@property (copy) NSString *name;
@property (copy) NSString *fullName; // Includes path
@property (assign) uint64_t parentFolderIdent;
@property (copy) NSDate *creationDate;
@property (copy) NSDate *unlockAtDate;

@end
