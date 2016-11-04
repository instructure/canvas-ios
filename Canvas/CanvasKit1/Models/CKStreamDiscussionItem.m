
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
    
    

#import "CKStreamDiscussionItem.h"
#import "CKDiscussionTopic.h"
#import "NSDictionary+CKAdditions.h"
#import "CKCourse.h"
#import "CKGroup.h"

@implementation CKStreamDiscussionItem

@synthesize discussionTopicId, totalRootEntries, rootEntries;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        discussionTopicId = [info[@"discussion_topic_id"] unsignedLongLongValue];
        totalRootEntries = [info[@"total_root_discussion_entries"] intValue];
        rootEntries = [info objectForKeyCheckingNull:@"root_discussion_entries"];
    }
    
    return self;
}


- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.courseId) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKDiscussionTopic class], @(self.discussionTopicId)];
    } else if (self.groupId) {
        self.actionPath = @[[CKGroup class], @(self.groupId), [CKDiscussionTopic class], @(self.discussionTopicId)];
    }
}

- (NSDictionary *)latestEntry
{
    // TODO: unit test this to make sure it returns the correct one
    NSDictionary *entry = nil;
    
    if ([self.rootEntries count] > 0) {
        entry = [self.rootEntries lastObject];
    }
    
    return entry;
}

@end
