//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

#import "CSGFlyingPandaRefreshControl.h"
#import <objc/runtime.h>

static CGFloat const kDropHeight = 120.0f;

typedef NS_ENUM(NSInteger, CSGFlyingPandaRefreshControlState) {
    CSGFlyingPandaRefreshControlStateInitial,
    CSGFlyingPandaRefreshControlStateIdle,
    CSGFlyingPandaRefreshControlStateFinishedDragging,
    CSGFlyingPandaRefreshControlStateRefreshing,
    CSGFlyingPandaRefreshControlStateDisappearing
};

@interface CSGFlyingPandaRefreshControl ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, assign) CSGFlyingPandaRefreshControlState state;
@property (nonatomic, strong) NSLayoutConstraint *pandaLeftConstraint;

@end

@implementation CSGFlyingPandaRefreshControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectMake(0.0f, -kDropHeight, scrollView.bounds.size.width, kDropHeight)];
    if (self) {
        _scrollView = scrollView;
        
        _state = CSGFlyingPandaRefreshControlStateInitial;

        self.flyingPandaImageView.image = [UIImage imageNamed:@"panda_1"];
        _pandaLeftConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.flyingPandaImageView.image.size.width];
    }
    return self;
}

- (void)setTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)setOriginalTopContentInset:(CGFloat)originalTopContentInset {
    _originalTopContentInset = originalTopContentInset;
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = _originalTopContentInset;
    if (self.state == CSGFlyingPandaRefreshControlStateRefreshing) {
        contentInset.top += kDropHeight;
    }
    
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
}

- (void)setToIdle {
    // if this was user triggered, aka it's already refreshing, ignore
    if (self.state != CSGFlyingPandaRefreshControlStateRefreshing) {
        [self stopAnimating];
        self.state = CSGFlyingPandaRefreshControlStateIdle;
    }
}

- (void)updateConstraints {
    [super updateConstraints];

    if (self.constraints.count == 0) {
        NSLayoutConstraint *verticalPandaConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
        [self addConstraints:@[verticalPandaConstraint, self.pandaLeftConstraint]];
    }
}

- (void)updateFrame {
    self.frame = CGRectMake(0.0f, -kDropHeight, self.scrollView.bounds.size.width, kDropHeight);
}

- (void)scrollViewDidScroll {
    if (self.scrollView.contentOffset.y < -1*_originalTopContentInset){
        self.hidden = NO;
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
            self.flyingPandaImageView.image = imageNamed(@"panda_1");
            [self setNeedsUpdateConstraints];
            [self layoutIfNeeded];
        }
    }
}

- (void)scrollViewDidEndDragging {
    if ([self realContentOffsetY] < -kDropHeight && self.animationProgress == 1) {
        self.state = CSGFlyingPandaRefreshControlStateFinishedDragging;
        [self startLoading:YES];
    }
}

- (void)startLoading:(BOOL)invokeTarget {
    if (self.state == CSGFlyingPandaRefreshControlStateInitial || self.state == CSGFlyingPandaRefreshControlStateIdle || self.state == CSGFlyingPandaRefreshControlStateFinishedDragging) {
        self.hidden = NO;
        [self updateConstraints];

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

        // safer.. no leaks
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        if (invokeTarget && self.target != nil){
            IMP imp = [self.target methodForSelector:self.action];
            void (*func)(id, SEL, id) = (void *)imp;
            func(self.target, self.action, self);
        }
        
        CGFloat pandaX = (self.scrollView.bounds.size.width / 2.0f - self.flyingPandaImageView.image.size.width / 2.0f);
        self.pandaLeftConstraint.constant = pandaX;
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
        [self startAnimating];
    }
}

- (void)finishLoadingWithCompletion:(void (^)())completion {
    BOOL runCompletion = completion != nil;
    
    if (self.state != CSGFlyingPandaRefreshControlStateDisappearing && self.pandaLeftConstraint.constant > 0){
        self.state = CSGFlyingPandaRefreshControlStateDisappearing;
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top = self.originalTopContentInset;
        
        self.pandaLeftConstraint.constant = self.scrollView.bounds.size.width;
        [self setNeedsUpdateConstraints];
        
        
        
        CGFloat duration = (runCompletion) ? 0.2f : 0.6f;
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.8f animations:^{
                self.scrollView.contentInset = newInsets;
            } completion:^(BOOL finished) {
                self.state = CSGFlyingPandaRefreshControlStateIdle;
                self.hidden = YES;
                [self stopAnimating];
                if (runCompletion) {
                    completion();
                }
            }];
        }];
    } else {
        if (runCompletion) {
            completion();
        }
    }
}

- (void)finishLoading
{
    [self finishLoadingWithCompletion:nil];
}


#pragma mark - Private helpers

- (CGFloat)animationProgress {
    return MIN(1.f, MAX(0, fabs(self.realContentOffsetY)/kDropHeight));
}

- (CGFloat)realContentOffsetY {
    return self.scrollView.contentOffset.y + self.originalTopContentInset;
}

@end
