//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
