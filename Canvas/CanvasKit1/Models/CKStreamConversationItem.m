//
//  CKStreamConversationItem.m
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
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
