//
//  DrawerHandleViewManager.m
//  Teacher
//
//  Created by Derrick Hathaway on 5/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
