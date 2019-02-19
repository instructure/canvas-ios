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
        _frontImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        isAnimatingCurrentFrame = NO;
        _currentFrame = nextFrame;
        
        UIImageView *tmp = _backImageView;
        _backImageView = _frontImageView;
        _frontImageView = tmp;
        [self bringSubviewToFront:_frontImageView];
        
        if (_isAnimating) {
            [self runNextAnimationFrame];
        }
     }];
}

@end
