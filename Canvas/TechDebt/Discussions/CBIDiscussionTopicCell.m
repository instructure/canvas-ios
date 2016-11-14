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
    
    

#import "CBIDiscussionTopicCell.h"
#import "CBIColorfulBadgeView.h"
#import "CBIDiscussionTopicViewModel.h"
@import SoPretty;
#import "UIImage+TechDebt.h"


@interface CBIDiscussionTopicCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet CBIColorfulBadgeView *badgeView;
@property (nonatomic) UIColor *courseTintColor;
@end

@implementation CBIDiscussionTopicCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImageView *disclosure = [[UIImageView alloc] initWithImage:[[UIImage techDebtImageNamed:@"icon_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    disclosure.tintColor = [UIColor whiteColor];
    self.accessoryView = disclosure;
    
    RAC(self, titleLabel.text) = RACObserve(self, viewModel.name);
    RAC(self, subtitleLabel.text) = RACObserve(self, viewModel.subtitle);
    RAC(self, badgeView.numberLabel.text) = [RACObserve(self, viewModel.model.unreadCount) map:^(NSNumber *number) {
        if ([number integerValue] > 98) {
            return @"99+";
        } if ([number integerValue] < 0) {
            return @"";
        }
        return [number description];
    }];
    RAC(self, badgeView.hidden) = [RACObserve(self, viewModel.model.unreadCount) map:^(NSNumber  *count) {
        return @([count integerValue] <= 0);
    }];
    RAC(self, courseTintColor) = RACObserve(self, viewModel.tintColor);
    self.selectedBackgroundView = [UIView new];
    RAC(self, selectedBackgroundView.backgroundColor) = RACObserve(self, viewModel.tintColor);
}

- (void)updateHighlight
{
    BOOL highlight = (self.selected || self.highlighted);
    UIColor *white = [UIColor whiteColor];
    self.titleLabel.textColor = highlight ? white : [UIColor prettyBlack];
    self.subtitleLabel.textColor = highlight ? white : [UIColor prettyGray];
    self.badgeView.backgroundColor = highlight ? white : self.courseTintColor;
    self.badgeView.numberLabel.textColor = highlight ? self.courseTintColor : white;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self updateHighlight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self updateHighlight];
}

@end
