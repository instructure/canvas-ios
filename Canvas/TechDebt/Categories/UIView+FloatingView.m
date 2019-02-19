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
    
    

#import "UIView+FloatingView.h"

@implementation UIView (FloatingView)

- (void)floatIntoWindow {
    if (self.superview == self.window) {
        return;
    }
    
    CGRect newFrame = [self.superview convertRect:self.frame toView:nil];
    [self.window addSubview:self];
    self.transform = [self transformForCurrentInterfaceOrientation];
    self.frame = newFrame;
}

- (void)floatIntoView:(UIView *)newView belowSubview:(UIView *)sibling {
    if (self.superview == newView) {
        return;
    }
    
    UIView *newSuperview = (newView ?: self.window);
    
    CGRect newFrame = [self.superview convertRect:self.frame toView:newSuperview];
    self.frame = newFrame;
    if (sibling == nil) {
        [newSuperview addSubview:self];
    }
    else {
        [newSuperview insertSubview:self belowSubview:sibling];
    }
    
    if (newView == nil) {
        self.transform = [self transformForCurrentInterfaceOrientation];
    }
    else {
        self.transform = newSuperview.transform;
    }
}

- (void)unfloatIntoView:(UIView *)newSuperview {
    if (self.superview == newSuperview) {
        return;
    }
    
    CGRect newFrame = [newSuperview convertRect:self.frame fromView:nil];
    [newSuperview addSubview:self];
    self.transform = newSuperview.transform;
    self.frame = newFrame;
}

- (CGAffineTransform)transformForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGAffineTransformIdentity;
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-M_PI_2);
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
        default:
            return CGAffineTransformIdentity;
    }
}

- (CGAffineTransform)transformForCurrentInterfaceOrientation {
    return [self transformForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

@end
