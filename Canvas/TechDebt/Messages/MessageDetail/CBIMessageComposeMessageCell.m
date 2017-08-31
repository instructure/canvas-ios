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
    
    

#import "CBIMessageComposeMessageCell.h"

#import "CBIMessageComposeMessageViewModel.h"
#import "CBIMessageParticipantsViewModel.h"
#import "EXTScope.h"
#import "MKNumberBadgeView+CanvasStyle.h"
#import "UIImage+TechDebt.h"

@interface CBIMessageComposeMessageCell ()
@property (weak, nonatomic) IBOutlet CBIResizableTextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *attachButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end

@implementation CBIMessageComposeMessageCell

- (void)awakeFromNib
{
    @weakify(self);
    
    [self.attachButton setImage:[[UIImage techDebtImageNamed:@"icon_attachment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.separatorInset = UIEdgeInsetsZero;

    RACChannelTo(self, messageTextView.text) = RACChannelTo(self, viewModel.currentTextEntry);
    
    RACSignal *validMessageSignal = [self.messageTextView.rac_textSignal map:^id(NSString *messageText) {
        NSString *trimmedString = [messageText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return @([trimmedString length] > 0);
    }];
    
    RACSignal *atLeastOneParticipantSignal = [[RACSignal combineLatest:@[[RACObserve(self, viewModel.model.participants) map:^id(NSArray *participants) {
        return @(participants.count > 0);
    }], [RACObserve(self, viewModel.participantsViewModel.pendingRecipients) map:^id(NSArray *pending) {
        return @(pending.count > 0);
    }]]] or];
    
    [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.sendButton.rac_command = [[RACCommand alloc] initWithEnabled:[[RACSignal combineLatest:@[atLeastOneParticipantSignal, validMessageSignal]] and] signalBlock:^(id input) {
        @strongify(self);
        [self.viewModel sendMessageFromTextView:self.messageTextView];
        return [RACSignal empty];
    }];
    
    RAC(self, height) = [self.messageTextView.viewHeightSignal map:^id(NSNumber *height) {
        return @(MIN(MAX([height floatValue], 33), 83) + 18);
    }];
        
    self.attachButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.viewModel addAttachmentsFromButton:self.attachButton];
        [self.messageTextView resignFirstResponder];
        
        return [RACSignal empty];
    }];
    
    MKNumberBadgeView *badge = [MKNumberBadgeView badgeViewForView:self.attachButton];
    badge.frame = CGRectOffset(badge.frame, -4, 6);
    [self.attachButton addSubview:badge];
    
    [RACObserve(self, viewModel.attachmentCount) subscribeNext:^(id x) {
        badge.value = [x intValue];
    }];
    

    
    [super awakeFromNib];
}

@end
