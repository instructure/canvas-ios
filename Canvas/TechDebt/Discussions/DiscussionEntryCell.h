
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
#import <CanvasKit1/CanvasKit1.h>

#import "DiscussionChildCountIndicatorView.h"

@class CKDiscussionEntry;
@protocol DiscussionEntryCellDelegate;

@interface DiscussionEntryCell : UITableViewCell

@property (weak) id<DiscussionEntryCellDelegate> delegate;

@property (strong, nonatomic) CKDiscussionEntry *entry;
@property (strong, nonatomic) CKDiscussionTopic *topic;
@property (strong, nonatomic) CKCourse *course;
@property (strong) NSDictionary *participants;
@property (weak, nonatomic) IBOutlet CKRemoteImageButton *avatarView;
@property (weak) IBOutlet DiscussionChildCountIndicatorView *childCountIndicator;
@property (weak) IBOutlet UIView *unreadIndicator;
@property (weak) IBOutlet UIWebView *contentWebView;
@property (assign) BOOL showsHighlightOnTouch;
@property (weak, nonatomic) IBOutlet UIView *likesView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@property (copy) void(^preferredHeightHandler)(CGFloat height);

+ (NSString *)reuseIdentifierForItem:(CKDiscussionEntry *)entry;

- (void) whenVisibleForDuration:(NSTimeInterval)timeInterval
                        doBlock:(dispatch_block_t)block;

- (void) updateUnreadIndicatorsAnimated:(BOOL)animated;

- (void)updateHeader;

@end

@protocol DiscussionEntryCellDelegate
- (void)entryCell:(DiscussionEntryCell *)cell requestsOpenURL:(NSURL *)url;
- (void)entryCell:(DiscussionEntryCell *)cell requestLikeEntry:(BOOL)like completion:(void(^)(NSError*))completion;
@end