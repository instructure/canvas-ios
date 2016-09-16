//
//  WebBrowserViewController.h
//  iCanvas
//
//  Created by Mark Suman on 10/24/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebBrowserRequest <NSObject>
- (void)loadRequestInWebView:(UIWebView *)webView;
@property (nonatomic, readonly) BOOL canOpenInSafari;
@end

@interface NSURLRequest (WebBrowser) <WebBrowserRequest>
@end

@interface StaticHTMLRequest: NSObject <WebBrowserRequest>
+ (instancetype)requestWithHTML:(NSString *)html baseURL:(NSURL *)baseURL;
@end

@interface WebBrowserViewController : UIViewController

// EITHER
@property (nonatomic) NSURL *url;
// OR
@property (nonatomic, strong) id<WebBrowserRequest> request;
// OR
- (void)setContentHTML:(NSString *)html baseURL:(NSURL *)baseURL;

@property (nonatomic, copy) void (^browserWillDismissBlock)();

@end
