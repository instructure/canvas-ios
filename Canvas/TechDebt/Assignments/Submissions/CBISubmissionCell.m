//
//  CBISubmissionCell.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISubmissionCell.h"
#import "CBISubmissionViewModel.h"
@import SoPretty;

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
