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

#import "CSGVideoSlider.h"

@implementation CSGVideoSlider

- (id)init {
    if ((self = [super init])) {
        [self setupView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupView];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, .5, .5)];
    
    [self.strokeColor setStroke];
    [path stroke];
    
    CGRect barRect = CGRectInset(self.bounds, 2., 2.);
    CGFloat barWidth = barRect.size.width;
    
    float length = self.maximumValue - self.minimumValue;
    float lenghtValue = self.value - self.minimumValue;
    float percent = lenghtValue / length;
    
    CGFloat width = percent*barWidth;
    
    path = [UIBezierPath bezierPathWithRect:CGRectMake(barRect.origin.x, barRect.origin.y, width, barRect.size.height)];
    
    [self.fillColor setFill];
    [path fill];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL returnValue = [super beginTrackingWithTouch:touch withEvent:event];
    
    [self setValue:[self valueFromTouch:touch]];
    
    if (self.continuous)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return returnValue;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL returnValue = [super continueTrackingWithTouch:touch withEvent:event];
    
    [self setValue:[self valueFromTouch:touch]];
    
    if (self.continuous)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return returnValue;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self setValue:[self valueFromTouch:touch]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (void)setValue:(float)value {
    if (value > self.maximumValue) {
        value = self.maximumValue;
    }
    
    if (value < self.minimumValue) {
        value = self.minimumValue;
    }
    
    _value = value;
    
    [self setNeedsDisplay];
}

- (UIColor *)strokeColor {
    if (!_strokeColor)
        _strokeColor = [UIColor whiteColor];
    return _strokeColor;
}

- (UIColor *)fillColor {
    if (!_fillColor)
        _fillColor = [UIColor whiteColor];
    return _fillColor;
}

#pragma mark - Private

- (void)setupView {
    [self setMinimumValue:0.];
    [self setMaximumValue:1.];
    [self setValue:.5];
    
    [self setContinuous:YES];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

- (float)valueFromTouch:(UITouch *)touch {
    // Border inset
    CGFloat x = [touch locationInView:self].x-2;
    CGFloat width = self.bounds.size.width-4.;
    CGFloat percent = x / width;
    
    float length = self.maximumValue - self.minimumValue;
    
    return percent*length;
}

@end
