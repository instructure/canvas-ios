//
//  CanvasWebViewContainer.m
//  CanvasCore
//
//  Created by Nate Armstrong on 2/26/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//


#import "CanvasWebViewContainer.h"
#import <React/RCTComponent.h>
#import <React/RCTAutoInsetsProtocol.h>
#import <UIKit/UIKit.h>
#import <CanvasCore/CanvasCore-Swift.h>

#import <objc/runtime.h>

static NSString *WebViewKeyPath = @"webView.scrollView.contentSize";

// runtime trick to remove WKWebView keyboard default toolbar
// see: http://stackoverflow.com/questions/19033292/ios-7-uiwebview-keyboard-issue/19042279#19042279
@interface _SwizzleHelperWK : NSObject @end
@implementation _SwizzleHelperWK
-(id)inputAccessoryView
{
  return nil;
}
@end

@interface CanvasWebViewContainer () <RCTAutoInsetsProtocol>

@property (nonatomic, copy) RCTDirectEventBlock onNavigation;
@property (nonatomic, copy) RCTDirectEventBlock onFinishedLoading;
@property (nonatomic, copy) RCTDirectEventBlock onMessage;
@property (nonatomic, copy) RCTDirectEventBlock onError;
@property (nonatomic, copy) RCTDirectEventBlock onHeightChange;

@property (nonatomic, assign) CGSize contentSize;

@end

@implementation CanvasWebViewContainer
{
    CanvasWebView *_webView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        _automaticallyAdjustContentInsets = NO;
        _contentInset = UIEdgeInsetsZero;
        _webView = [CanvasWebView new];
        _webView.frame = self.bounds;
        self.contentSize = CGSizeZero;
        
        @weakify(self);
        _webView.finishedLoading = ^{
            @strongify(self);
            if (self.onFinishedLoading) {
                self.onFinishedLoading(@{});
            }
        };
        
        _webView.onMessage = ^(NSDictionary<NSString *,id> * _Nonnull message) {
            @strongify(self);
            if (self.onMessage) {
                self.onMessage(message);
            }
        };
        
        _webView.onHeightChange = ^(NSDictionary<NSString *,id> * _Nonnull message) {
            @strongify(self);
            if (self.onHeightChange) {
                self.onHeightChange(message);
            }
        };
        
        _webView.onError = ^(NSError * _Nonnull error) {
            @strongify(self);
            if (self.onError) {
                self.onError(@{@"error": error.localizedDescription});
            }
        };
        
        // Needs a presenting view controller
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
            while (rootViewController.presentedViewController) {
                rootViewController = rootViewController.presentedViewController;
            }
            _webView.presentingViewController = rootViewController;
        });

        [self addSubview:_webView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _webView.frame = self.bounds;
}

- (void)refreshContentInset
{
  [RCTView autoAdjustInsetsForView:self
                    withScrollView:_webView.scrollView
                      updateOffset:YES];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
  _contentInset = contentInset;
  [RCTView autoAdjustInsetsForView:self
                    withScrollView:_webView.scrollView
                      updateOffset:NO];
}

- (void)setSource:(NSDictionary *)source
{
    if (![_source isEqualToDictionary:source]) {
        _source = [source copy];

        // Check for a static html source first
        NSString *html = [RCTConvert NSString:source[@"html"]];
        if ([html isKindOfClass:[NSString class]]) {
            NSURL *baseURL = [RCTConvert NSURL:source[@"baseURL"]];
            if (![baseURL isKindOfClass:[NSURL class]]) {
                baseURL = [NSURL URLWithString:@"about:blank"];
            }
            @weakify(self);
            [_webView loadWithHtml:html title:nil baseURL:baseURL routeToURL:^(NSURL * _Nonnull url) {
                @strongify(self);
                if (self.onNavigation) {
                    self.onNavigation(@{@"url": url.absoluteString});
                }
            }];
            return;
        }
        
        NSURLRequest *request = [RCTConvert NSURLRequest:source];
        if (!request.URL) {
            // Clear the webview
            [_webView loadHTMLString:@"" baseURL:nil];
            return;
        }

        // Must use loadFileURL:allowingReadAccessToURL: to load file urls in WKWebView
        // See: https://stackoverflow.com/questions/24882834/wkwebview-not-loading-local-files-under-ios-8
        if (request.URL.isFileURL) {
            [_webView loadFileURL:request.URL allowingReadAccessToURL:request.URL];
            return;
        }
        
        if ([[request.URL lastPathComponent] isEqualToString:@"zss-rich-text-editor.html"]) {
            NSString *html = [NSString stringWithContentsOfURL:request.URL encoding:NSUTF8StringEncoding error:nil];
            NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
            [_webView loadHTMLString:html baseURL:baseURL];
            return;
        }

        [_webView loadRequest:request];
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *error))completionHandler
{
    [_webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

-(void)setHideKeyboardAccessoryView:(BOOL)hideKeyboardAccessoryView
{
  if (!hideKeyboardAccessoryView) {
    return;
  }
  
  UIView *subview;
  for (UIView* view in _webView.scrollView.subviews) {
    if ([[view.class description] hasPrefix:@"WKContent"])
      subview = view;
  }
  
  if (subview == nil) return;
  
  NSString *name = [NSString stringWithFormat:@"%@_SwizzleHelperWK", subview.class.superclass];
  Class newClass = NSClassFromString(name);
  
  if(newClass == nil)
  {
    newClass = objc_allocateClassPair(subview.class, [name cStringUsingEncoding:NSASCIIStringEncoding], 0);
    if(!newClass) return;
    
    Method method = class_getInstanceMethod([_SwizzleHelperWK class], @selector(inputAccessoryView));
    class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));
    
    objc_registerClassPair(newClass);
  }
  
  object_setClass(subview, newClass);
}

@end
