//
//  UnreadMessages.m
//  CanvasCore
//
//  Created by Derrick Hathaway on 10/9/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface TabBarBadgeCounts (React) <RCTBridgeModule>
@end

@implementation TabBarBadgeCounts (React)
RCT_EXPORT_MODULE(TabBarBadgeCounts);
RCT_EXTERN_METHOD(updateUnreadMessageCount:);
RCT_EXTERN_METHOD(updateTodoListCount:);

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
