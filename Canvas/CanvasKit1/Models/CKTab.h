//
//  CKTab.h
//  CanvasKit
//
//  Created by David M. Brown on 11/12/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKTabTypeUnknown,
    CKTabTypeInternal,
    CKTabTypeExternal
} CKTabType;

@interface CKTab : CKModelObject

@property (readonly) NSString *identStr;
@property (readonly) NSURL *htmlURL;
@property (readonly) NSString *label;
@property (readonly) CKTabType tabType;
@property (readonly) NSURL *externalToolCreateSessionURL;

/**
 * Initialize the CKCourseTab object with the information contained in the info dictionary
 *
 * @param info The dictionary from which to obtain initialization values. The following keys will be used:
 *   'id'
 *   'html_url'
 *   'label'
 *   'type'
 * 'id' is required, and if it is missing, this object will be released and this method will return nil.
 */
- (id)initWithInfo:(NSDictionary *)info;
- (BOOL)hasSameIdentityAs:(NSObject *)object;

@end
