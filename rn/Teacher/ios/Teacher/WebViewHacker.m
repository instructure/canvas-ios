//
//  WebViewHacker.m
//  Teacher
//
//  Created by Nathan Armstrong on 4/11/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
  UIWebView *webView = [self webViewInView:RCTPresentedViewController().view];
  [self hideAccessoryView:webView];
}

RCT_EXPORT_METHOD(setKeyboardDisplayRequiresUserAction:(BOOL)requiresUserAction)
{
  UIWebView *webView = [self webViewInView:RCTPresentedViewController().view];
  webView.keyboardDisplayRequiresUserAction = requiresUserAction;
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

@end
