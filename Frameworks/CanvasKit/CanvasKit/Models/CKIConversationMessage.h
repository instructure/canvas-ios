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

@class CKIMediaComment, CKISubmission;

@interface CKIConversationMessage : CKIModel

/**
 the date that the message was created
 */
@property (nonatomic, copy) NSDate *createdAt;

/**
 the body of the message (html)
 */
@property (nonatomic, copy) NSString *body;

/**
 The id of the author
 */
@property (nonatomic, copy) NSString *authorID;

/**
 an array of CKIConversationMessage objects that represent
 forwarded messages
 */
@property (nonatomic, copy) NSArray *forwardedMessages;

/**
 an array of `CKIConversationMessageAttachment`s
 */
@property (nonatomic, copy) NSArray *attachments;

/**
 Is this a system generated message i.e.: "Bob added Alice to the conversation"
 */
@property (nonatomic) BOOL generated;

/**
 A CKIConversationMediaComment
 */
@property (nonatomic) CKIMediaComment *mediaComment;


/**
 The submission that this conversation belongs to
 */
@property (nonatomic) CKISubmission *submission;

@end
