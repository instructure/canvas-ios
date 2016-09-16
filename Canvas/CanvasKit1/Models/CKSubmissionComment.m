//
//  CKComment.m
//  CanvasKit
//
//  Created by Zach Wily on 6/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKSubmissionComment.h"
#import "CKCommentAttachment.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "CKSubmission.h"
#import "CKUser.h"
#import "CKCanvasAPI.h"
#import "CKMediaComment.h"
#import "CKSafeDictionary.h"

@implementation CKSubmissionComment {
    NSDictionary *raw;
}

@synthesize submission, authorIdent, author, createdAt, attachments, body, mediaComment;

- (id)initWithInfo:(NSDictionary *)info andSubmission:(CKSubmission *)aSubmission
{
    self = [super init];
    if (self) {
        raw = info;
        self.submission = aSubmission;
        if (info[@"author_id"] && info[@"author_id"] != [NSNull null]) {
            self.authorIdent = [info[@"author_id"] unsignedLongLongValue];
        }
        self.authorName = info[@"author_name"];
        
        if (info[@"author"]) {
            CKCommentAuthor *user = [[CKCommentAuthor alloc] initWithInfo:info[@"author"]];
            self.author = user;
        }
        
        NSString *dateString = info[@"created_at"];
        if (dateString) {
            ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
            self.createdAt = [dateFormatter dateFromString:dateString];
        }
        
        self.body = info[@"comment"];
        attachments = [[NSMutableArray alloc] init];
        
        NSDictionary *mediaCommentInfo = [info objectForKeyCheckingNull:@"media_comment"];
        if (mediaCommentInfo) {
            CKMediaComment *attachment = [[CKMediaComment alloc] initWithInfo:mediaCommentInfo];
            
            [attachments addObject:attachment];
            mediaComment = attachment;
        }

        for (NSDictionary *attachmentInfo in info[@"attachments"]) {
            CKCommentAttachment *attachment = [[CKCommentAttachment alloc] initWithInfo:attachmentInfo];
            attachment.comment = self;
            
            [attachments addObject:attachment];
        }
    }
    return self;
}

- (id)initPlaceholdCommentWithSubmission:(CKSubmission *)aSubmission user:(CKUser *)aUser
{   
    self = [super init];
    if (self) {
        self.submission = aSubmission;
        self.authorIdent = aUser.ident;
        self.createdAt = [NSDate date];
        self.body = @"<div style='height:45px;'></div>";
    }
    
    return self;
}

- (id)initWithConversationSummaryInfo:(NSDictionary *)info {
    self = [self initWithInfo:info andSubmission:nil];
    if (self) {
        self.body = info[@"comment"];
    }
    return self;
}

- (NSUInteger)hash {
    return [self.createdAt hash];
}

@end


@implementation CKCommentAuthor


- (id)initWithInfo:(NSDictionary *)unsafeInfo {
    
    self = [super init];
    if (self) {
        CKSafeDictionary *info = [[CKSafeDictionary alloc] initWithDictionary:unsafeInfo];
        _ident = [info[@"id"] unsignedLongLongValue];
        _displayName = info[@"display_name"];
        NSString *avatarURLString = info[@"avatar_image_url"];
        if (avatarURLString) {
            _avatarURL = [NSURL URLWithString:avatarURLString];
        }
        
        NSString *htmlURL = info[@"html_url"];
        if (htmlURL) {
            _htmlProfileURL = [NSURL URLWithString:htmlURL];
        }
    }
    return self;
}

- (NSUInteger)hash {
    return self.ident;
}

@end
