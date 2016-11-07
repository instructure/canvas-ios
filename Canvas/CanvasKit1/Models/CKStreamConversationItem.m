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
    
    

#import "CKStreamConversationItem.h"
#import "CKConversation.h"

@implementation CKStreamConversationItem

@synthesize conversationId, privateConversation, participantCount, messageCount, conversation;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        conversationId = [info[@"conversation_id"] unsignedLongLongValue];
        privateConversation = [info[@"private"] boolValue];
        participantCount = [info[@"participant_count"] intValue];
        messageCount = [info[@"message_count"] intValue];
    }
    
    return self;
}


- (NSArray *)authorNames
{
    return conversation.audienceNames;
}

- (NSString *)latestMessage
{
    return self.conversation.lastMessagePreview;
}

- (void)populateActionPath {
    self.actionPath = @[[CKConversation class], @(self.conversationId)];
}

@end
