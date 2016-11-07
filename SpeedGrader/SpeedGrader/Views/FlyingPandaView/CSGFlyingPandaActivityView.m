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

#import "CSGFlyingPandaActivityView.h"
#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaActivityView ()

@end

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
