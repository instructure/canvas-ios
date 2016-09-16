//
//  CKComment.h
//  CanvasKit
//
//  Created by Zach Wily on 6/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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
