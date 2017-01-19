//
//  CKIActivityStreamItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

/**
 Base class for all activity stream items. There are many different types
 of activity stream item: discussion topics, announcements, conversations, messages,
 submissions, conferences, collaborations... and maybe more in the future.
 
 For properties specific to each of these types, use the methods provided
 by their appropriate subclasses.
 */
@interface CKIActivityStreamItem : CKIModel

/**
 The title of the activity stream item.
 */
@property (nonatomic, copy) NSString *title;

/**
 The body text message describing the stream item. It is plain-text and can
 be multiple paragraphs.
 */
@property (nonatomic, copy) NSString *message;

/**
 The ID of this item's course, if it belongs to a group.
 
 @see groupID
 */
@property (nonatomic, copy) NSString *courseID;

/**
 The ID of this item's group, if it belongs to a group.
 
 @see courseID
 */
@property (nonatomic, copy) NSString *groupID;

/**
 The date the item was created at.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date the item was last updated at.
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 The URL to the canvas API endpoint for this item.
 */
@property (nonatomic, strong) NSURL *url;

/**
 The URL to the HTML web canvas page for this item.
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 Whether or not the notification has been read.
 */
@property (nonatomic) BOOL isRead;

/**
 A transformer that will take a JSON dictionary for an activity stream item
 and transform it into an instance of the correct CKIActivityStreamItem
 subclass.
 */
+ (NSValueTransformer *)activityStreamItemTransformer;

@end
