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

@interface CKIFile : CKILockableModel

/**
 The size of the file in bytes.
 */
@property (nonatomic) NSInteger size;

/**
 The HTTP content type of the media.
 */
@property (nonatomic, strong) NSString *contentType;

/**
 The name of the file. Ex: file.txt
 */
@property (nonatomic, strong) NSString *name;

/**
 The download URL for this file in Canvas.
 */
@property (nonatomic, strong) NSURL *url;

/**
 The date the file was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date the file was last modified.
 */
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) NSDate *unlockAt;

@property (nonatomic, strong) NSDate *lockAt;

/**
 If the file should be hidden from the current user.
 */
@property (nonatomic, getter = isHiddenForUser) BOOL hiddenForUser;

/**
 The URL of the thumbnail for the file.
 */
@property (nonatomic, strong) NSURL *thumbnailURL;

/**
 The URL of the preview for the file.
 */
@property (nonatomic, strong) NSString *previewURLPath;

@property (nonatomic, getter = isLocked) BOOL locked;

@property (nonatomic, getter = isHidden) BOOL hidden;




@property (nonatomic, readonly) BOOL isMediaAttachment;

@end

