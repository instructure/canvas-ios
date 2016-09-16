//
//  AnnouncementCreationIPhoneStrategy.m
//  iCanvas
//
//  Created by David M. Brown on 12/19/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "AnnouncementCreationIPhoneStrategy.h"

@implementation AnnouncementCreationIPhoneStrategy

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded {
    // Announcements are always side comment
    return CKDiscussionTopicTypeSideComment;
}

- (BOOL)shouldHideThreadedControls {
    return YES;
}

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block
{
    // Topic type is ignored because announcements don't support it.
    [canvasAPI postAnnouncementForContext:context
                                withTitle:title
                                  message:message
                              attachments:attachments
                                    block:block];
}

- (NSString *)createDiscussionViewTitle
{
    return NSLocalizedString(@"Announcement", @"Title of the new announcement view");
}

@end
