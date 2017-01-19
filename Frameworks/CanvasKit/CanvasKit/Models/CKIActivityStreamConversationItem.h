//
//  CKIActivityStreamConversationItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

@interface CKIActivityStreamConversationItem : CKIActivityStreamItem

/**
 This conversation item is private.
 */
@property (nonatomic) BOOL isPrivate;

/**
 The number of participants in the conversation.
 */
@property (nonatomic) NSUInteger participantCount;

/**
 The unique identifier for the conversation to which
 this stream item refers.
 */
@property (nonatomic, copy) NSString *conversationID;

@end
