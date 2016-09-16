//
//  DiscussionCreationIPhoneStrategy.m
//  iCanvas
//
//  Created by David M. Brown on 12/19/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "DiscussionCreationIPhoneStrategy.h"

@implementation DiscussionCreationIPhoneStrategy

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded
{
    if (threaded) {
        return CKDiscussionTopicTypeThreaded;
    }
    else {
        return CKDiscussionTopicTypeSideComment;
    }
}

- (BOOL)shouldHideThreadedControls
{
    return NO;
}

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block
{
    [canvasAPI postDiscussionTopicForContext:context
                                   withTitle:title
                                     message:message
                                 attachments:attachments
                                   topicType:topicType
                                       block:block];
}

- (NSString *)createDiscussionViewTitle
{
    return NSLocalizedString(@"Discussion", @"Title of the new discussion view");
}

@end
