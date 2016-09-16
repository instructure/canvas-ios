//
//  CBIMessageViewModel.m
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageViewModel.h"
#import "CBIMessageDetailViewController.h"
#import "CBIMessageComposeMessageViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "CBIMessageParticipantsViewModel.h"

@implementation CBIMessageViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _participantsViewModel = [CBIMessageParticipantsViewModel new];
        _composeViewModel = [CBIMessageComposeMessageViewModel new];
        _composeViewModel.participantsViewModel = _participantsViewModel;
        
        RAC(self, sender) = [RACSignal combineLatest:@[RACObserve(self, model.participants), RACObserve(self, model.audienceIDs)] reduce:^(NSArray *participants, NSArray *audience) {
            
            NSArray *audienceUserNames = [[[participants.rac_sequence filter:^BOOL(CKIUser *user) {
                return [audience containsObject:user.id];
            }] map:^id(CKIUser *user) {
                return user.name;
            }] array];
            
            return [audienceUserNames componentsJoinedByString:@", "];
        }];
        
        RAC(self, date) = [RACObserve(self, model) map:^(CKIConversation *model) {
            return model.lastAuthoredMessageAt ?: model.lastMessageAt;
        }];
        RAC(self, isUnread, @NO) = [RACObserve(self, model.workflowState) map:^(NSNumber *value) {
            CKIConversationWorkflowState state = [value integerValue];
            return @(state == CKIConversationWorkflowStateUnread);
        }];
        RAC(self, hasAttachment, @NO) = RACObserve(self, model.hasAttachments);
        RAC(self, messagePreview) = [RACObserve(self, model) map:^(CKIConversation *model) {
            return model.lastAuthoredMessage ?: model.lastMessage;
        }];
        RAC(self, subject) = RACObserve(self, model.subject);
        RAC(self, participantsViewModel.model) = RACObserve(self, model);
        RAC(self, composeViewModel.model) = RACObserve(self, model);
    }
    return self;
}

- (void)viewController:(CBIMessageDetailViewController *)detailViewController viewWillAppear:(BOOL)animated {
    
    self.composeViewModel.attachmentManager = detailViewController.attachmentManager;
    self.composeViewModel.attachmentManager.delegate = self.composeViewModel;
}

@end
