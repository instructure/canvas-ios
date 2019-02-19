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

extern NSString *CKDiscussionEntryMediaToken;

@class CKDiscussionTopic, CKStudent;

@interface CKDiscussionEntry : CKModelObject

@property (nonatomic, weak) CKDiscussionTopic *discussionTopic;
@property (nonatomic, weak) CKDiscussionEntry *parentEntry;
@property (nonatomic, weak) CKStudent *student;
@property (nonatomic, strong) NSString *internalIdent;

// JSON values
@property uint64_t ident;
@property uint64_t userIdent;
@property uint64_t parentEntryIdent;
@property (copy) NSString *userName;
@property (copy) NSURL *userAvatarURL;
@property (nonatomic, strong) NSString *entryMessage;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (strong, nonatomic, readonly) NSMutableDictionary *attachments;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, copy) NSArray *replies;

@property (readonly) BOOL allowsReplies;

@property (assign, getter=isDeleted) BOOL deleted;
@property (assign, nonatomic, getter=isUnread) BOOL unread;

@property (readonly) int recursiveReplyCount;
@property (readonly) int recursiveUnreadCount;
@property (readonly) BOOL hasUnreadDescendant;

- (id)initWithInfo:(NSDictionary *)info andDiscussionTopic:(CKDiscussionTopic *)aDiscussionTopic entryRatings:(NSDictionary*)entryRatings;

- (void)updateWithInfo:(NSDictionary *)info;
- (NSString *)JSONString;

@end
