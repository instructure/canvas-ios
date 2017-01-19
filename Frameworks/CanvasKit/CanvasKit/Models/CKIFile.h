//
//  CKIFile.h
//  CanvasKit
//
//  Created by rroberts on 9/19/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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

