//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKILoginViewController.h"
#import "NSString+CKIAdditions.h"
@import ReactiveObjC;
#import "CKIClient.h"
#import "UIAlertController+Show.h"

@interface CKILoginViewController () <WKNavigationDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic) CKIAuthenticationMethod method;
@property (nonatomic, copy) void(^completionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential *);
@end

@implementation CKILoginViewController

- (id)initWithRequest:(NSURLRequest *)request method:(CKIAuthenticationMethod)method
{
    self = [super init];
    if (self) {
        self.request = request;
        self.method = method;
    }
    return self;
}

- (void)clearExistingSessions {
    // remove cookies to dispose of previous login session
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *oldCookie in storage.cookies) {
        [storage deleteCookie:oldCookie];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerUserAgentForGoogle];
    [self setTitle:self.request.URL.host];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.navigationDelegate = self;
    [self.webView setOpaque:NO];
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    self.view = self.webView;
    
    [self clearExistingSessions];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    [[session dataTaskWithURL:[self.request URL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadLoginRequest];
                });
            }] resume];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterUserAgentForGoogle];
}

+ (NSString *)safariUserAgent {
    return @"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1";
}

static UIImage *_loadingImage = nil;

+ (void)setLoadingImage:(UIImage *)image {
    _loadingImage = image;
}

+ (UIImage *)loadingImage {
    return _loadingImage;
}

- (void)registerUserAgentForGoogle {
    // Google auth does not support WebViews so we have to send a Safari user agent
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": self.class.userAgent}];
}

+ (NSString *)userAgent {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return [NSString stringWithFormat:[CKILoginViewController safariUserAgent], [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
}

- (void)unregisterUserAgentForGoogle
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserAgent"];
}

- (void)loadLoginRequest {
    [self clearExistingSessions];
    NSMutableURLRequest *request = [self.request mutableCopy];
    if (self.method == CKIAuthenticationMethodSiteAdmin) {
        [request setHTTPShouldHandleCookies:YES];
        NSDictionary *cookieProperties = @{
                                           NSHTTPCookieValue: @"1",
                                           NSHTTPCookieDomain: @".instructure.com",
                                           NSHTTPCookieName: @"canvas_sa_delegated",
                                           NSHTTPCookiePath: @"/"
                                           };
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    [request setValue:[self.class userAgent] forHTTPHeaderField:@"User-Agent"];
    [self.webView loadRequest:request];
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        NSURLCredential *credential = nil;
        self.completionHandler = completionHandler;
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM] || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"Username", nil);
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedStringFromTableInBundle(@"Password", nil, [NSBundle bundleForClass:[self class]], nil);
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                [self cancelOAuth];
            }];
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSString *username = alert.textFields.firstObject.text;
                NSString *password = alert.textFields.lastObject.text;
                
                NSURLCredential *secretHandshake = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
                if (self.completionHandler) {
                    self.completionHandler(NSURLSessionAuthChallengeUseCredential,secretHandshake);
                }
            }];
            [alert addAction:cancelAction];
            [alert addAction:OKAction];
            
            [alert show];
        } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
            //See AFURLSessionManager
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
            
            if (self.completionHandler) {
                self.completionHandler(disposition, credential);
            }
        } else {
            if (self.completionHandler) {
                self.completionHandler(disposition, credential);
            }
        }
    });
}

#pragma mark - Webview Delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([[[navigationAction.request URL] description] isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // I dunno why, but we have to wait for the code to be the first param cuz it can keep changing as we follow redirects
    if ([navigationAction.request.URL.absoluteString containsString:@"/canvas/login?code="]) {
        self.successBlock([self getValueFromRequest:navigationAction.request withKey:@"code"]);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([self getValueFromRequest:navigationAction.request withKey:@"error"]) {
        self.failureBlock([NSError errorWithDomain:@"com.instructure.canvaskit" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Authentication failed. Most likely the user denied the request for access."}]);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - OAuth Processing

/**
 Checks the query parameters of the |request| for the |key|
 
 @param request The request object that may contain the specified key in the query parameters
 @param key The key for the value desired from the query parameters
 */
- (id)getValueFromRequest:(NSURLRequest *)request withKey:(NSString *)key
{
    NSString *query = request.URL.query;
    NSDictionary *parameters = [query queryParameters];
    
    return parameters[key];
}

- (void)cancelOAuth {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return NO;
    }
    return YES;
}
    
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}
    
@end
