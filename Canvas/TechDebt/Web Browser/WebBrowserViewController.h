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
    
    

@import UIKit;
@import WebKit;

@protocol WebBrowserRequest <NSObject>
- (void)loadRequestInWebView:(WKWebView *)webView;
@property (nonatomic, readonly) BOOL canOpenInSafari;
@end

@class WebBrowserViewController;

@protocol WebBrowserViewControllerDelegate <NSObject>
- (void)webBrowser:(WebBrowserViewController *)webBrowser didFinishLoadingWebView:(WKWebView *)webView;
@end

@interface NSURLRequest (WebBrowser) <WebBrowserRequest>
@end

@interface StaticHTMLRequest: NSObject <WebBrowserRequest>
+ (instancetype)requestWithHTML:(NSString *)html baseURL:(NSURL *)baseURL;
@end

@interface WebBrowserViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url delegate:(id<WebBrowserViewControllerDelegate>)delegate;

// EITHER
@property (nonatomic) NSURL *url;
// OR
@property (nonatomic, strong) id<WebBrowserRequest> request;
// OR
- (void)setContentHTML:(NSString *)html baseURL:(NSURL *)baseURL;

@property (nonatomic, copy) void (^browserWillDismissBlock)(void);

@property (nonatomic, weak) id<WebBrowserViewControllerDelegate> delegate;

@end
