
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
