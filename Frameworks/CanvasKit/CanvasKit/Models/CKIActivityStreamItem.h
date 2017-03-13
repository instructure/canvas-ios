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
