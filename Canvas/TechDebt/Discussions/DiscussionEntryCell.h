//
//  DiscussionEntryCell.h
//  iCanvas
//
//  Created by BJ Homer on 5/7/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
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