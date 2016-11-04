
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
    
    

#import "CKConversation.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"
#import "CKUser.h"
#import "CKConversationRelatedSubmission.h"
#import "CKConversationMessage.h"
#import "CKConversationRecipient.h"
#import "NSArray+CKAdditions.h"

@implementation CKConversation

@synthesize ident;
@synthesize state;
@synthesize lastMessagePreview;
@synthesize lastMessageDate;
@synthesize messageCount;
@synthesize userIsSubscribed;
@synthesize isPrivate;
@synthesize label;
@synthesize hasAttachments;
@synthesize userIsLastAuthor;
@synthesize hasMediaAttachments;
@synthesize audienceIDs;
@synthesize audienceContexts;
@synthesize avatarURL;
@synthesize participants;
@synthesize relatedSubmissions;
@synthesize messages;


- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        ident = [info[@"id"] unsignedLongLongValue];

        NSString *stateStr = [info objectForKeyCheckingNull:@"workflow_state"];
        if ([@"unread" isEqualToString:stateStr]) {
            state = CKConversationStateUnread;
        }
        else if ([@"read" isEqualToString:stateStr]) {
            state = CKConversationStateRead;
        }
        else {
            NSAssert([@"archived" isEqualToString:stateStr], @"Unknown workflow_state");
            state = CKConversationStateArchived;
        }
        
        lastMessagePreview = [[info objectForKeyCheckingNull:@"last_message"] copy];
        
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        lastMessageDate = [[formatter dateFromString:[info objectForKeyCheckingNull:@"last_message_at"]] copy];
        
        messageCount = [info[@"message_count"] unsignedIntegerValue];
        
        userIsSubscribed = [info[@"subscribed"] boolValue];
        
        isPrivate = [info[@"private"] boolValue];
        
        label = [[info objectForKeyCheckingNull:@"label"] copy];
        
        NSArray *properties = [info objectForKeyCheckingNull:@"properties"];
        if ([properties containsObject:@"attachments"]) {
            hasAttachments = YES;
        }
        if ([properties containsObject:@"last_author"]) {
            userIsLastAuthor = YES;
        }
        if ([properties containsObject:@"media_objects"]) {
            hasMediaAttachments = YES;
        }
        
        audienceIDs = [[info objectForKeyCheckingNull:@"audience"] copy];
        
        audienceContexts = [[info objectForKeyCheckingNull:@"audience_contexts"] copy];
        
        avatarURL = [[NSURL URLWithString:[info objectForKeyCheckingNull:@"avatar_url"]] copy];
        
        NSArray *participantDicts = [info objectForKeyCheckingNull:@"participants"];
        
        NSMutableArray *tmpParticipants = [NSMutableArray arrayWithCapacity:participantDicts.count];
        for (NSDictionary *userDict in participantDicts) {
            CKConversationRecipient *user = [[CKConversationRecipient alloc] initWithInfo:userDict];
            [tmpParticipants addObject:user];
        }
        participants = [tmpParticipants copy];
        
        NSArray *messageDicts = [info objectForKeyCheckingNull:@"messages"];
        NSMutableArray *tmpMessages = [NSMutableArray arrayWithCapacity:messageDicts.count];
        for (NSDictionary *dict in messageDicts) {
            CKConversationMessage *message = [[CKConversationMessage alloc] initWithInfo:dict];
            [tmpMessages addObject:message];
        }
        messages = [tmpMessages copy];
        
        NSArray *submissionDicts = [info objectForKeyCheckingNull:@"submissions"];
        NSMutableArray *tmpSubmissions = [NSMutableArray arrayWithCapacity:submissionDicts.count];
        for (NSDictionary *dict in submissionDicts) {
            CKConversationRelatedSubmission *submission = [[CKConversationRelatedSubmission alloc] initWithInfo:dict];
            [tmpSubmissions addObject:submission];
        }
        relatedSubmissions = [tmpSubmissions copy];
        
    }
    return self;
}

- (void)updateWithConversation:(CKConversation *)conversation {
    self.messages = conversation.messages;
    
    self.state = conversation.state;
    self.lastMessagePreview = conversation.lastMessagePreview;
    self.lastMessageDate = conversation.lastMessageDate;
    self.messageCount = conversation.messageCount;
    self.userIsSubscribed = conversation.userIsSubscribed;
    self.isPrivate = conversation.isPrivate;
    self.label = conversation.label;
    self.hasAttachments = conversation.hasAttachments;
    self.userIsLastAuthor = conversation.userIsLastAuthor;
    self.hasMediaAttachments = conversation.hasMediaAttachments;
    self.audienceIDs = conversation.audienceIDs;
    self.audienceContexts = conversation.audienceContexts;
    self.participants = conversation.participants;
    self.avatarURL = conversation.avatarURL;
    
    if (conversation.relatedSubmissions) {
        // Note: Don't unconditionally update relatedSubmissions, since it's not included in the POST add_message response.    
        self.relatedSubmissions = conversation.relatedSubmissions;
    }
}


- (void)updateWithNewMessagesFromConversation:(CKConversation *)conversation {
    
    NSArray *combinedMessages = [conversation.messages arrayByAddingObjectsFromArray:self.messages];
    [self updateWithConversation:conversation];
    self.messages = combinedMessages;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<(CKConversation %p) id: %qu, messageCount: %d>", self, ident, messageCount];
}



- (NSArray *)audience {
    NSArray *idsToShow = self.audienceIDs;
    NSMutableArray *usersToShow = [NSMutableArray array];
    for (NSNumber *userId in idsToShow) {
        CKConversationRecipient *user = [self.participants in_firstObjectPassingTest:
                                         ^BOOL(CKConversationRecipient *obj, NSUInteger idx, BOOL *stop) {
                                             return [obj ident] == [userId unsignedLongLongValue];
                                         }];
        
        [usersToShow addObject:user];
    }

    return usersToShow;
}

- (NSArray *)audienceNames {
    return [self.audience valueForKey:@"name"];
}

- (NSUInteger)hash {
    return ident << 6 + messageCount << 3 + state;
}

@end
