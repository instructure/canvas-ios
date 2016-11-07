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
