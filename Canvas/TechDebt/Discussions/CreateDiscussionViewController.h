//
//  CreateDiscussionViewController.h
//  iCanvas
//
//  Created by joshua on 7/13/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/CKDiscussionTopic.h>
#import "CKRichTextInputView.h"

@protocol DiscussionCreationStrategy;
@class DiscussionsControllerHD;

@protocol CreateDiscussionDelegate <NSObject>
@required
- (void)showNewDiscussion:(CKDiscussionTopic *)discussionTopic;
@end

@interface CreateDiscussionViewController : UITableViewController <CKRichTextInputViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@property (weak, nonatomic) IBOutlet UISwitch *threadedDiscussionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *threadedSwitchLabel;

@property (nonatomic, strong) id <DiscussionCreationStrategy> createDiscussionStrategy;
@property (nonatomic,strong) CKCanvasAPI *canvasAPI;
@property (nonatomic,strong) CKContextInfo *contextInfo;
@property (nonatomic) BOOL iPadToolbarHidden;

@property id <CreateDiscussionDelegate> delegate;

- (id)initWithStrategy:(id <DiscussionCreationStrategy>)createDiscussionStrategy;

- (BOOL)hasContent;
- (void)dismissKeyboard;

@end
