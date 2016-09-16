//
//  CKDiscussionTopic.m
//  CanvasKit
//
//  Created by Mark Suman on 11/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKDiscussionTopic.h"
#import "CKDiscussionEntry.h"
#import "CKStudent.h"
#import "CKAssignment.h"
#import "CKContextInfo.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAttachment.h"

@implementation CKDiscussionTopic

@synthesize ident, liveURL, assignment, assignmentIdent, discussionEntries;
@synthesize title, message, creatorName, postDate, lastReplyDate;
@synthesize hasMoreEntries;
@synthesize type;
@synthesize canAddAttachments;
@synthesize unreadChildren;
@synthesize requiresInitialPost;

- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment
{
    self = [super init];
    if (self) {
        self.ident = [info[@"id"] unsignedLongLongValue];
        self.assignment = anAssignment;
        self.contextInfo = [[CKContextInfo alloc] initWithContextType:CKContextTypeCourse ident:anAssignment.courseIdent];
        self.hasMoreEntries = YES; // until we hear otherwise
        
        _attachments = [NSMutableDictionary dictionary];
        
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.topicChildren = [info objectForKeyCheckingNull:@"topic_children"];
    
    self.liveURL = [NSURL URLWithString:info[@"url"]];
    self.title = [info objectForKeyCheckingNull:@"title"];
    self.message = [info objectForKeyCheckingNull:@"message"];
    if (!self.message) {
        self.message = @"";
    }
    
    self.creatorName = [info objectForKeyCheckingNull:@"user_name"];
    
    self.assignmentIdent = [[info objectForKeyCheckingNull:@"assignment_id"] unsignedLongLongValue];
    
    self.groupCategoryID = [[[info objectForKeyCheckingNull:@"assignment"] objectForKeyCheckingNull:@"group_category_id" ] unsignedLongLongValue];

    if (self.groupCategoryID == 0) {
        self.groupCategoryID = [[info objectForKeyCheckingNull:@"group_category_id" ] unsignedLongLongValue];
    }
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSString *postString = [info objectForKeyCheckingNull:@"posted_at"];
    if (postString) {
        self.postDate = [formatter dateFromString:postString];
    }
    
    NSString *lastReplyString = [info objectForKeyCheckingNull:@"last_reply_at"];
    if (lastReplyString) {
        self.lastReplyDate = [formatter dateFromString:lastReplyString];
    }
    
    // Default for type for discussions is "
    NSString *discussionType = [info objectForKeyCheckingNull:@"discussion_type"];
    if ([discussionType isEqualToString:@"threaded"]) {
        self.type = CKDiscussionTopicTypeThreaded;
    }
    else {
        self.type = CKDiscussionTopicTypeSideComment;
    }
    
    self.canAddAttachments = [[[info objectForKeyCheckingNull:@"permissions"] objectForKeyCheckingNull:@"attach"] boolValue];
    
    self.unreadChildren = [[info objectForKeyCheckingNull:@"unread_count"] intValue];
    
    self.requiresInitialPost = [[info objectForKeyCheckingNull:@"require_initial_post"] boolValue];
    
    self.isLocked = [[info objectForKeyCheckingNull:@"locked"] boolValue];
    
    _contentLock = [CKContentLock contentLockWithInfo:info];
    
    // Temporarily disable all discussion liking capabilities
    self.allowRating = NO; //[[info objectForKeyCheckingNull:@"allow_rating"] boolValue];
    self.onlyGradersCanRate = [[info objectForKeyCheckingNull:@"only_graders_can_rate"] boolValue];
    
    for (NSDictionary *entryAttachmentInfo in info[@"attachments"]) {
        CKAttachment *attachment = [[CKAttachment alloc] initWithInfo:entryAttachmentInfo];
        _attachments[@(attachment.ident)] = attachment;
    }

}

- (NSArray *)entriesForStudent:(CKStudent *)student
{
    return [self.discussionEntries filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"SELF.userIdent == %qu", student.ident]];
}

- (NSString *)keyString
{
    return [NSString stringWithFormat:@"%qu", self.ident];
}

- (void)recalculateUnreadChildren {
    int count = 0;
    for (CKDiscussionEntry *entry in self.discussionEntries) {
        count += entry.recursiveUnreadCount;
        if (entry.isUnread) {
            count += 1;
        }
    }
    self.unreadChildren = count;
}

- (NSUInteger)hash {
    return ident;
}

@end
