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

RCT_EXPORT_METHOD(refresh)
{
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
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

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
