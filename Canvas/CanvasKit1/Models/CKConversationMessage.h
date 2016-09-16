//
//  CKConversationMessage.h
//  CanvasKit
//
//  Created by BJ Homer on 10/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"
@class CKConversationAttachment;
@class CKConversationRelatedSubmission;

@interface CKConversationMessage : CKModelObject


//id:	The unique identifier for the message
//created_at:	The timestamp of the message
//body:	The actual message body
//author_id:	The id of the user who sent the message (see audience, participants)
//generated:	If true, indicates this is a system-generated message (e.g. "Bob added Alice to the conversation")
//media_comment:	Audio comment data for this message (if applicable). Fields include: id, title, media_id
//forwarded_messages:	If this message contains forwarded messages, they will be included here (same format as this list). Note that those messages may have forwarded messages of their own, etc.
//attachments:	Array of attachments for this message. Fields include: id, display_name, uuid

@property (assign) uint64_t ident;
@property (copy) NSDate *creationTime;
@property (copy) NSString *text;
@property (assign) uint64_t authorIdent;
@property (assign) BOOL isSystemGenerated;
@property (strong) CKConversationAttachment *mediaComment;
@property (copy) NSArray *forwardedMessages;
@property (copy) NSArray *attachments;
@property (strong) CKConversationRelatedSubmission *relatedSubmission;


- (id)initWithInfo:(NSDictionary *)info;

@end
