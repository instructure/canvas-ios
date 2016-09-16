//
//  CKPage.h
//  CanvasKit
//
//  Created by BJ Homer on 10/31/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKContentLock;

@interface CKPage : CKModelObject

@property NSDate *creationDate;
@property BOOL hiddenFromStudents;
@property NSString *title;
@property NSDate *updatedDate;
@property NSString *identifier;
@property (readonly) CKContentLock *contentLock;
@property (readonly) BOOL isFrontPage;

// Only present if individually fetched, not present when listing
@property NSString *body;

- (id)initWithInfo:(NSDictionary *)info;

@end
