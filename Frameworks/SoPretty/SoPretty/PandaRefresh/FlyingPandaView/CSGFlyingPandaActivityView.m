
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
    
    

#import "CSGFlyingPandaActivityView.h"
#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaActivityView ()

@end

UIColor* RGB(CGFloat red, CGFloat green, CGFloat blue){
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@implementation CSGFlyingPandaActivityView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    
    self.backgroundColor = RGB(110, 202, 255);
    self.layer.cornerRadius = 10.0;
    self.clipsToBounds = YES;
    self.alpha = 0;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    NSLayoutConstraint *horizontalPandaConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *verticalPandaConstraint = [NSLayoutConstraint constraintWithItem:self.flyingPandaImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self addConstraints:@[horizontalPandaConstraint, verticalPandaConstraint]];
}

- (void)show
{
    [self startAnimating];
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformScale(self.transform, 1.f/1.3f, 1.f/1.3f);
        self.alpha = 1.0f;
    } completion:nil];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformScale(self.transform, 0.8f, 0.8f);
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
        [self stopAnimating];
    }];
}

@end
