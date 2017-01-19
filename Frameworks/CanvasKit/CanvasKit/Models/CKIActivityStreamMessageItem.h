//
//  CKIActivityStreamMessageItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

/**
 Generic notification message for letting students know things
 like an assignment was graded.
 */
@interface CKIActivityStreamMessageItem : CKIActivityStreamItem

/**
 The category of notification. Can be any of the following:
 - "Assignment Created"
 - "Assignment Changed"
 - "Assignment Due Date Changed"
 - "Assignment Graded"
 - "Assignment Submitted Late"
 - "Grade Weight Changed"
 - "Group Assignment Submitted Late"
 - "Due Date"
 */
@property (nonatomic, copy) NSString *notificationCategory;

/**
 The ID of the message.
 */
@property (nonatomic, copy) NSString *messageID;

@end
