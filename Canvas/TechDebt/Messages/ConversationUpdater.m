//
//  ConversationUpdater.m
//  iCanvas
//
//  Created by Stephen Lottermoser on 10/24/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>

#import "ConversationUpdater.h"
#import "CanvasKit1/CKCanvasAPI.h"
#import "CanvasKit1/CKConversation.h"
#import <CanvasKit1/CKPaginationInfo.h>
#import "CKCanvasAPI+CurrentAPI.h"

NSString * const iCanvasInboxUnreadCount = @"unreadCount";
NSString * const iCanvasInboxUnreadItems = @"unreadConversations";
NSString * const iCanvasInboxUnreadHasMore = @"iCanvasInboxUnreadHasMore";
NSString * const iCanvasInboxUpdatedNotification = @"iCanvasInboxUpdatedNotification";
NSString * const iCanvasSupportNotificationCountUpdatedNotification = @"iCanvasSupportNotificationCountUpdatedNotification";
NSString * const iCanvasSupportNotificationCountKey = @"iCanvasSupportNotificationCountKey";


@interface ConversationUpdater ()

- (void)updateUnreadConversationCount;

@end

@implementation ConversationUpdater

- (void)startPollingForInboxUpdates
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateApplicationIconBadgeNumber:) name:iCanvasInboxUpdatedNotification object:nil];
    // this causes the singleton to be instantiated and scheduled.
    [ConversationUpdater sharedConversationUpdater];
}

- (void)updateApplicationIconBadgeNumber:(NSNotification *)note
{
    int unreadCount = [[note userInfo][iCanvasInboxUnreadCount] intValue];
    
    NSInteger countToShow = unreadCount; //+ todo items, etc
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:countToShow];
}

+ (instancetype)sharedConversationUpdater
{
    static ConversationUpdater *updater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updater = [[self alloc] init];
    });
    return updater;
}

@synthesize timer;
@synthesize conversationsInfo;

- (id)init
{
    self = [super init];
    if (self) {
        NSTimeInterval interval = 300.0;
        timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateUnreadConversationCount) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)updateUnreadConversationCount
{
    CKCanvasAPI *api = CKCanvasAPI.currentAPI;
    int originalItemsPerPage = api.itemsPerPage;
    api.itemsPerPage = 999;
    [api getConversationsInScope:CKAPIConversationScopeUnread withPageURL:nil block:
     
     ^(NSError *error, NSArray *theConversations, CKPaginationInfo *pagination) {
         if (error) {
             // Don't present an error; this was a background operation.
             return;
         }
         int unreadConversationCount = 0;
         NSMutableArray *unreadConversationIDs = [NSMutableArray array];
         
         for (CKConversation *conversation in theConversations) {
             if (conversation.state == CKConversationStateUnread) {
                 unreadConversationCount++;
                 [unreadConversationIDs addObject:@(conversation.ident)];
             }
         }
         
         self.conversationsInfo = @{iCanvasInboxUnreadCount: @(unreadConversationCount),
                                   iCanvasInboxUnreadItems: theConversations,
                                    iCanvasInboxUnreadHasMore: @(pagination.nextPage != nil)};
         
         [[NSNotificationCenter defaultCenter] postNotificationName:iCanvasInboxUpdatedNotification object:self userInfo:self.conversationsInfo];
         
     }];
    api.itemsPerPage = originalItemsPerPage;
}

@end
