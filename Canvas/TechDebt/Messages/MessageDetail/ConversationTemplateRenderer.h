//
//  ConversationTemplateRenderer.h
//  iCanvas
//
//  Created by BJ Homer on 10/19/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CKConversation;

@interface ConversationTemplateRenderer : NSObject

@property (assign) uint64_t currentUserID;

/**
 *
 * Note: Attachment links will be <a> tags pointing to show-attachment://ignore.this.host/{$ATTACHMENT_URL$}
 *
 */
 - (NSString *)htmlStringForObject:(CKConversation *)conversation;


@end
