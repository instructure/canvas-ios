//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    [Session.current postProgressDiscussionViewedWithCourseID:courseID discussionTopicID:discussionID];
}

RCT_EXPORT_METHOD(contributedDiscussion:(NSString *)courseID discussionID:(NSString *)discussionID)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.instructure.core.notification.ModuleItemRequirementCompleted" object:nil];
    [Session.current postProgressDiscussionContributedWithCourseID:courseID discussionTopicID:discussionID];
}

RCT_EXPORT_METHOD(viewedPage:(NSString *)courseID pageURL:(NSString *)pageURL)
{
    [Session.current postProgressPageViewedWithCourseID:courseID pageURL:pageURL];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
