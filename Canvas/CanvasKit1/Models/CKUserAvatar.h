//
//  CKUserAvatar.h
//  CanvasKit
//
//  Created by Joshua Dutton on 6/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
