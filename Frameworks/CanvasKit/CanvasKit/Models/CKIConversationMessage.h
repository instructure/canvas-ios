//
//  CKIConversationMessage.h
//  CanvasKit
//
//  Created by derrick on 11/26/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
