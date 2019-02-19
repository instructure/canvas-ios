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
    
    

#import "CBISubmissionCell.h"
#import "CBISubmissionViewModel.h"
@import CanvasCore;

@interface CBISubmissionCell ()
@property (nonatomic) UIColor *courseTintColor;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIView *submissionBackgroundView;
@end

@implementation CBISubmissionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    RAC(self, courseTintColor) = RACObserve(self, viewModel.tintColor);
    RAC(self, titleLabel.text) = RACObserve(self, viewModel.name);
    RAC(self, dateLabel.text) = RACObserve(self, viewModel.subtitle);
    RAC(self, icon.image) = RACObserve(self, viewModel.icon);
    RAC(self, gradeLabel.text) = [RACObserve(self, viewModel.model.score) map:^id(id value) {
        return [value description];
    }];

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor prettyLightGray];
    self.backgroundView = backgroundView;
}

- (void)updateHighlight
{
    if (self.highlighted || self.selected) {
        self.tintColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.gradeLabel.textColor = [UIColor whiteColor];
        self.submissionBackgroundView.backgroundColor = self.courseTintColor;
    }
    else {
        self.tintColor = self.courseTintColor;
        self.titleLabel.textColor = [UIColor blackColor];
        self.dateLabel.textColor = [UIColor blackColor];
        self.gradeLabel.textColor = [UIColor blackColor];
        self.submissionBackgroundView.backgroundColor = [UIColor whiteColor];
    }
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
