//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import <CanvasKit1/CKAssignment.h>
#import <QuartzCore/QuartzCore.h>
#import "AssignmentDetailsViewController.h"
#import "iCanvasErrorHandler.h"
#import "Router.h"
#import "CBIModuleProgressNotifications.h"
#import "NSURL+TechDebt.h"
@import CanvasKit;
@import CanvasKeymaster;
@import CanvasCore;

@interface AssignmentDetailsViewController ()
@property (nonatomic) CanvasWebView *webView;
@end

@implementation AssignmentDetailsViewController

#pragma mark - Public Methods
- (UIScrollView *)scrollView
{
    return self.webView.scrollView;
}

#pragma mark - View Lifecycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.webView = [[CanvasWebView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self);
    self.webView.presentingViewController = self;
    self.webView.finishedLoading = ^{
        @strongify(self);
        [self finishedLoadingContent];
    };
    
    [self.view addSubview:self.webView];
    self.webView.frame = CGRectInset(self.view.bounds, 0, 0);
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self loadDetailsForAssignment];
    self.view.backgroundColor = [UIColor prettyLightGray];
    self.webView.layer.borderColor = [UIColor prettyGray].CGColor;
    self.webView.layer.borderWidth = 1.0f;
    
    if(self.prependAssignmentInfoToContent){
        self.webView.layer.borderWidth = 0.0f;
    }

    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    [AppStoreReview handleNavigateToAssignment];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;
}

- (void)dealloc
{
    [AppStoreReview handleNavigateFromAssignment];
}

- (void)finishedLoadingContent {
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.topContentInset, 0, self.bottomContentInset, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    CBIPostModuleItemProgressUpdate([@(self.assignment.ident) description], CKIModuleItemCompletionRequirementMustView);
}

- (void)setTopContentInset:(CGFloat)topContentInset
{
    _topContentInset = topContentInset;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(topContentInset, 0, self.bottomContentInset, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(topContentInset, 0, self.bottomContentInset, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)setBottomContentInset:(CGFloat)bottomContentInset
{
    _bottomContentInset = bottomContentInset;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(self.topContentInset, 0, bottomContentInset, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.topContentInset, 0, bottomContentInset, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

#pragma mark - Assignment Management

- (void)loadDetailsForAssignment
{
    if (self.assignment == nil) {
        return;
    }

    NSBundle *bundle = [NSBundle bundleForClass:self.class];

    NSString *detailPlaceholder = [NSString stringWithFormat:@"<span style=\"color: #999999;\">%@</span>", NSLocalizedStringFromTableInBundle(@"This assignment has no details.", nil, bundle, @"message displayed in the details section if there is no comment.")];
    NSString *details = self.assignment.assignmentDescription ?: detailPlaceholder;
    
    if (self.prependAssignmentInfoToContent) {
        NSString *dueDateString;
        if (self.assignment.dueDate == nil) {
            dueDateString = NSLocalizedStringFromTableInBundle(@"No due date", nil, bundle, "Indicates an assignment does not have a due date");
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateStyle = NSDateFormatterMediumStyle;
            dateFormat.timeStyle = NSDateFormatterShortStyle;

            dueDateString = [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"Due: %@", nil, bundle, "Due date label indicating when an assignment is due"), [dateFormat stringFromDate:self.assignment.dueDate]];
        }
        
        if (self.assignment.name) {
            NSString* assignmentInfo = [NSString stringWithFormat:@"<p style=\"font-family:'HelveticaNeue-Medium','Helvetica Neue Medium','Helvetica Neue', Helvetica, Arial, 'Lucida Grande', sans-serif; font-weight:500;\"><span style=\"font-size: 125%%;\">%@</span><br><span style=\"font-style:italic; font-weight:bold;\">%@</span></p>",self.assignment.name, dueDateString];
            details = [assignmentInfo stringByAppendingString:details];       
        }
    }

    NSURL *baseURL = TheKeymaster.currentClient.baseURL;
    @weakify(self);
    [self.webView loadWithHtml:details title:nil baseURL:baseURL routeToURL:^(NSURL *url){
        @strongify(self);
        
        if (self.assignment.ident) {
            url = [[url copy] urlByAddingQueryParamWithName:@"assignmentID" value:[@(self.assignment.ident) stringValue]];
        }
        
        [[Router sharedRouter] routeFromController:self toURL:url];
    }];
}

- (void)setAssignment:(CKAssignment *)assignment
{
    if (_assignment == assignment) {
        return;
    }
    
    _assignment = assignment;
    [self loadDetailsForAssignment];
}

@end
