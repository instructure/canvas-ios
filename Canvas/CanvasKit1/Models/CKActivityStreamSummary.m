//
//  CKActivityStreamSummary.m
//  CanvasKit
//
//  Created by nlambson on 6/11/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKActivityStreamSummary.h"
#import "NSDictionary+CKAdditions.h"
#import "CKCanvasAPI+ActivityStream.h"

@implementation CKActivityStreamSummary

- (id)initWithInfo:(NSArray *)info{
    
    self = [super init];
    if (self) {
        
        [info enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSDictionary *safeDict = [dict safeCopy];
            
            if([safeDict[@"type"] isEqualToString:@"DiscussionTopic"]){
                _discussionTopicCount = [safeDict[@"count"] integerValue];
                _discussionTopicUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Announcement"]){
                _announcementCount = [safeDict[@"count"] integerValue];
                _announcementUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Conversation"]){
                _conversationCount = [safeDict[@"count"] integerValue];
                _conversationUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Message"]){
                _messageCount = [safeDict[@"count"] integerValue];
                _messageUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Submission"]){
                _submissionCount = [safeDict[@"count"] integerValue];
                _submissionUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Conference"]){
                _conferenceCount = [safeDict[@"count"] integerValue];
                _conferenceUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"Collaboration"]){
                _collaborationCount = [safeDict[@"count"] integerValue];
                _collaborationUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            else if([safeDict[@"type"] isEqualToString:@"CollectionItem"]){
                _collectionItemCount = [safeDict[@"count"] integerValue];
                _collectionItemUnreadCount = [safeDict[@"unread_count"] integerValue];
            }
            
            _count = _count + [safeDict[@"count"] integerValue];
            _unreadCount = _unreadCount + [safeDict[@"unread_count"] integerValue];
        }];
    }
    return self;
}

+ (id)activityStreamSummary:(NSArray *)info{
    return [[CKActivityStreamSummary alloc] initWithInfo:info];
}

- (NSInteger)totalCount{
    return  _count;
}

- (NSInteger)totalUnreadCount{
    return  _unreadCount;
}

@end
