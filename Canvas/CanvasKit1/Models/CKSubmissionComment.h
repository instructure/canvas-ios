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

@class CKSubmission;
@class CKUser;
@class CKCommentAuthor;
@class CKMediaServer;
@class CKAttachment;
@class CKMediaComment;

@interface CKSubmissionComment : CKModelObject

@property (nonatomic, weak) CKSubmission *submission;
@property (nonatomic, assign) uint64_t authorIdent;
@property (nonatomic, strong) CKCommentAuthor *author;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSMutableArray *attachments;
@property (nonatomic, strong) CKMediaComment *mediaComment; // This will also be in the 'attachments' array
@property (nonatomic, strong) NSString *body;

- (id)initWithInfo:(NSDictionary *)info andSubmission:(CKSubmission *)aSubmission;
- (id)initPlaceholdCommentWithSubmission:(CKSubmission *)aSubmission user:(CKUser *)aUser;
- (id)initWithConversationSummaryInfo:(NSDictionary *)info;

@end


@interface CKCommentAuthor : CKModelObject

@property (readonly) uint64_t ident;
@property (readonly, copy) NSString *displayName;
@property (readonly, copy) NSURL *avatarURL;
@property (readonly, copy) NSURL *htmlProfileURL;

- (id)initWithInfo:(NSDictionary *)info;

@end;
