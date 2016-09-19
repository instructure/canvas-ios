//
//  AssignmentDetailsViewController.m
//  iCanvas
//
//  Created by derrick on 4/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//
#import <CanvasKit1/CKAssignment.h>
#import "UIViewController+AnalyticsTracking.h"
#import <QuartzCore/QuartzCore.h>

#import "AssignmentDetailsViewController.h"
#import "iCanvasErrorHandler.h"
#import "UIWebView+RemoveShadow.h"
#import "UIWebView+SafeAPIURL.h"
#import "Router.h"
#import "CBIModuleProgressNotifications.h"
@import SoPretty;
@import CanvasKit;
#import "CBILog.h"
@import CanvasKeymaster;
@import PageKit;

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

#pragma mark - Assignment Management

- (void)loadDetailsForAssignment
{
    if (self.assignment == nil) {
        return;
    }
    
    NSString *detailPlaceholder = [NSString stringWithFormat:@"<span style=\"color: #999999;\">%@</span>", NSLocalizedString(@"This assignment has no details.", @"message displayed in the details section if there is no comment.")];
    NSString *details = self.assignment.assignmentDescription ?: detailPlaceholder;
    
    if(self.prependAssignmentInfoToContent){
        NSString *date = NSLocalizedString(@"Due:", "This string is prepended to the due date for an assignment");
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateStyle = NSDateFormatterMediumStyle;
        dateFormat.timeStyle = NSDateFormatterShortStyle;
        
        if (self.assignment.dueDate != nil) {
            date = [date stringByAppendingString:[dateFormat stringFromDate:self.assignment.dueDate]];
        }
        
        if (self.assignment.name) {
            NSString* assignmentInfo = [NSString stringWithFormat:@"<p style=\"font-family:'HelveticaNeue-Medium','Helvetica Neue Medium','Helvetica Neue', Helvetica, Arial, 'Lucida Grande', sans-serif; font-weight:500;\"><span style=\"font-size: 125%%;\">%@</span><br><span style=\"font-style:italic; font-weight:bold;\">%@</span></p>",self.assignment.name, date];
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
    if (navigationType == UIWebViewNavigationTypeOther
        || navigationType == UIWebViewNavigationTypeFormSubmitted
        || navigationType == UIWebViewNavigationTypeFormResubmitted) {
        return YES;
    }
    
    [[Router sharedRouter] routeFromController:self.parentViewController toURL:request.URL];

    return NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView.scrollView setContentInset:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [webView replaceHREFsWithAPISafeURLs];
    DDLogVerbose(@"AssignmentDetailViewController posting module item progress update");
    CBIPostModuleItemProgressUpdate([@(self.assignment.ident) description], CKIModuleItemCompletionRequirementMustView);
}
@end
