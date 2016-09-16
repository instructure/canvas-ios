//
//  ConversationUpdater.h
//  iCanvas
//
//  Created by Stephen Lottermoser on 10/24/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const iCanvasInboxUpdatedNotification;
extern NSString * const iCanvasInboxUnreadCount;
extern NSString * const iCanvasInboxUnreadItems;
extern NSString * const iCanvasInboxUnreadHasMore;

@interface ConversationUpdater : NSObject

+ (instancetype)sharedConversationUpdater;

@property (strong) NSTimer *timer;
@property (strong) NSDictionary *conversationsInfo;

- (void)startPollingForInboxUpdates;
- (void)updateUnreadConversationCount;

@end
