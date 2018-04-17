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
    
    

#import <MobileCoreServices/MobileCoreServices.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/CKURLPreviewViewController.h>
#import <CanvasKit1/CKUploadProgressToolbar.h>

#import "FileViewController.h"
#import "WebBrowserViewController.h"
#import "NoPreviewAvailableController.h"
#import "Router.h"
#import "ContentLockViewController.h"
#import "UIWebView+SafeAPIURL.h"
#import "CBIModuleProgressNotifications.h"
#import "Analytics.h"
#import "CBILog.h"
#import "CKIClient+CBIClient.h"
#import "CBIAssignmentDetailViewController.h"
#import "UIAlertController+TechDebt.h"

@import PSPDFKit;
@import PSPDFKitUI;
@import CanvasKeymaster;

// TODO: REMOVE

// This is just a simple controller to present a webview as a child
// controller, so it can be used analogously to QLPreviewController.
@interface HTMLPreviewController : UIViewController <UIWebViewDelegate>
@property (nonatomic) NSURL *url;
@end

@implementation HTMLPreviewController
- (void)loadView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    if (self.url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [webView loadRequest:request];
        [webView setBackgroundColor:[UIColor clearColor]];
    }
    self.view = webView;
}

- (void)setUrl:(NSURL *)url
{
    if (url == _url) {
        return;
    }
    _url = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [(UIWebView *)self.view loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView replaceHREFsWithAPISafeURLs];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) {
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"There was a problem accessing the requested file.\n\nError: %@", "Error message when fetching a file fails"), error.localizedDescription];
        [UIAlertController showAlertWithTitle:nil message:errorMessage];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        UINavigationController *controller = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
        WebBrowserViewController *browser = controller.viewControllers[0];
        [browser setUrl:request.URL];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

@end



@interface FileViewController () < UIDocumentInteractionControllerDelegate, QLPreviewControllerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation FileViewController {
    UIViewController *contentChildController;
    UIView *container;
    UINavigationBar *interactionNavBar;
    UIBarButtonItem *actionButton;
    UIDocumentInteractionController *interactionController;
    UILabel *messageLabel;
    UIPrintInteractionController *printController;
    PreSubmissionPDFDocumentPresenter *pdfDocPresenter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.definesPresentationContext = YES;
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self lockIfNeeded];
    
    CGFloat toolbarHeight = [CKUploadProgressToolbar preferredHeight];
    CGFloat myViewBottom = CGRectGetMaxY(self.view.bounds);
    CGFloat myViewWidth = CGRectGetWidth(self.view.bounds);
    _progressToolbar = [[CKUploadProgressToolbar alloc] initWithFrame:CGRectMake(0, myViewBottom - toolbarHeight, myViewWidth, toolbarHeight)];
    _progressToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    _progressToolbar.uploadCompleteText = NSLocalizedString(@"Finished downloading", @"Shown when we finish downloading a file");
    _progressToolbar.uploadInProgressText = NSLocalizedString(@"Downloading...", @"Shown while downloading a file");
    
    [self.view addSubview:_progressToolbar];
    
    interactionNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, myViewWidth, 44)];
    interactionNavBar.barStyle = UIBarStyleBlackOpaque;
    interactionNavBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(tappedActionButton:)];
    actionButton.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = actionButton;
    interactionNavBar.items = @[self.navigationItem];
    
    container = [[UIView alloc] initWithFrame:self.view.bounds];
    container.backgroundColor = [UIColor clearColor];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:container belowSubview:_progressToolbar];

    [self updateForURLState];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.pageViewEventLog = [PageViewEventLoggerLegacySupport new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.activityView];
    [Analytics logScreenView:kGAIScreenFilePreview];
    [self.pageViewEventLog start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [pdfDocPresenter savePDFAnnotations];
    
    if (_progressToolbar.cancelBlock && [self.presentedViewController isBeingPresented] == NO) {
        _progressToolbar.cancelBlock();
        [_progressToolbar cancel];
    }
    [self.pageViewEventLog stopWithEventName: self.pageViewEventName];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Routing

- (void)applyRoutingParameters:(NSDictionary *)params {
    [super applyRoutingParameters:params];
    NSNumber *fileIdent = params[@"query"][@"preview"];
    if (fileIdent) {
        self.fileIdent = [fileIdent intValue];
    }
    NSNumber *assignmentID = params[@"query"][@"assignmentID"];
    if (assignmentID) {
        self.assignmentID = [assignmentID intValue];
    }
    [self fetchFile];
}

#pragma mark - Fetching

- (void)fetchFile {
    [self.canvasAPI getFileWithId:self.fileIdent block:^(NSError *error, BOOL isFinalValue, CKAttachment *file) {
        if (error) {
            NSLog(@"Error getting file with ident: %lld", self.fileIdent);

            if (error.code != NSURLErrorCancelled) {
                NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"There was a problem accessing the requested file.\n\nError: %@", "Error message when fetching a file fails"), error.localizedDescription];
                [UIAlertController showAlertWithTitle:nil message:errorMessage];
            }
            return;
        }
        
        if (!isFinalValue) {
            return;
        }
        
        self.file = file;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [self pathForPersistedFile:file];
        
        if ([fileManager fileExistsAtPath:path]) {
            [self.activityView stopAnimating];
            self.downloadProgress = 1.0;
            self.showsInteractionButton = YES;
            DDLogVerbose(@"CBIFileViewController posting module item progress update after fetching file");
            CBIPostModuleItemProgressUpdate([@(self.fileIdent) description], CKIModuleItemCompletionRequirementMustView);

            NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
            self.url = url;
        } else {
            [self.canvasAPI downloadAttachment:file progressBlock:^(float progress) {
                self.downloadProgress = progress;
            } completionBlock:^(NSError *error, BOOL isFinalValue, NSURL *url) {
                if (error) {
                    [self showDownloadError:error];
                }
                else if (isFinalValue) {
                    self.downloadProgress = 1.0;
                    self.showsInteractionButton = YES;

                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSURL *persistentURL = [[NSURL alloc] initFileURLWithPath:path];
                    [fileManager copyItemAtURL:url toURL:persistentURL error:nil];

                    self.url = persistentURL;
                }

                [self.activityView stopAnimating];
                DDLogVerbose(@"CBIFileViewController posting module item progress update after fetching file");
                CBIPostModuleItemProgressUpdate([@(self.fileIdent) description], CKIModuleItemCompletionRequirementMustView);
            }];
        }
    }];
}

- (NSString *)pathForPersistedFile:(CKAttachment *)file {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%llu_%@", TheKeymaster.currentClient.authSession.user.id, file.ident, file.filename]];
    return path;
}

- (void)setFile:(CKAttachment *)file {
    if (file == _file) {
        return;
    }
    _file = file;
    self.title = file.displayName;
    [self lockIfNeeded];
}

- (void)setShowsInteractionButton:(BOOL)showsInteractionButton {
    _showsInteractionButton = showsInteractionButton;
    
    [self.view setNeedsLayout];
}

- (UIViewController *)childControllerForContentAtURL:(NSURL *)url {
    NSString *uti;
    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    
    UIViewController *controller = nil;
    
    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeHTML)) {
        HTMLPreviewController *webController = [[HTMLPreviewController alloc] init];
        webController.url = url;
        controller = webController;
    } else if ([_file.contentType isEqualToString:@"application/pdf"]) {
        pdfDocPresenter = [[PreSubmissionPDFDocumentPresenter alloc] initWithDocumentURL:url session:TheKeymaster.currentClient.authSession defaultCourseID:[self hackishlyGetDefaultCourseIfPossible] defaultAssignmentID:[self hackishlyGetDefaultAssignmentIfPossible]];
        @weakify(self);
        pdfDocPresenter.didSubmitAssignment = ^{
            @strongify(self);

            if ([self->contentChildController isKindOfClass:[PSPDFViewController class]]) {
                PSPDFViewController *vc = (PSPDFViewController *)self->contentChildController;
                [vc.annotationToolbarController.annotationToolbar hideToolbarAnimated:NO completion:nil];
            }

            [self.navigationController popViewControllerAnimated:YES];
        };
        controller = [pdfDocPresenter getPDFViewController];
    } else if ([QLPreviewController canPreviewItem:_url]) {
        CKURLPreviewViewController *previewController = [[CKURLPreviewViewController alloc] init];
        previewController.delegate = self;
        previewController.url = url;
        [previewController reloadData];
        controller = previewController;
    }
    else {
        NoPreviewAvailableController *noPreviewController = [NoPreviewAvailableController new];
        noPreviewController.url = url;
        controller = noPreviewController;
    }
    return controller;
}

- (NSString * _Nullable)hackishlyGetDefaultAssignmentIfPossible {
    if (self.assignmentID) {
        return [@(self.assignmentID) stringValue];
    }
    
    CBIAssignmentDetailViewController *assignmentDeets = [self assignmentDeets];
    return assignmentDeets.viewModel.model.id;
}

- (NSString * _Nullable)hackishlyGetDefaultCourseIfPossible {
    CBIAssignmentDetailViewController *assignmentDeets = [self assignmentDeets];
    if (assignmentDeets.viewModel.model.courseID) {
        return assignmentDeets.viewModel.model.courseID;
    }
    
    if (self.contextInfo.contextType == CKContextTypeCourse) {
        return [@(self.contextInfo.ident) stringValue];
    }
    
    return nil;
}

- (CBIAssignmentDetailViewController * _Nullable)assignmentDeets {
    if (self.navigationController.viewControllers.count < 2) { return nil; }

    UIViewController *previousViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    UIViewController *realFRD = previousViewController;
    if ([previousViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitView = (UISplitViewController *)realFRD;
        if ([[splitView.viewControllers objectAtIndex:1] isKindOfClass:[UINavigationController class]] && [((UINavigationController *)[splitView.viewControllers objectAtIndex:1]).topViewController isKindOfClass:[CBIAssignmentDetailViewController class]]) {
            realFRD = [splitView.viewControllers objectAtIndex:1];
        }
        // TODO: This never worked in the first place, put we should fix it!
        /*else if ([splitView.detail isKindOfClass:[CBIModuleProgressionViewController class]]) {
            CBIModuleProgressionViewController *progressionVC = (CBIModuleProgressionViewController *)splitView.detail;
            if ([progressionVC.childViewController isKindOfClass:[CBIAssignmentDetailViewController class]]) {
                realFRD = progressionVC.childViewController;
            }
        }*/
    }

    if ([realFRD isKindOfClass:[CBIAssignmentDetailViewController class]]) {
        return (CBIAssignmentDetailViewController *)realFRD;
    } else {
        return nil;
    }
}

- (void)setUrl:(NSURL *)url {
    _url = [url copy];
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
    [self updateForURLState];
}

- (void)updateForURLState {

    if ([_url isFileURL]) {
        contentChildController = [self childControllerForContentAtURL:_url];

        [self addChildViewController:contentChildController];
        [contentChildController viewWillAppear:YES]; // for some reason viewWillAppear wasn't getting called during addChildViewController's invocation
        UIView *childView = contentChildController.view;
        childView.translatesAutoresizingMaskIntoConstraints = NO;
        childView.frame = container.bounds;
        [childView setClipsToBounds:NO];
        [self.view addSubview:childView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[childView]|" options:0 metrics:nil views:@{@"childView":childView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:@{@"childView":childView}]];

        actionButton.enabled = YES;

        if ([contentChildController isKindOfClass:[PSPDFViewController class]]) {
            self.navigationItem.rightBarButtonItems = contentChildController.navigationItem.rightBarButtonItems;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"FileViewControllerBarButtonItemsDidChange" object:nil];
        }

         [contentChildController didMoveToParentViewController:self];
    } else {
        actionButton.enabled = NO;
        
        [contentChildController willMoveToParentViewController:nil];
        [contentChildController.view removeFromSuperview];
        [contentChildController removeFromParentViewController];
        contentChildController = nil;
    }
    [self.view setNeedsLayout];
}

- (void)setDownloadProgress:(float)downloadProgress {
    _downloadProgress = downloadProgress;
    
    if (downloadProgress >= 1.0) {
        [self.activityView stopAnimating];
        [_progressToolbar transitionToUploadCompletedWithError:NULL completion:nil];
    }
    else if (downloadProgress > 0.0) {
        [self.activityView startAnimating];
        [_progressToolbar updateProgressViewWithProgress:downloadProgress];
    }
}

- (void)showDownloadError:(NSError *)error {
    [_progressToolbar transitionToUploadCompletedWithError:error completion:NULL];
}

- (void)setShowsCancelMessage:(BOOL)show {
    if (!messageLabel) {
        messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = [UIFont systemFontOfSize:20];
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.alpha = 0.5;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view insertSubview:messageLabel belowSubview:container];
    }
    if (show) {
        messageLabel.text = _progressToolbar.cancelText ?: NSLocalizedString(@"Download Canceled", @"Shown when we cancel a file download");
    }
    else {
        messageLabel.text = nil;
    }
}


- (void)tappedActionButton:(id)sender {
    DDLogVerbose(@"tappedActionButton");
    if (!interactionController) {
        interactionController = [UIDocumentInteractionController interactionControllerWithURL:self.url];
        interactionController.delegate = self;
    }
    interactionController.URL = self.url;
    BOOL presented = [interactionController presentOptionsMenuFromBarButtonItem:actionButton animated:YES];
    if (!presented) {
        NSString *title = NSLocalizedString(@"No actions available for this file", @"Text of alert when attempting to select a file that can't be printed or passed to any other app");
        [UIAlertController showAlertWithTitle:title message:nil];
    }
    if (printController) {
        [printController dismissAnimated:NO];
        printController = nil;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.activityView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self repositionToolbar];
    [self repositionContainer];
}

- (void)repositionToolbar {
    BOOL shouldBeVisible = _showsInteractionButton && (self.navigationController == nil || self.navigationController.navigationBarHidden);
    
    interactionNavBar.frame = (CGRect){
        .origin = CGPointZero,
        .size.width = container.bounds.size.width,
        .size.height = (shouldBeVisible ? 44 : 0)
    };
    
    if (shouldBeVisible) {
        [self.view addSubview:interactionNavBar];
    }
    else {
        [interactionNavBar removeFromSuperview];
    }
}

- (void)repositionContainer {
    CGRect interactionFrame = interactionNavBar.frame;
    CGFloat interactionBottom = CGRectGetMaxY(interactionFrame);
    CGRect containerFrame = CGRectMake(0, interactionBottom, self.view.bounds.size.width, CGRectGetMaxY(self.view.bounds) - interactionBottom);
    container.frame = containerFrame;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action {
    if (action == @selector(copy:)) {
        return NO;
    }
    if (action == @selector(print:) && [UIPrintInteractionController canPrintURL: controller.URL]) {
        return YES;
    }
    return NO;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action {
    if (action == @selector(print:)) {
        [self print:nil];
        return YES;
    }
    return NO;
}

- (void)print:(id)sender {
    printController = [UIPrintInteractionController sharedPrintController];
    printController.printingItem = self.url;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [printController presentFromBarButtonItem:actionButton animated:YES completionHandler:NULL];
    }
    else {
        [printController presentAnimated:YES completionHandler:NULL];
    }
}

#pragma mark - QLPreviewControllerDelegate

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item
{
    UINavigationController *navController = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    WebBrowserViewController *browser = navController.viewControllers[0];
    [browser setUrl:url];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:navController animated:YES completion:nil];
    
    
    return NO;
}

#pragma mark - Locking

- (void)lockIfNeeded {
    if (self.file.contentLock) {
        [self displayContentLock];
    }
}

- (void)displayContentLock {
    ContentLockViewController *contentLockVC = [[ContentLockViewController alloc] initWithContentLock:self.file.contentLock
                                                                                             itemName:self.file.displayName
                                                                                            inContext:self.contextInfo];
    
    [contentLockVC lockViewController:self];
}

@end
