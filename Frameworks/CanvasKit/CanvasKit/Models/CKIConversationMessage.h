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
