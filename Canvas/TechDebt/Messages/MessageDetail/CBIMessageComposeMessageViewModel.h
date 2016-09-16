//
//  CBIMessageComposeMessageViewModel.h
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit1/CanvasKit1.h>
@import CanvasKit;
#import "CKAttachmentManager.h"

@class CBIMessageParticipantsViewModel;

@interface CBIMessageComposeMessageViewModel : NSObject <CKAttachmentManagerDelegate>
@property (nonatomic) CKIConversation *model;
@property (nonatomic) CBIMessageParticipantsViewModel *participantsViewModel;
@property (nonatomic) CKAttachmentManager *attachmentManager;
@property (nonatomic) BOOL isUploading;
@property (nonatomic) NSInteger attachmentCount;

@property (nonatomic, strong) NSString *currentTextEntry;

- (void)sendMessageFromTextView:(UITextView *)textView;
- (void)addAttachmentsFromButton:(UIButton *)button;

@property (nonatomic, weak) UITableViewController *messageDetailTableViewController;
@end
