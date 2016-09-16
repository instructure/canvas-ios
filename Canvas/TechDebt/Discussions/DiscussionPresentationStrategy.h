//
//  DiscussionPresentationStrategy.h
//  iCanvas
//
//  Created by David M. Brown on 12/19/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CanvasKit1/CanvasKit1.h>

@class CKDiscussionTopic;
@class CKContextInfo;

@protocol DiscussionPresentationStrategy <NSObject>

@required

// The title of the discussion tab
- (NSString *)tabTitle;

// The strategy to use for creating new discussions.
- (Class)createDiscussionStrategyClass;

// The method called when making a new canvas API request for discussion topics/announcements/etc.
- (void)requestItemsWithPageURL:(NSURL *)pageURL
                    contextInfo:(CKContextInfo *)contextInfo
                      canvasAPI:(CKCanvasAPI *)canvasAPI
                 resultsHandler:(CKPagedArrayBlock)completion;

- (BOOL)allowsDiscussionCreationForCourse:(CKCourse *)course;

// String to use for confirming deletion of a discussion
- (NSString *)textForConfirmingDeletionOfDiscussion:(CKDiscussionTopic *)discussion;

@optional 

// The string to use for the create new discussion cell on iPad
- (NSString *)textForCreateDiscussionCell;

@end
