//
//  CKStreamConversationItem.h
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamItem.h"
@class CKConversation;

@interface CKStreamConversationItem : CKStreamItem

@property (nonatomic, assign) uint64_t conversationId;
@property (nonatomic, assign, getter = isPrivate) BOOL privateConversation;
@property (nonatomic, assign) int participantCount;
@property (nonatomic, assign) int messageCount;
@property (nonatomic, strong) CKConversation *conversation;

- (NSArray *)authorNames;
- (NSString *)latestMessage;

@end
