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

@interface CKILoginViewController () <UIWebViewDelegate, NSURLSessionTaskDelegate, UIAlertViewDelegate>
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
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.webView setOpaque:NO];
    [self.webView setBackgroundColor:[UIColor blackColor]];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterUserAgentForGoogle];
}

+ (NSString *)safariUserAgent {
    return @"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1";
}

- (void)registerUserAgentForGoogle
{
    // Google auth does not support WebViews so we have to send a Safari user agent
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *userAgent = [NSString stringWithFormat: [CKILoginViewController safariUserAgent], [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": userAgent}];
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
    [self.webView loadRequest:request];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self cancelOAuth];
    } else {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        
        NSURLCredential *secretHandshake = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
        if (self.completionHandler) {
            self.completionHandler(NSURLSessionAuthChallengeUseCredential,secretHandshake);
        }
    }
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        NSURLCredential *credential = nil;
        self.completionHandler = completionHandler;
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM] || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]){
            UIAlertView *alertView = [UIAlertView new];
            alertView.delegate = self;
            alertView.title = NSLocalizedString(@"Login", nil);
            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [alertView textFieldAtIndex:0].placeholder = NSLocalizedString(@"Username", nil);
            [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
            
            [alertView show];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] description] isEqualToString:@"about:blank"]) {
        return NO;
    }
    
    // I dunno why, but we have to wait for the code to be the first param cuz it can keep changing as we follow redirects
    if ([request.URL.absoluteString containsString:@"/canvas/login?code="]) {
        self.successBlock([self getValueFromRequest:request withKey:@"code"]);
        return NO;
    } else if ([self getValueFromRequest:request withKey:@"error"]) {
        self.failureBlock([NSError errorWithDomain:@"com.instructure.canvaskit" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Authentication failed. Most likely the user denied the request for access."}]);
        return NO;
    }
    
    return YES;
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

- (void)cancelOAuth
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.failureBlock([NSError errorWithDomain:@"com.instructure.canvaskit" code:0 userInfo:@{NSLocalizedDescriptionKey: @"User cancelled authentication"}]);
    }];
}

@end
