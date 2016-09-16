//
//  CBIModuleItemCell.m
//  iCanvas
//
//  Created by Derrick Hathaway on 3/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulModuleCell.h"
#import "CBIColorfulViewModel.h"
#import "EXTScope.h"
#import "UIImage+TechDebt.h"

@import SoPretty;

@interface CBIColorfulModuleCell ()
@property (nonatomic) UIImageView *highlightedStateIcon;
@property (nonatomic) UIImageView *stateIcon;
@end

@implementation CBIColorfulModuleCell

static UIImage *(^iconForStateBlock)(NSNumber *state) = ^UIImage *(NSNumber *state) {
    if (state == nil) {
        return nil;
    }
    
    UIImage *image;
    switch ([state integerValue]) {
        case CBIColorfulModuleViewModelStateCompleted:
            image = [UIImage techDebtImageNamed:@"icon_check_sm"];
            break;
        case CBIColorfulModuleViewModelStateLocked:
            image = [UIImage techDebtImageNamed:@"icon_locked_sm"];
            break;
        case CBIColorfulModuleViewModelStateIncomplete:
            image = [UIImage techDebtImageNamed:@"icon_circle_sm"];
            break;
        case CBIColorfulModuleViewModelStateUnlocked:
            image = [UIImage techDebtImageNamed:@"icon_unlocked_sm"];
            break;
    };
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
};

- (void)awakeFromNib
{
    [self setupStateIcons];

    @weakify(self);
    RAC(self, textLabel.textColor) = [[RACObserve(self, viewModel.lockedOut) map:^id(NSNumber *value) {
        return (value && [value boolValue]) ? [UIColor prettyGray] : [UIColor prettyBlack];
    }] doNext:^(id x) {
        @strongify(self);
        [self updateHighlight];
    }];
    RAC(self, tintColor) = [[RACSignal combineLatest:@[RACObserve(self, viewModel), RACObserve(self, viewModel.lockedOut)] reduce:^id(CBIColorfulViewModel<CBIColorfulModuleViewModel> *vm, NSNumber *locked) {
        @strongify(self);
        if (self.highlighted || self.selected) {
            return [UIColor whiteColor];
        }
        return (vm && vm.lockedOut) ? [UIColor prettyGray] : vm.tintColor;
    }] doNext:^(id x) {
        @strongify(self);
        [self updateHighlight];
    }];

    RACSignal *stateIcon = [RACObserve(self, viewModel.state) map:iconForStateBlock];
    RAC(self, stateIcon.image) = stateIcon;
    RAC(self, highlightedStateIcon.image) = stateIcon;

    [RACObserve(self, viewModel.selected) subscribeNext:^(NSNumber *selected) {
        if (selected) {
            [self setHighlighted:[selected boolValue] animated:NO];
            [self setSelected:[selected boolValue] animated:NO];
        }
    }];

    RAC(self, accessibilityLabel) = RACObserve(self, viewModel.accessibilityLabel);

    [super awakeFromNib];
}

- (void)updateHighlight
{
    [super updateHighlight];
    if (self.highlighted || self.selected) {
        self.tintColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
    }
    else {
        if (self.viewModel.lockedOut) {
            self.tintColor = [UIColor prettyGray];
            self.textLabel.textColor = [UIColor prettyGray];
        } else {
            self.tintColor = self.viewModel.tintColor;
            self.textLabel.textColor = [UIColor prettyBlack];
        }
        self.detailTextLabel.textColor = [UIColor prettyGray];
    }
}

- (void)setupStateIcons
{
    self.stateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    self.stateIcon.tintColor = [UIColor prettyGray];
    self.nonHighlightedAccessoryView = self.stateIcon;

    UIView *highlightedAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15 + 14 + 4, 34)];
    highlightedAccessory.autoresizingMask = 0;
    highlightedAccessory.backgroundColor = [UIColor clearColor];
    
    self.highlightedStateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, 15, 15)];
    self.highlightedStateIcon.tintColor = [UIColor whiteColor];
    [highlightedAccessory addSubview:self.highlightedStateIcon];
    
    UIImageView *right = [[UIImageView alloc] initWithImage:[[UIImage techDebtImageNamed:@"icon_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    right.contentMode = UIViewContentModeScaleAspectFill;
    right.frame = CGRectMake(19, 0, 14, 34);
    right.tintColor = [UIColor whiteColor];
    [highlightedAccessory addSubview:right];
    
    self.highlightedAccessoryView = highlightedAccessory;
}

@end
