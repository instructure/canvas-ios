//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKCrossfadingImageView.h"

@implementation CKCrossfadingImageView {
    UIImageView *_frontImageView;
    UIImageView *_backImageView;
    
    BOOL _isAnimating;
    BOOL _isVisible;
    BOOL isAnimatingCurrentFrame;
    
    NSUInteger _currentFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _frontImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_backImageView];
        [self addSubview:_frontImageView];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window == nil) {
        _isVisible = NO;
    }
    else {
        _isVisible = YES;
        [self runNextAnimationFrame];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    _frontImageView.contentMode = contentMode;
    _backImageView.contentMode = contentMode;
}

- (UIViewContentMode)contentMode {
    return _frontImageView.contentMode;
}

- (void)startAnimating {
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    
    _currentFrame = 0;
    [self runNextAnimationFrame];
}

- (void)stopAnimating {
    if (!_isAnimating) {
        return;
    }
    _isAnimating = NO;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (void)runNextAnimationFrame {
    if (!_isAnimating || !_isVisible || isAnimatingCurrentFrame) {
        return;
    }
    int nextFrame = (_currentFrame + 1) % ((int)self.animationImages.count);
    
    _frontImageView.image = (self.animationImages)[_currentFrame];
    _backImageView.image = (self.animationImages)[nextFrame];
    
    CFTimeInterval frameInterval = self.animationDuration / self.animationImages.count;
    
    _frontImageView.alpha = 1.0;
    _backImageView.alpha = 1.0;
    
    isAnimatingCurrentFrame = YES;
    [UIView animateWithDuration:frameInterval animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self->_frontImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self->isAnimatingCurrentFrame = NO;
        self->_currentFrame = nextFrame;
        
        UIImageView *tmp = self->_backImageView;
        self->_backImageView = self->_frontImageView;
        self->_frontImageView = tmp;
        [self bringSubviewToFront:self->_frontImageView];
        
        if (self->_isAnimating) {
            [self runNextAnimationFrame];
        }
     }];
}

@end
