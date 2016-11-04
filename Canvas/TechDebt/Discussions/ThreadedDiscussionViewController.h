
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
