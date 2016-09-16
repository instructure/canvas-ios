//
//  DiscussionCreationStrategy.h
//  iCanvas
//
//  Created by David M. Brown on 12/19/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CanvasKit1/CanvasKit1.h>

@protocol DiscussionCreationStrategy <NSObject>

@required

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded;

- (BOOL)shouldHideThreadedControls;

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block;

@optional

// The title displayed in the view responsible for posting new discussions
- (NSString *)createDiscussionViewTitle;

@end
