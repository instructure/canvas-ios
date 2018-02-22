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

#import "WebViewHacker.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <React/RCTUtils.h>

@interface _SwizzleHelper : NSObject
@end

@implementation _SwizzleHelper
-(id)inputAccessoryView
{
  return nil;
}
@end

@implementation WebViewHacker

RCT_EXPORT_MODULE();

// runtime trick to remove UIWebview keyboard default toolbar
// see: http://stackoverflow.com/questions/19033292/ios-7-uiwebview-keyboard-issue/19042279#19042279
RCT_EXPORT_METHOD(removeInputAccessoryView)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWebView *webView = [self webViewInView:RCTPresentedViewController().view];
    [self hideAccessoryView:webView];
  });
}

RCT_EXPORT_METHOD(setKeyboardDisplayRequiresUserAction:(BOOL)requiresUserAction)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWebView *webView = [self webViewInView:RCTPresentedViewController().view];
    webView.keyboardDisplayRequiresUserAction = requiresUserAction;
  });
}

- (UIWebView *)webViewInView:(UIView *)view {
  if ([view isKindOfClass:[UIWebView class]]) {
    return (UIWebView *)view;
  }

  for (UIView *subview in view.subviews) {
    UIWebView *webView = [self webViewInView:subview];
    if (webView) {
      return webView;
    }
  }

  return nil;
}

-(void)hideAccessoryView:(UIWebView *)webView
{
  UIView *subview;
  for (UIView *view in webView.scrollView.subviews) {
    if ([[view.class description] hasPrefix:@"UIWeb"])
      subview = view;
  }

  if (!subview) return;

  NSString *name = [NSString stringWithFormat:@"%@_SwizzleHelper", subview.class.superclass];
  Class newClass = NSClassFromString(name);

  if (!newClass) {
    newClass = objc_allocateClassPair(subview.class, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
    if (!newClass) return;

    Method method = class_getInstanceMethod([_SwizzleHelper class], @selector(inputAccessoryView));
    class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));

    objc_registerClassPair(newClass);
  }

  object_setClass(subview, newClass);
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
