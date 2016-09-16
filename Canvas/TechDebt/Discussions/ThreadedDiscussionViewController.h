//
//  ThreadedDiscussionViewController.h
//  iCanvas
//
//  Created by BJ Homer on 5/7/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBIDiscussionTopicViewModel.h"

@class CKDiscussionEntry;
@class CKDiscussionTopic;
@class CKCanvasAPI;
@class CKContextInfo;

@interface ThreadedDiscussionViewController : UIViewController

@property (weak) IBOutlet UITableView *tableView;

// Required Objects or Idents
@property (nonatomic) CKDiscussionTopic *topic;
@property uint64_t topicIdent; // Only used if `topic` is not set
@property CKContextInfo *contextInfo;

@property CKDiscussionEntry *entry;
@property CKCanvasAPI *canvasAPI;
@property (nonatomic) id<CBIDiscussionTopicViewModel> viewModel;

- (void)fetchTopic:(BOOL)isAnnouncement;

@end


@interface UIViewController (ThreadedDiscussions)
// Implement this in a parent view controller to be
// notified when discussions change.
- (void)discussionUnreadCountChanged;
@end
