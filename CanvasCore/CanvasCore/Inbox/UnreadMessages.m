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

@interface UnreadMessages (React) <RCTBridgeModule>
@end

@implementation UnreadMessages (React)
RCT_EXPORT_MODULE(UnreadMessages);
RCT_EXTERN_METHOD(updateUnreadCount:);
@end
