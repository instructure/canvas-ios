//
//  CKIAttachment.h
//  CanvasKit
//
//  Created by derrick on 11/26/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIAttachment : CKIModel
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic) NSUInteger size;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *unlockAt;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL hiddenForUser;
@property (nonatomic) BOOL lockedForUser;
@property (nonatomic, copy) NSURL *thumbnailURL;
@end
