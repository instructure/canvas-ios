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
    
    
#import <CanvasKit1/CKAssignment.h>
#import "UIViewController+AnalyticsTracking.h"
#import <QuartzCore/QuartzCore.h>

#import "AssignmentDetailsViewController.h"
#import "iCanvasErrorHandler.h"
#import "UIWebView+LinkProcessing.h"
#import "UIWebView+RemoveShadow.h"
#import "UIWebView+SafeAPIURL.h"
#import "Router.h"
#import "CBIModuleProgressNotifications.h"
@import CanvasKit;
#import "CBILog.h"
@import CanvasKeymaster;
@import CanvasCore;

@interface AssignmentDetailsViewController () <UIWebViewDelegate>
@end

@implementation AssignmentDetailsViewController

#pragma mark - Public Methods
- (UIScrollView *)scrollView
{
    return self.webView.scrollView;
}

#pragma mark - View Lifecycle
- (id)init
{
    return self = [[UIStoryboard storyboardWithName:@"AssignmentDetails" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"AssignmentDetailsViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadDetailsForAssignment];
    self.view.backgroundColor = [UIColor prettyLightGray];
    self.webView.layer.borderColor = [UIColor prettyGray].CGColor;
    self.webView.layer.borderWidth = 1.0f;
    
    if(self.prependAssignmentInfoToContent){
        self.webView.layer.borderWidth = 0.0f;
    }
    
    [self.webView removeShadow];
    
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;
}

#pragma mark - Assignment Management

- (void)loadDetailsForAssignment
{
    if (self.assignment == nil) {
        return;
    }
    
    NSString *detailPlaceholder = [NSString stringWithFormat:@"<span style=\"color: #999999;\">%@</span>", NSLocalizedString(@"This assignment has no details.", @"message displayed in the details section if there is no comment.")];
    NSString *details = self.assignment.assignmentDescription ?: detailPlaceholder;
    
    if (self.prependAssignmentInfoToContent) {
        NSString *dueDateString;
        if (self.assignment.dueDate == nil) {
            dueDateString = NSLocalizedString(@"No due date", "Indicates an assignment does not have a due date");
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateStyle = NSDateFormatterMediumStyle;
            dateFormat.timeStyle = NSDateFormatterShortStyle;

            dueDateString = [NSString stringWithFormat: NSLocalizedString(@"Due: %@", "Due date label indicating when an assignment is due"), [dateFormat stringFromDate:self.assignment.dueDate]];
        }
        
        if (self.assignment.name) {
            NSString* assignmentInfo = [NSString stringWithFormat:@"<p style=\"font-family:'HelveticaNeue-Medium','Helvetica Neue Medium','Helvetica Neue', Helvetica, Arial, 'Lucida Grande', sans-serif; font-weight:500;\"><span style=\"font-size: 125%%;\">%@</span><br><span style=\"font-style:italic; font-weight:bold;\">%@</span></p>",self.assignment.name, dueDateString];
            details = [assignmentInfo stringByAppendingString:details];       
        }
    }

    NSString *htmlContents = [PageTemplateRenderer htmlStringWithTitle:self.assignment.name ?: @"" body:details ?: @""];
    NSURL *baseURL = TheKeymaster.currentClient.baseURL;
    [self.webView loadHTMLString:htmlContents baseURL:baseURL];
}

- (void)setAssignment:(CKAssignment *)assignment
{
    if (_assignment == assignment) {
        return;
    }
    
    _assignment = assignment;
    [self loadDetailsForAssignment];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([Secrets openExternalResourceIfNecessaryWithAURL:request.URL]) {
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeOther
        || navigationType == UIWebViewNavigationTypeFormSubmitted
        || navigationType == UIWebViewNavigationTypeFormResubmitted) {
        return YES;
    }
    
    NSArray<NSString *> *components = request.URL.pathComponents;
    if (components.lastObject != nil && request.URL.fragment != nil && components.count > 0) {
        NSString *selfReferencingFragment = [NSString stringWithFormat:@"%@#%@", TheKeymaster.currentClient.baseURL.absoluteString, request.URL.fragment];
        NSString *jsScrollToAnchor = [NSString stringWithFormat:@"window.location.href=\'#%@\';", request.URL.fragment];
        
        if ([request.URL.absoluteString isEqualToString:selfReferencingFragment]) {
            [webView stringByEvaluatingJavaScriptFromString:jsScrollToAnchor];
            return NO;
        }
    } else if (request.URL.fragment != nil && request.URL.pathComponents.count == 0 && [request.URL.scheme isEqualToString: @"applewebdata"]) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.href=\'#%@\';", request.URL.fragment]];
        return NO;
    }
    
    [[Router sharedRouter] routeFromController:self.parentViewController toURL:request.URL];

    return NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView.scrollView setContentInset:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    if (webView.loading == NO) {
        [webView replaceHREFsWithAPISafeURLs];
        [webView replaceYoutubeLinksWithInlineVideo];
    }
    
    DDLogVerbose(@"AssignmentDetailViewController posting module item progress update");
    CBIPostModuleItemProgressUpdate([@(self.assignment.ident) description], CKIModuleItemCompletionRequirementMustView);
}
@end
