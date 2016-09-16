//
//  CKFolder.h
//  CanvasKit
//
//  Created by BJ Homer on 7/10/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
