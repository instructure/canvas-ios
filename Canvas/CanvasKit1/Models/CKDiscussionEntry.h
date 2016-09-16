//
//  CKDiscussionEntry.h
//  CanvasKit
//
//  Created by Mark Suman on 11/5/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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
