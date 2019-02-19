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
    
    

#import "CBIAddSubmissionCommentCell.h"
#import "CBIResizableTextView.h"
#import "CBIAddSubmissionCommentViewModel.h"

@interface CBIAddSubmissionCommentCell () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (nonatomic) BOOL typingTextComment;
@property (nonatomic) NSString *comment;
@end

@implementation CBIAddSubmissionCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    RACSignal *hasText = [RACObserve(self, comment) map:^(NSString *comment) {
        return @(comment.length > 0);
    }];
    
    RACSignal *isPostingComment = [RACObserve(self, viewModel.isPostingComment) map:^id(id value) {
        if(value) {
            return @([value boolValue]);
        }
        
        return @(NO);
    }];
    
    [isPostingComment subscribeNext:^(id x) {
        if ([x isEqual: @(YES)]) {
            self.activityIndicator.hidden = NO;
            self.sendButton.hidden = YES;
            [self.activityIndicator startAnimating];
        } else {
            self.activityIndicator.hidden = YES;
            self.sendButton.hidden = NO;
            [self.activityIndicator stopAnimating];
        }
    }];
    
    RACSignal *mediaCommentsNotAllowed = [RACObserve(self, viewModel.allowMediaComments) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    RACSignal *showSendButton = [[RACSignal combineLatest:@[RACObserve(self, typingTextComment), hasText, mediaCommentsNotAllowed]] or];
    
    RAC(self, attachButton.hidden) = showSendButton;
    RAC(self, sendButton.hidden) = [showSendButton map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    RAC(self, sendButton.enabled) = hasText;

    [self rac_liftSelector:@selector(updateHeightWithTextViewHeight:) withSignals:self.resizeableTextView.viewHeightSignal, nil];
    
    [self.attachButton setImage:[[self.attachButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)updateHeightWithTextViewHeight:(CGFloat)height {
    height = MAX(50, MIN(height, 72));
    
    if (height != self.textViewHeightConstraint.constant) {
        self.textViewHeightConstraint.constant = height;
        [self setNeedsLayout];
        self.height = height + 9 + 9;
    }
}

#pragma mark - textview delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.typingTextComment = YES;
    if (textView.text.length == 0) {
        self.sendButton.enabled = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.typingTextComment = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.comment = textView.text;
}

@end
