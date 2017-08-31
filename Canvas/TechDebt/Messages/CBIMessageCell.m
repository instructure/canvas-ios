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
    
    

#import "CBIMessageCell.h"
#import "CBIMessageViewModel.h"

@import SoPretty;


@interface CBIMessageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *discloserIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadIndicatorHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@end


@implementation CBIMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.unreadImageView.image = [self.unreadImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.attachmentImageView.image = [self.attachmentImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.discloserIndicator.image = [self.discloserIndicator.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.discloserIndicator.tintColor = [UIColor prettyOffWhite];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor prettyOffWhite];
    self.backgroundView = backgroundView;
    
    UIView *selectionHighlight = [UIView new];
    selectionHighlight.backgroundColor = [UIColor prettyGray];
    self.selectedBackgroundView = selectionHighlight;
    
    RAC(self, dateLabel.text) = [RACObserve(self, viewModel.date) map:^id(id value) {
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
        });
        return [dateFormatter stringFromDate:value];
    }];
    RAC(self, senderLabel.text) = RACObserve(self, viewModel.sender);
    RAC(self, subjectLabel.text) = RACObserve(self, viewModel.subject);
    RAC(self, previewLabel.text) = RACObserve(self, viewModel.messagePreview);
    RACSignal *unreadImageShown = [RACObserve(self, viewModel.isUnread) map:^id(id value) {
        return value ?: @NO;
    }];
    RAC(self, unreadIndicatorHeightConstraint.constant) = [unreadImageShown map:^(NSNumber *shown) {
        return @([shown boolValue] ? 16.f : 0.f);
    }];
    RAC(self, unreadImageView.hidden) = [unreadImageShown not];
    RAC(self, attachmentImageView.hidden) = [[RACObserve(self, viewModel.hasAttachment) map:^id(id value) {
        return value ?: @NO;
    }] not];
}


- (void)updateHighlightAnimated:(BOOL)animated
{
    UIColor *gray, *black, *background;
    if (self.highlighted || self.selected) {
        gray = [UIColor prettyOffWhite];
        black = [UIColor prettyOffWhite];
        background = [UIColor prettyGray];
    } else {
        gray = [UIColor prettyGray];
        black = [UIColor prettyBlack];
        background = [UIColor prettyOffWhite];
    }

    self.discloserIndicator.hidden = self.editing;
    
    void (^block)() = ^{
        self.tintColor = gray;
        self.attachmentImageView.tintColor = gray;
        self.dateLabel.textColor = gray;
        self.subjectLabel.textColor = black;
        self.senderLabel.textColor = black;
        self.previewLabel.textColor = gray;
        self.backgroundColor = background;
        self.contentView.backgroundColor = background;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:block];
    } else {
        block();
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self updateHighlightAnimated:animated];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateHighlightAnimated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self updateHighlightAnimated:animated];
}

@end
