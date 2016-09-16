
//
//  CBITabCell.m
//  iCanvas
//
//  Created by derrick on 10/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulCell.h"
#import "CBIColorfulViewModel.h"

#import "EXTScope.h"
#import "UIView+Circular.h"
#import "UIImage+TechDebt.h"

@import SoPretty;

@interface CBIColorfulCell ()
@property (nonatomic) UIColor *courseTintColor;
@property (nonatomic) RACDisposable *imageUpdateObservation;
@end

@implementation CBIColorfulCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    @weakify(self);
    if (self.highlightedAccessoryView == nil) {
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[[UIImage techDebtImageNamed:@"icon_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        disclosure.frame = CGRectMake(0, 0, 14, disclosure.frame.size.height);
        disclosure.contentMode = UIViewContentModeScaleAspectFill;
        disclosure.tintColor = [UIColor whiteColor];
        self.highlightedAccessoryView = disclosure;
    }
    
    RAC(self, courseTintColor) = RACObserve(self, viewModel.tintColor);
    
    if (self.customIcon || self.customTitleLabel || self.customDetailLabel) {
        RAC(self, customDetailLabel.text) = RACObserve(self, viewModel.detail);
        RAC(self, customTitleLabel.text) = RACObserve(self, viewModel.name);
        RAC(self, customIcon.image) = RACObserve(self, viewModel.icon);
    } else {
        RAC(self, detailTextLabel.text) = RACObserve(self, viewModel.subtitle);
        RAC(self, textLabel.text) = RACObserve(self, viewModel.name);
        RAC(self, imageView.image) = RACObserve(self, viewModel.icon);
        
        self.imageUpdateObservation = [[[RACSignal combineLatest:@[RACObserve(self, viewModel.icon), RACObserve(self, viewModel.name)]] subscribeNext:^(id x) {
            @strongify(self);
            [self updateHighlight];
        }] asScopedDisposable];
    }
    
    self.selectedBackgroundView = [UIView new];
    RAC(self, selectedBackgroundView.backgroundColor) = RACObserve(self, viewModel.tintColor);
    
    self.accessoryView = self.nonHighlightedAccessoryView;
}

- (void)setCourseTintColor:(UIColor *)courseTintColor
{
    _courseTintColor = courseTintColor;
    [self updateHighlight];
}

- (void)updateHighlight
{
    if (self.highlighted || self.selected) {
        self.tintColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.customTitleLabel.textColor = [UIColor whiteColor];
        self.customDetailLabel.textColor = [UIColor whiteColor];
        self.accessoryView = self.highlightedAccessoryView;
    }
    else {
        self.tintColor = self.courseTintColor;
        self.textLabel.textColor = [UIColor prettyBlack];
        self.detailTextLabel.textColor = [UIColor prettyGray];
        self.customTitleLabel.textColor = [UIColor prettyBlack];
        self.customDetailLabel.textColor = [UIColor prettyGray];
        self.accessoryView = self.nonHighlightedAccessoryView;
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

- (void)setRoundIcon:(BOOL)roundIcon
{
    if (roundIcon) {
        [self.customIcon makeViewCircular];
        [self.imageView makeViewCircular];
    }
    else {
        [self.customIcon makeViewRectangular];
        [self.imageView makeViewCircular];
    }
}

@end
