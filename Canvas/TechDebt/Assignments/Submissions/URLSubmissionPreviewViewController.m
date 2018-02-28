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
    
    

#import "URLSubmissionPreviewViewController.h"
#import "UIViewController+AnalyticsTracking.h"
#import "UIWebView+SafeAPIURL.h"
#import "Analytics.h"
#import "UIAlertController+TechDebt.h"

@interface URLSubmissionPreviewViewController () <UIWebViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UINavigationItem *navItem;
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIBarButtonItem *submitButton;
    UIActivityIndicatorView *spinner;
    
    id keyboardShowObserver;
    id keyboardHideObserver;
    
    int loadingCount;
    BOOL webViewHasContent;
}

@end

@implementation URLSubmissionPreviewViewController
@synthesize onSubmit;
@synthesize shouldHideCancelButton;

+ (UIViewController *)createWithSubmissionHandler:(void (^)(NSURL*))handler
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"URLSubmissionPreviewStoryboard" bundle:[NSBundle bundleForClass:[self class]]];
    
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    URLSubmissionPreviewViewController *controller = (URLSubmissionPreviewViewController *)navigationController.topViewController;
    controller.onSubmit = [handler copy];
    controller.preferredContentSize = CGSizeMake(320, 480);
    
    return navigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [textField setRightView:spinner];
    textField.rightViewMode = UITextFieldViewModeAlways;
    spinner.hidesWhenStopped = YES;
    
    if (shouldHideCancelButton) {
        navItem.leftBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self startObservingKeyboard];
    
    [Analytics logScreenView:kGAIScreenURLSubmissionPreview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopObservingKeyboard];
}

- (void)startObservingKeyboard {
    void (^keyboardFrameBlock)(NSNotification *) = ^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        
        CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        CGFloat topOfKeyboard = CGRectGetMinY(keyboardFrame);
        CGFloat bottomOfView = CGRectGetMaxY(self.view.bounds);
        
        [UIView animateWithDuration:duration animations:^{
            [UIView setAnimationCurve:curve];
            
            CGFloat bottomInset = 0.0;
            if (topOfKeyboard < bottomOfView) {
                bottomInset = bottomOfView - topOfKeyboard;
            }
            webView.scrollView.contentInset = webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottomInset, 0);
            
        }];
        
    };
    
    keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:keyboardFrameBlock];
    
    keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:keyboardFrameBlock];
}
- (void)stopObservingKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:keyboardHideObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:keyboardShowObserver];
}

- (IBAction)typedURL:(id)sender
{
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadURLFromField) object:nil];
    [webView stopLoading];
    [spinner stopAnimating];
    if (webViewHasContent) {
        loadingCount = 0;
        webViewHasContent = NO;
        [webView loadHTMLString:@"<html></html>" baseURL:nil];
    }
    if (textField.text.length == 0) {
        submitButton.enabled = NO;
    }
    else {
        submitButton.enabled = YES;
        [self performSelector:@selector(loadURLFromField) withObject:nil afterDelay:0.75];
    }
}

- (void)loadURLFromField {
    NSURL *url = [NSURL URLWithString:textField.text];
    if (url.scheme == nil) {
        NSString *string = [@"http://" stringByAppendingString:textField.text];
        url = [NSURL URLWithString:string];
    }
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        loadingCount = 0;
        webViewHasContent = YES;
        [webView loadRequest:request];
    }
}

- (IBAction)submit:(id)sender {
    NSURL *url = [NSURL URLWithString:textField.text];
    if (url.scheme == nil) {
        NSString *string = [@"http://" stringByAppendingString:textField.text];
        url = [NSURL URLWithString:string];
    }
    
    if (url) {
        [textField resignFirstResponder];
        if (onSubmit) {
            onSubmit(url);
        }
        onSubmit = nil;
        [self dismiss:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ is not a valid URL", nil), textField.text];
        [UIAlertController showAlertWithTitle:nil message:message];
    }
}

- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [textField endEditing:YES];
    return NO;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    ++loadingCount;
    if (webViewHasContent) {
        [spinner startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    --loadingCount;
    if (loadingCount <= 0) {
        [spinner stopAnimating];
    }
    
    [webView replaceHREFsWithAPISafeURLs];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    --loadingCount;
    if (loadingCount <= 0) {
        [spinner stopAnimating];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ||
        navigationType == UIWebViewNavigationTypeFormSubmitted ||
        navigationType == UIWebViewNavigationTypeBackForward) {
        return NO;
    }
    
    return YES;
}
@end
