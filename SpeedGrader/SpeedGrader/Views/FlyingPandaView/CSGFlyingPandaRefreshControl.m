//
//  CSGFlyingPandaRefreshControl.m
//  SpeedGrader
//
//  Created by Ben Kraus on 12/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGFlyingPandaRefreshControl.h"

static CGFloat const kDropHeight = 120.0f;

typedef NS_ENUM(NSInteger, CSGFlyingPandaRefreshControlState) {
    CSGFlyingPandaRefreshControlStateInitial,
    CSGFlyingPandaRefreshControlStateIdle,
    CSGFlyingPandaRefreshControlStateFinishedDragging,
    CSGFlyingPandaRefreshControlStateRefreshing,
    CSGFlyingPandaRefreshControlStateDisappearing
};

@interface CSGFlyingPandaRefreshControl ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, assign) CSGFlyingPandaRefreshControlState state;
@property (nonatomic, assign) CGFloat originalTopContentInset;

@property (nonatomic, strong) NSLayoutConstraint *pandaLeftConstraint;

@end

@implementation CSGFlyingPandaRefreshControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView target:(id)target action:(SEL)action
{
    self = [super initWithFrame:CGRectMake(0.0f, -kDropHeight, scrollView.bounds.size.width, kDropHeight)];
    if (self) {
        _scrollView = scrollView;
        _target = target;
        _action = action;
        
        _state = CSGFlyingPandaRefreshControlStateInitial;

        self.flyingPandaImageView.image = [UIImage imageNamed:@"panda_1"];
        _pandaLeftConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.flyingPandaImageView.image.size.width];

        // I really really really hate hard coding 64, 20 for the status bar and 44 for the nav bar.
        // BUT, the top layout guide wasn't adjusting the contentInset of the scrollView until later
        // in the game, and I couldn't figure out how to calculate that before, at the right time.
        _originalTopContentInset = 64.0f;
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];

    NSLayoutConstraint *verticalPandaConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self addConstraints:@[verticalPandaConstraint, self.pandaLeftConstraint]];
}

- (void)scrollViewDidScroll
{
    if (self.originalTopContentInset == 0) {
        self.originalTopContentInset = self.scrollView.contentInset.top;
    }

    if (self.state != CSGFlyingPandaRefreshControlStateDisappearing) {
        if (self.state == CSGFlyingPandaRefreshControlStateRefreshing) {
            if (self.scrollView.contentOffset.y >= -self.originalTopContentInset) {
                self.scrollView.contentInset = UIEdgeInsetsMake(self.originalTopContentInset, 0, 0, 0);
            } else {
                self.scrollView.contentInset = UIEdgeInsetsMake(MIN(-self.scrollView.contentOffset.y, kDropHeight+self.originalTopContentInset), 0, 0, 0);
            }
        }

        if (self.state != CSGFlyingPandaRefreshControlStateRefreshing) {
            CGFloat percentage = self.state == CSGFlyingPandaRefreshControlStateInitial ? 1.0f : self.animationProgress;
            CGFloat pandaX = percentage * (self.scrollView.bounds.size.width / 2.0f - self.flyingPandaImageView.image.size.width / 2.0f);
            self.pandaLeftConstraint.constant = pandaX;
            [self setNeedsUpdateConstraints];
            [self layoutIfNeeded];
        }
    }
}

- (void)scrollViewDidEndDragging
{
    if ([self realContentOffsetY] < -kDropHeight && self.animationProgress == 1) {
        self.state = CSGFlyingPandaRefreshControlStateFinishedDragging;
        [self startLoading];
    }
}

- (void)startLoading
{
    if (self.state == CSGFlyingPandaRefreshControlStateInitial || self.state == CSGFlyingPandaRefreshControlStateIdle || self.state == CSGFlyingPandaRefreshControlStateFinishedDragging) {
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top = self.originalTopContentInset + kDropHeight;
        if (self.state == CSGFlyingPandaRefreshControlStateInitial) {
            newInsets.top = kDropHeight;
        }
        CGPoint contentOffset = self.scrollView.contentOffset; // even though we don't change the value... this is fixing a weird jittery jumpy issue

        [UIView animateWithDuration:0 animations:^{
            self.scrollView.contentInset = newInsets;
            if (self.state == CSGFlyingPandaRefreshControlStateFinishedDragging) {
                self.scrollView.contentOffset = contentOffset;
            } else {
                self.scrollView.contentOffset = CGPointMake(0, -newInsets.top);
            }
        }];

        self.state = CSGFlyingPandaRefreshControlStateRefreshing;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

        if ([self.target respondsToSelector:self.action]) {
            [self.target performSelector:self.action withObject:self];
        }

#pragma clang diagnostic pop

        [self startAnimating];
    }
}

- (void)finishLoading
{
    self.state = CSGFlyingPandaRefreshControlStateDisappearing;
    UIEdgeInsets newInsets = self.scrollView.contentInset;
    newInsets.top = self.originalTopContentInset;

    self.pandaLeftConstraint.constant = self.scrollView.bounds.size.width;
    [self setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8f animations:^{
            self.scrollView.contentInset = newInsets;
        } completion:^(BOOL finished) {
            self.state = CSGFlyingPandaRefreshControlStateIdle;
            [self stopAnimating];
        }];
    }];


}


#pragma mark - Private helpers

- (CGFloat)animationProgress
{
    return MIN(1.f, MAX(0, fabsf(@(self.realContentOffsetY).floatValue)/kDropHeight));
}

- (CGFloat)realContentOffsetY
{
    return self.scrollView.contentOffset.y + self.originalTopContentInset;
}

@end
