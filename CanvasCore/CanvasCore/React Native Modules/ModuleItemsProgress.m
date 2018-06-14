//
//  ModuleItemsProgress.m
//  CanvasCore
//
//  Created by Nate Armstrong on 6/13/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface ModuleItemsProgress: NSObject<RCTBridgeModule>

@end

@implementation ModuleItemsProgress

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(viewedDiscussion:(NSString *)courseID discussionID:(NSString *)discussionID)
{
    Session *session = TheKeymaster.currentClient.authSession;
    [session postProgressDiscussionViewedWithCourseID:courseID discussionTopicID:discussionID];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
