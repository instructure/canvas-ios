//
//  NativeAccessibility.m
//  Teacher
//
//  Created by Layne Moseley on 5/15/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "NativeAccessibility.h"
#import <UIKit/UIKit.h>

@implementation NativeAccessibility

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(focusElement:(NSString *)identifier)
{
  UIView *element = [self subviewWithIdentifier:identifier];
  if (element) {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, element);
  }
}

- (nullable UIView *)subviewWithIdentifier:(NSString *)identifier {
  NSArray<UIWindow *> *windows = [[UIApplication sharedApplication] windows];
  for (UIWindow *window in windows) {
    UIView *view = [self subviewWithIdentifier:identifier inSuperview:window];
    if (view) {
      return view;
    }
  }
  
  return nil;
}

- (nullable UIView *)subviewWithIdentifier:(NSString *)identifier inSuperview:(UIView *)superview {
  for (UIView *subview in superview.subviews) {
    if ([subview.accessibilityIdentifier isEqualToString:identifier]) {
      return subview;
    }
    
    UIView *view = [self subviewWithIdentifier:identifier inSuperview:subview];
    if (view) {
      return view;
    }
  }
  
  return nil;
}

@end
