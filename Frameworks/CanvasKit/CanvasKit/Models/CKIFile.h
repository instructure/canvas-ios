//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

