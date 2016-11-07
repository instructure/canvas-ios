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
    
    

#import "CKModelObject.h"

@interface CKActivityStreamSummary : NSObject

//see original API endpoint for types: https://canvas.instructure.com/doc/api/users.html#method.users.activity_stream
@property (readonly) NSInteger discussionTopicCount;
@property (readonly) NSInteger discussionTopicUnreadCount;

@property (readonly) NSInteger announcementCount;
@property (readonly) NSInteger announcementUnreadCount;

@property (readonly) NSInteger conversationCount;
@property (readonly) NSInteger conversationUnreadCount;

@property (readonly) NSInteger messageCount;
@property (readonly) NSInteger messageUnreadCount;

@property (readonly) NSInteger submissionCount;
@property (readonly) NSInteger submissionUnreadCount;

@property (readonly) NSInteger conferenceCount;
@property (readonly) NSInteger conferenceUnreadCount;

@property (readonly) NSInteger collaborationCount;
@property (readonly) NSInteger collaborationUnreadCount;

@property (readonly) NSInteger collectionItemCount;
@property (readonly) NSInteger collectionItemUnreadCount;

@property (readonly) NSInteger count;
@property (readonly) NSInteger unreadCount;

- (id)initWithInfo:(NSArray *)info;
+ (id)activityStreamSummary:(NSArray *)info;

- (NSInteger)totalCount;
- (NSInteger)totalUnreadCount;

@end
