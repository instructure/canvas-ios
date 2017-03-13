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

@class CKIAttachment;

@interface CKIDiscussionEntry : CKIModel
/**
The unique identifier for the author of the entry.
 */
@property (nonatomic, copy) NSString *userID;

/**
 The unique user id of the person to last edit the entry, if different than user_id.
 */
@property (nonatomic, copy) NSString *editorID;

/**
 The name of the author of the entry.
 */
@property (nonatomic, copy) NSString *userName;

/**
The content of the entry.
 */
@property (nonatomic, copy) NSString *message;

/**
The read state of the entry, "read" or "unread".
 */
@property (nonatomic, getter=isRead) BOOL read;

/**
Whether the read_state was forced (was set manually)
 */
@property (nonatomic, getter=isManuallyMarkedReadOrUnread) BOOL manuallyMarkedReadOrUnread;

/**
 The creation time of the entry, in ISO8601 format.
 */
@property (nonatomic) NSDate *createdAt;

/**
 The updated time of the entry, in ISO8601 format.
 */
@property (nonatomic) NSDate *updatedAt;

/**
 JSON representation of the attachment for the entry, if any. Present only if there is an attachment.
 */
@property (nonatomic) CKIAttachment *attachment;

/**
 The 10 most recent replies for the entry, newest first. Present only if there is at least one reply.
 */
@property (nonatomic, copy) NSArray *recentReplies;

/**
 True if there are more than 10 replies for the entry (i.e., not all were included in this response). Present only if there is at least one reply.
 */
@property (nonatomic) BOOL hasMoreReplies;

@end
