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

#import "DrawerHandleViewManager.h"
#import <React/RCTBridge.h>
#import <React/RCTView.h>
#import "InteractableView.h"

@interface DrawerHandleView : RCTView
@property (nonatomic, weak) UIPanGestureRecognizer *hijackedPan;
@end

@implementation DrawerHandleViewManager
RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[DrawerHandleView alloc] init];
}

@end

@implementation DrawerHandleView

- (InteractableView *)interactableViewIn:(UIView *)view depth:(NSInteger)depth {
  
  if (depth > 4) {
    return nil;
  }
  
  if ([view isKindOfClass:[InteractableView class]]) {
    return (InteractableView *)view;
  }
  
  for (UIView *child in view.subviews) {
    InteractableView *i = [self interactableViewIn:child depth:depth + 1];
    if (i) { return i; }
  }
  
  return nil;
}

- (void)hijackThePanGestureRecognizer {
  id view = [self interactableViewIn:self.superview.superview.superview depth:0];
  
  UIPanGestureRecognizer *pan = [view valueForKeyPath:@"pan"];
  NSAssert([pan isKindOfClass:[UIPanGestureRecognizer class]], @"Expected InteractableView to have a pan property of type UIPanGestureRecognizer");
  
  self.hijackedPan = pan;
  [self addGestureRecognizer:pan];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (!self.hijackedPan) {
    [self hijackThePanGestureRecognizer];
  }
}

@end
