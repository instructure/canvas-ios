//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
