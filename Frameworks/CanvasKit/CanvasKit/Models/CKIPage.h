//
//  CKIPage.h
//  CanvasKit
//
//  Created by Jason Larsen on 9/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKILockableModel.h"

@class CKIUser;

@interface CKIPage : CKILockableModel

/**
 The title of the page.
 */
@property (nonatomic, copy) NSString *title;

/**
 The date the page was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date the page was last updated.
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 This page is hidden from students.
 
 @note Students will never see this true; pages hidden
 from them will be omitted from results
 */
@property (nonatomic) BOOL hideFromStudents;

/**
 The user that last edited this page.
 */
@property (nonatomic, readonly) CKIUser *lastEditedBy;

@property (nonatomic) BOOL published;

@property (nonatomic) BOOL frontPage;

@end
