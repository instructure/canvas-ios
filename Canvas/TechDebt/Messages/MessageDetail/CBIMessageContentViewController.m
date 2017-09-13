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
    
    

#import "CBIMessageContentViewController.h"
#import "CBIMessageViewModel.h"
#import <CanvasKit1/CanvasKit1.h>
#import "EXTScope.h"
#import "CBIMessageParticipantsViewModel.h"

@import CanvasKeymaster;

@interface CBIMessageContentViewController ()
@end

@implementation CBIMessageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.hasLoadedConversation) {
        return;
    }

    RACSignal *participantsAdded = self.viewModel.participantsViewModel.recipientsAddedSignal;
    RACSignal *messageCount = [RACObserve(self, viewModel.model.messageCount) distinctUntilChanged];
    [self rac_liftSelector:@selector(refreshConversationIgnoringValue:) withSignals:[RACSignal merge:@[messageCount, participantsAdded]], nil];
}

- (void)refreshConversationIgnoringValue:(id)ignored
{
    if (self.viewModel.model == nil) {
        return;
    }

    @weakify(self);
    [[[[CKIClient currentClient] refreshConversation:self.viewModel.model] map:^id(CKIConversation *updatedConversation) {
        NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:updatedConversation];
        CKConversation *oldConversation = [[CKConversation alloc] initWithInfo:dict];
        return oldConversation;
    }] subscribeNext:^(CKConversation *legacyConversation) {
        @strongify(self);
        self.conversation = legacyConversation;
        self.hasLoadedConversation = YES;
    }];
}

@end
