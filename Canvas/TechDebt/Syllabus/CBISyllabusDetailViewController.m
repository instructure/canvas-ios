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
    
    

#import "CBISyllabusDetailViewController.h"
#import <CanvasKit/CanvasKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"
#import "UIWebView+SafeAPIURL.h"
#import "CKIClient+CBIClient.h"
#import "Router.h"
@import CanvasKeymaster;
#import "CBILog.h"
@import Crashlytics;
@import CanvasCore;

@interface CBISyllabusDetailViewController () <UIWebViewDelegate>
@property (nonatomic, strong) CanvasWebView *webView;
@end

@implementation CBISyllabusDetailViewController

@synthesize course = _course;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.viewModel) {
        [[[CKIClient currentClient] courseWithUpdatedPermissionsSignalForCourse:self.viewModel.model] subscribeNext:^(CKICourse *course) {
            CKCourse *model = [CKCourse new];
            self.course = [model initWithInfo:[course JSONDictionary]];
        }];
    }
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    CLS_LOG(@"Loaded Syllabus Detail View");
    
    self.webView = [[CanvasWebView alloc] init];
    self.webView.presentingViewController = self;
    [self.view addSubview:self.webView];
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *innerView = self.webView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[innerView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(innerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[innerView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(innerView)]];
    [self.view layoutIfNeeded];

    [self updateWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView setFrame:self.view.frame];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)updateWebView
{
    if (self.course) {
        Session *session = TheKeymaster.currentClient.authSession;
        @weakify(self);
        [self.webView loadWithHtml:self.course.syllabusBody title:self.course.name baseURL:session.baseURL routeToURL:^(NSURL * _Nonnull url) {
            @strongify(self);
            [[Router sharedRouter] routeFromController:self toURL:url];
        }];
    }
}

- (void)setCourse:(CKCourse *)course
{
    _course = course;
    [self updateWebView];
}

@end
