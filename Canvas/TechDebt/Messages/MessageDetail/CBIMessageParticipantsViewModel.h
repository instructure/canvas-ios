//
//  CBIMessageParticipantsViewModel.h
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIConversation;
@class RACSignal;

@interface CBIMessageParticipantsViewModel : NSObject
@property (nonatomic) CKIConversation *model;
@property (nonatomic, copy) NSArray *pendingRecipients;

@property (nonatomic, weak) UIViewController *viewControllerToPresentFrom;
- (void)showRecipientsPopoverInView:(UIView *)parent fromButton:(UIView *)button;


- (void)signalNewRecipients;
@property (nonatomic, readonly) RACSignal *recipientsAddedSignal;
@end
