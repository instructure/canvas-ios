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
    
    

#import "LTIViewController.h"
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit/CanvasKit.h>
#import "iCanvasErrorHandler.h"

#import "UIViewController+AnalyticsTracking.h"
#import "UIWebView+SafeAPIURL.h"
#import "CBIModuleProgressNotifications.h"
#import "Analytics.h"
@import CanvasKeymaster;
#import "CBILog.h"

@interface LTIViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation LTIViewController

- (id)init
{
    return [[UIStoryboard storyboardWithName:@"LTIView" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"LTIViewController"];
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.externalTool.name;
    [self.webView loadHTMLString:@"" baseURL:nil]; // gets rid of the black bar while loading
    [self loadExternalTool];
    [self finishLoading];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"TRACKING: %@", kGAIScreenLTI);
    [Analytics logScreenView:kGAIScreenLTI];
}

#pragma mark - content

- (void)loadExternalTool
{
    if (!self.externalTool || !self.webView) {
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.externalTool.url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", TheKeymaster.currentClient.accessToken] forHTTPHeaderField:@"Authorization"];
    [session.configuration.URLCache removeCachedResponseForRequest:request];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSURL *url = [NSURL URLWithString:jsonResponse[@"url"]];
        if (url) {
            url = [self url:url appendingURLQuery:[NSURLQueryItem queryItemWithName:@"platform" value:@"ios"]];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

        [self.webView loadRequest:request];
        DDLogVerbose(@"LTIViewController posting module item progress update after starting to load the External Tool URL in the webview");
        CBIPostModuleItemProgressUpdate([self.externalTool.url absoluteString], CKIModuleItemCompletionRequirementMustView);
    }];
    [task resume];
    CBIPostModuleItemProgressUpdate([self.externalTool.url absoluteString], CKIModuleItemCompletionRequirementMustView);
}

- (NSURL *)url:(NSURL *)url appendingURLQuery:(NSURLQueryItem *)query
{
    NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:components.queryItems];
    [queryItems addObject:query];
    components.queryItems = queryItems;

    return components.URL;
}

- (void)setExternalTool:(CKIExternalTool *)externalTool
{
    _externalTool = externalTool;
    
    self.title = externalTool.name;
    [self loadExternalTool];
}

#pragma mark - actions

- (IBAction)navigateBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)navigateForward:(id)sender {
    [self.webView goForward];
}

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate

- (void)finishLoading
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self constrainWidth];
    }];
}

- (void)constrainWidth {
    UIWebView *webView = self.webView;
    NSInteger width = webView.bounds.size.width;
    
    NSString* js =
    [NSString stringWithFormat:@"var meta = document.createElement('meta'); " \
     "meta.setAttribute( 'name', 'viewport' ); " \
     "meta.setAttribute( 'content', 'width = %@, initial-scale = 1.0, user-scalable = yes' ); " \
     "document.getElementsByTagName('head')[0].appendChild(meta)", @(width)];
    
    [webView stringByEvaluatingJavaScriptFromString: js];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self constrainWidth];

    [self finishLoading];
    [webView replaceHREFsWithAPISafeURLs];
    DDLogVerbose(@"LTIViewController posting module item progress update after webview finished loading");
    CBIPostModuleItemProgressUpdate([self.externalTool.url absoluteString], CKIModuleItemCompletionRequirementMustView);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoading];
}
- (IBAction)closeButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
