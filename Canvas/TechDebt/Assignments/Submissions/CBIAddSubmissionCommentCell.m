//
//  CBIAddSubmissionCommentCell.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
