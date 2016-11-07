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
    
    

#import "ShortPressGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation ShortPressGestureRecognizer {
    CGPoint initialPosition;
    NSTimer *cancellationTimer;
    NSTimer *startTimer;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touches.count > 1) {
        self.state = UIGestureRecognizerStateFailed;
    }
    else {
        self.state = UIGestureRecognizerStatePossible;
        
        initialPosition = [self locationInView:self.view];
        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(startRecognition:)
                                                    userInfo:nil
                                                     repeats:NO];
        cancellationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(cancelRecognition:)
                                               userInfo:nil
                                                repeats:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGPoint position = [self locationInView:self.view];
    CGFloat distance = hypot(position.x - initialPosition.x,
                             position.y - initialPosition.y);
    if (distance > 10) {
        self.state = UIGestureRecognizerStateCancelled;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
    [cancellationTimer invalidate];
    [startTimer invalidate];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateBegan) {
        self.state = UIGestureRecognizerStateCancelled;
    }
    [cancellationTimer invalidate];
    [startTimer invalidate];
}

- (void)cancelRecognition:(NSTimer *)timer {
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)startRecognition:(NSTimer *)timer {
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)reset {
    [super reset];
    [startTimer invalidate];
    [cancellationTimer invalidate];
}

@end
