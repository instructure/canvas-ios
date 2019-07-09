//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import "CKILockableModel.h"
#import "CKICourse.h"

@interface CKIFolder : CKILockableModel

/**
 The context type of the folder.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 The id of the context for this folder
 */
@property (nonatomic, copy) NSString *contextID;


/**
 The number of files in this folder.
 */
@property (nonatomic) NSInteger filesCount;

/**
 The number of folders in this folder.
 */
@property (nonatomic) NSInteger foldersCount;

/**
 The API URL for accessing a listing of all folders in this folder.
 */
@property (nonatomic, strong) NSURL *foldersURL;

/**
 The API URL for accessing a listing of all files in this folder.
 */
@property (nonatomic, strong) NSURL *filesURL;

/**
 The date the folder was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date this folder was last updated.
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 When the folder will be unlocked.
 */
@property (nonatomic, strong) NSDate *unlockAt;

/**
 The name of the folder.
 */
@property (nonatomic, strong) NSString *name;

/**
 The full path of the folder from the root.
 
 @note Example: "course files/11folder"
 */
@property (nonatomic, strong) NSString *fullName;

/**
 The date after which the folder will be locked.
 */
@property (nonatomic, strong) NSDate *lockAt;

/**
 The ID of the folder's parent folder.
 */
@property (nonatomic, strong) NSString *parentFolderID;

/**
 If this folder should be hidden from this user.
 */
@property (nonatomic, getter = isHiddenForUser) BOOL hiddenForUser;

/**
 Sort position for the folder
 */
@property (nonatomic) NSInteger position;

@end
