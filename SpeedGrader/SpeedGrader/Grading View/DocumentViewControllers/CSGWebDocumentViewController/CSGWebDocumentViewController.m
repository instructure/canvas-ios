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

#import "CSGWebDocumentViewController.h"

#import "CSGAppDataSource.h"
#import "NSAttributedString+RegexHighlight.h"
#import "CSGGradingViewController.h"

#import "CSGFileTypes.h"
#import "NSURL+QueryParams.h"

@import PSPDFKit;
@import SoAnnotated;

typedef void (^AnimationBlock)();

static NSTimeInterval const CSGWebDocumentControllerDefaultAnimationDuration = 0.25;

@interface CSGWebDocumentViewController () <UIWebViewDelegate, PSPDFFlexibleToolbarDelegate>

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, strong) NSArray *supportedFileTypes;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UITextView *sourceTextView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (nonatomic) BOOL animatingToolbar;
@property (nonatomic) BOOL isToolbarVisible;
@property (nonatomic, weak) IBOutlet UIView *actionToolbar;
@property (nonatomic, weak) IBOutlet UIButton *customActionButton;

@property (nonatomic, weak) IBOutlet UIButton *webViewBackButton;
@property (nonatomic, weak) IBOutlet UIButton *webViewForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *webViewReloadButton;
@property (nonatomic, weak) IBOutlet UIView *webViewControlsContainer;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) BOOL showFullDiscussionView;
@property (nonatomic) BOOL showScreenCaptureView;

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, weak, nullable) PSPDFViewController *pspdfViewController;

@end

@implementation CSGWebDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard {
    CSGWebDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    if ([self isNotSubmission:submission] || [self isDummySubmission:submission]) {
        return NO;
    }
    
    return  [self isOnlineTextEntry:submission] ||
    [self isOnlineURL:submission] ||
    [self isOnlineQuiz:submission] ||
    [self isDiscussionEntry:submission] ||
    [self isAcceptableBoxRenderUpload:submission attachment:attachment] ||
    [self isAcceptableLocalRenderUpload:submission attachment:attachment];
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGWebDocumentViewController *webDocumentViewController = (CSGWebDocumentViewController *)[self instantiateFromStoryboard];

    webDocumentViewController.submissionRecord = submissionRecord;
    webDocumentViewController.submission = submission;
    webDocumentViewController.attachment = attachment;
    
    return webDocumentViewController;
}

#pragma mark - Can Handle Submission attachment

+ (BOOL)isNotSubmission:(CKISubmission *)submission
{
    return !submission;
}

+ (BOOL)isDummySubmission:(CKISubmission *)submission
{
    return submission.attempt == 0;
}

+ (BOOL)isOnlineTextEntry:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeOnlineTextEntry;
}

+ (BOOL)isOnlineURL:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeOnlineURL;
    return NO;
}

+ (BOOL)isOnlineUpload:(CKISubmission *)submission {
    return submission.type == CKISubmissionEnumTypeOnlineUpload;
}

+ (BOOL)isDiscussionEntry:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeDiscussion;
}

+ (BOOL)isOnlineQuiz:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeQuiz;
}

+ (BOOL)isAcceptableBoxRenderUpload:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([self isOnlineUpload:submission]) {
        NSArray *acceptableFileTypes = [self supportedBoxRenderFileTypes];
        NSString *fileExtension = attachment.name.pathExtension;
        return [acceptableFileTypes containsObject:fileExtension];
    }
    
    return NO;
}

+ (BOOL)isAcceptableLocalRenderUpload:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([self isOnlineUpload:submission]) {
        NSArray *acceptableFileTypes = [self supportedLocalRenderFileTypes];
        NSString *fileExtension = attachment.name.pathExtension;
        return [acceptableFileTypes containsObject:fileExtension];
    }
    
    return NO;
}

+ (NSArray *)supportedBoxRenderFileTypes {
    return @[@"doc", @"docx", @"pdf"];
}

+ (NSArray *)supportedLocalRenderFileTypes {
    // These are the only supported file types listed here: https://developer.apple.com/library/ios/qa/qa1630/_index.html
    // More file types are supported such as all text files, but for now lets just allow files with these extensions and the ones we support syntax highlighting.
    NSArray *supportedWebViewFileTypes = @[@"key.zip", @"numbers.zip", @"pages.zip", @"ppt", @"pptx", @"xls", @"xlsx", @"rtf", @"rtfd.zip", @"pages", @"numbers", @"key", @"txt"];
    return [supportedWebViewFileTypes arrayByAddingObjectsFromArray:[NSAttributedString supportedSyntaxHighlightFileExtensions]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    
    self.showFullDiscussionView = NO;
    self.showScreenCaptureView = YES;
    
    [self setupView];
    [self loadCachedFilesIfNecessary];
    [self reloadView];
}



# pragma mark - View Setup
- (void)setupView {
    self.webView.opaque = YES;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.alpha = 0.0f;
    
    self.sourceTextView.alpha = 0.0f;
    
    [self setupToolbarView];
}

- (void)setupToolbarView {
    self.actionToolbar.backgroundColor = [UIColor whiteColor];
    self.actionToolbar.layer.shadowColor = RGB(212, 212, 208).CGColor;
    self.actionToolbar.layer.shadowOffset = CGSizeMake(0, -1);
    self.actionToolbar.layer.shadowOpacity = 1.0;
    self.actionToolbar.layer.shadowRadius = 1.0;
}

- (void)setupDiscussionToolbar {
    [self showUserDiscussion];
}

- (void)setupOnlineTextEntryToolbar {
    if ([CSGWebDocumentViewController shouldSyntaxHighlightSubmission:self.submission attachment:self.attachment]) {
        [self showSourceView];
    } else {
        [self showWebView];
    }
}

- (void)setupOnlineURLToolbar {
    [self showURLImage];
}

- (void)setupSyntaxHighlightToolbar {
    if ([CSGWebDocumentViewController shouldSyntaxHighlightSubmission:self.submission attachment:self.attachment]) {
        [self showSourceView];
    } else {
        [self showWebView];
    }
}

- (void)setupNoToolbar {
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self setToolbarVisible:NO animated:NO completion:nil];
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:NO animated:NO finished:nil];
}

- (void)setupRACBindings {
    // if either the file or submission change, lets verify if we can toggle source
    @weakify(self);
    [RACObserve(self, attachment) subscribeNext:^(id x) {
        @strongify(self);
        self.customActionButton.alpha = [CSGWebDocumentViewController canSyntaxHighlightSubmission:self.submission attachment:self.attachment];
    }];
    [RACObserve(self, submission) subscribeNext:^(id x) {
        @strongify(self);
        self.customActionButton.alpha = [CSGWebDocumentViewController canSyntaxHighlightSubmission:self.submission attachment:self.attachment];
    }];
}

- (void)showSourceView {
    [self.customActionButton setTitle:@"Show Web" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showWebViewPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:NO animated:NO finished:nil];
    [self setView:self.sourceTextView visible:YES animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:NO animated:NO finished:nil];
}

- (void)showWebView {
    [self.customActionButton setTitle:@"Show Source" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showSourceViewPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:NO animated:NO finished:nil];
}

- (void)showFullDiscussion {
    [self.customActionButton setTitle:@"Show User Submissions" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showUserDiscussionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:YES animated:NO finished:nil];
}

- (void)showUserDiscussion {
    [self.customActionButton setTitle:@"Show Full Discussions" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showFullDiscussionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:NO animated:NO finished:nil];
}

- (void)showURLImage {
    [self.customActionButton setTitle:@"Show Web" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showURLSubmissionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:NO animated:NO finished:nil];
}

- (void)showURLSubmission {
    [self.customActionButton setTitle:@"Show Screen Capture" forState:UIControlStateNormal];
    [self.customActionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.customActionButton addTarget:self action:@selector(showURLImagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setView:self.webView visible:YES animated:NO finished:nil];
    [self setView:self.sourceTextView visible:NO animated:NO finished:nil];
    
    [self setView:self.webViewControlsContainer visible:YES animated:NO finished:nil];
    [self reloadWebViewControls];
}

# pragma mark - IBActions

- (IBAction)webViewBackPressed:(id)sender {
    [self.webView goBack];
    [self reloadWebViewControls];
}
- (IBAction)webViewForwardPressed:(id)sender {
    [self.webView goForward];
    [self reloadWebViewControls];
}
- (IBAction)webViewReloadPressed:(id)sender {
    [self.webView reload];
}

#pragma mark Syntax Highlight
- (IBAction)showSourceViewPressed:(id)sender {
    DDLogInfo(@"SHOW SOURCE VIEW PRESSED");
    [CSGWebDocumentViewController setUserSettingShouldShowSource:YES];
    [self showSourceView];
}
- (IBAction)showWebViewPressed:(id)sender {
    DDLogInfo(@"SHOW WEB VIEW PRESSED");
    [CSGWebDocumentViewController setUserSettingShouldShowSource:NO];
    [self showWebView];
}

#pragma mark Discussion Handling
- (IBAction)showFullDiscussionPressed:(id)sender {
    DDLogInfo(@"SHOW FULL DISCUSSION PRESSED");
    self.showFullDiscussionView = YES;
    [self showFullDiscussion];
    
    [self reloadWebViewControls];
    [self reloadWebView];
}
- (IBAction)showUserDiscussionPressed:(id)sender {
    DDLogInfo(@"SHOW USER DISCUSSION PRESSED");
    self.showFullDiscussionView = NO;
    [self showUserDiscussion];
    
    [self reloadWebView];
}

#pragma mark URL Handling
- (IBAction)showURLImagePressed:(id)sender {
    DDLogInfo(@"SHOW URL IMAGE PRESSED");
    self.showScreenCaptureView = YES;
    [self showURLImage];
    
    [self reloadWebView];
}
- (IBAction)showURLSubmissionPressed:(id)sender {
    DDLogInfo(@"SHOW URL SUBMISSION PRESSED");
    self.showScreenCaptureView = NO;
    [self showURLSubmission];
    
    [self reloadWebViewControls];
    [self reloadWebView];
}

# pragma mark - Reload Data Methods
- (void)reloadView {
    [self reloadWebView];
    [self reloadToolbar];
}

- (void)reloadWebViewControls {
    if ([CSGWebDocumentViewController isDiscussionEntry:self.submission]) {
        self.webViewBackButton.enabled = ([self.webView canGoBack] && ![self.webView.request.URL isEqual:self.dataSource.assignment.discussionTopic.htmlURL]);
    } else {
        self.webViewBackButton.enabled = [self.webView canGoBack];
    }

    self.webViewForwardButton.enabled = [self.webView canGoForward];
}

- (void)reloadToolbar {
    [self setToolbarVisible:[CSGWebDocumentViewController shouldDisplayToolbar:self.submission attachment:self.attachment] animated:NO completion:nil];
    if ([CSGWebDocumentViewController isDiscussionEntry:self.submission]) {
        [self setupDiscussionToolbar];
    } else if ([CSGWebDocumentViewController isOnlineTextEntry:self.submission]) {
        [self setupOnlineTextEntryToolbar];
    } else if ([CSGWebDocumentViewController isOnlineURL:self.submission]) {
        [self setupOnlineURLToolbar];
    } else if ([CSGWebDocumentViewController canSyntaxHighlightSubmission:self.submission attachment:self.attachment]) {
        [self setupSyntaxHighlightToolbar];
    } else {
        [self setupNoToolbar];
    }
}

- (void)reloadWebView {
    NSURLRequest *urlRequest = nil;
    
    if ([CSGWebDocumentViewController isAcceptableBoxRenderUpload:self.submission attachment:self.attachment]) {
        DDLogInfo(@"BOX RENDER SUBMISSION");
        [self loadAttachmentPreviewURLWithRedirect];
        return;
    } else if ([CSGWebDocumentViewController isAcceptableLocalRenderUpload:self.submission attachment:self.attachment]) {
        DDLogInfo(@"LOCAL RENDER SUBMISSION");
        urlRequest = [NSURLRequest requestWithURL:self.attachment.url];
        
        NSURLSessionDownloadTask *downloadTask = [[TheKeymaster currentClient] downloadTaskWithRequest:urlRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", self.submission.id, [response suggestedFilename]]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [self.webView loadData:[NSData dataWithContentsOfURL:filePath] MIMEType:response.MIMEType textEncodingName:[response textEncodingName] baseURL:[NSURL new]];
            self.cachedAttachmentURL = filePath;
        }];
        
        [downloadTask resume];
        return;
    } else if ([CSGWebDocumentViewController isOnlineURL:self.submission]) {
        DDLogInfo(@"URL SUBMISSION");
        if (self.showScreenCaptureView) {
            urlRequest = [NSURLRequest requestWithURL:self.attachment.url];
        } else {
            urlRequest = [NSURLRequest requestWithURL:self.submission.url];
        }
    } else if ([CSGWebDocumentViewController isOnlineTextEntry:self.submission]) {
        DDLogInfo(@"ONLINE TEXT SUBMISSION");
        urlRequest = [NSURLRequest requestWithURL:[self.submission urlForLocalTextEntryHTMLFile]];
    } else if ([CSGWebDocumentViewController isDiscussionEntry:self.submission]) {
        DDLogInfo(@"DISCUSSION SUBMISSION");
        if (self.showFullDiscussionView) {
            DDLogInfo(@"FULL DISCUSSION");
            urlRequest = [NSURLRequest requestWithURL:self.dataSource.assignment.discussionTopic.htmlURL];
        } else {
            DDLogInfo(@"USER DISCUSSION");
            urlRequest = [NSURLRequest requestWithURL:[self.submission urlForLocalDiscussionEntriesHTMLFile]];
        }
    } else if ([CSGWebDocumentViewController isOnlineQuiz:self.submission]) {
        DDLogInfo(@"QUIZ SUBMISSION");
        urlRequest = [NSURLRequest requestWithURL:self.submission.previewURL];
    }
    
    
    DDLogInfo(@"WEB SUBMISSION URL: %@", [urlRequest.URL absoluteString]);
    
    [self.webView loadRequest:urlRequest];
}

- (void)loadAttachmentPreviewURLWithRedirect {
    NSString *previewURLPath = [self.attachment.previewURLPath substringFromIndex:1];
    
    // redirect hackyness
    CKIClient *baseClient = [[TheKeymaster currentClient] copy];
    [baseClient setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [baseClient setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [baseClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [TheKeymaster currentClient].accessToken] forHTTPHeaderField:@"Authorization"];
    [baseClient GET:previewURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // successful load doesn't actually mean anything except the redirect happened
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // TODO: notify user of failure
    }];
    
    // capture the redirect URL and display it \o/
    @weakify(self);
    [baseClient setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
        @strongify(self);
        
        if ([self.attachment.previewURLPath containsString:@"api/v1/canvadoc_session"]) {
            // YAY, let's do the new awesome annotations
            self.webView.hidden = YES;
            
            NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
            
            // the url looks like this: https://canvadocs-edge.insops.net/1/sessions/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjIjoxNDQ2MTM5NTY4MjgxLCJkIjoiTlA4UUdIbFAtTUNoSW9wLTdJVjY4WTFTUnh1QkRNIiwiZSI6MTQ0NjE0MzE2OCwiYSI6eyJjIjoiZGVmYXVsdCIsInAiOiJyZWFkd3JpdGUiLCJ1IjoxMDAwMDAwNjExMjAyMCwibiI6ImJrcmF1cyt0ZWFjaEBpbnN0cnVjdHVyZS5jb20iLCJyIjoiIn0sImlhdCI6MTQ0NjEzOTU2OH0.zLTb6VN4yyh-GGBhOXuflNYFwzz0tv5ucDOiBYuz3vE/view?theme=dark
            // so we need to knock off the query params and the /view from the path
            components.query = nil;
            components.path = components.path.stringByDeletingLastPathComponent;
            
            NSURL *goodURL = components.URL;
            if (goodURL != nil) {
                // NEW ANNOTATIONS FTW!
                [CanvadocsPDFDocumentPresenter loadPDFViewController:goodURL with:[AppAnnotationsConfiguration canvasAndSpeedgraderConfig] completed:^(UIViewController *pdfViewController, NSArray *errors) {
                    if (pdfViewController != nil) {
                        if (self.pspdfViewController) {
                            [self.pspdfViewController.view removeFromSuperview];
                            [self.pspdfViewController removeFromParentViewController];
                        }
                        
                        self.pspdfViewController = (PSPDFViewController *)pdfViewController;
                        
                        [self addChildViewController:pdfViewController];
                        [self.view addSubview:pdfViewController.view];
                        [pdfViewController didMoveToParentViewController:self];
                        pdfViewController.view.frame = self.view.bounds;
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
                        
                        if ([pdfViewController isKindOfClass:[PSPDFViewController class]] && [self.submissionRecord.id isEqualToString:self.dataSource.selectedSubmissionRecord.id]) {
                            ((PSPDFViewController *)pdfViewController).annotationToolbarController.annotationToolbar.toolbarDelegate = self;
                        }
                    }
                }];
            } else {
                // WTF Happened!
            }
            return nil;
        } else {
            // Sigh, this doc is older and can't be supported with the new stuff
            self.webView.hidden = NO;
            [self.webView loadRequest:request];
            return nil;
        }
    }];
    
}

- (void)loadCachedFilesIfNecessary {
    if ([CSGWebDocumentViewController canSyntaxHighlightSubmission:self.submission]) {
        NSString *sourceText = self.submission.body;
        NSString *plistName = [NSAttributedString plistMappingForFileExtension:@"html"];
        NSDictionary *highlightDefinition = [NSAttributedString highlightDefinitionWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
        
        self.sourceTextView.attributedText = [NSAttributedString highlightText:sourceText font:nil defaultColor:nil hightlightDefinition:highlightDefinition theme:nil];
        return;
    }
    
    // for now lets just pull the files down if we can syntax highlight.  If not we'll just render them normally
    if (![CSGWebDocumentViewController canSyntaxHighlightAttachment:self.attachment]) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.attachment.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    
    NSURLSessionDownloadTask *downloadTask = [[TheKeymaster currentClient] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *sourceText = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSString *fileExtension = filePath.pathExtension;
        NSString *plistName = [NSAttributedString plistMappingForFileExtension:fileExtension];
        NSDictionary *highlightDefinition = [NSAttributedString highlightDefinitionWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
        
        self.sourceTextView.attributedText = [NSAttributedString highlightText:sourceText font:nil defaultColor:nil hightlightDefinition:highlightDefinition theme:nil];
    }];
    
    [downloadTask resume];
}

#pragma mark - UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([CSGWebDocumentViewController isOnlineQuiz:self.submissionRecord]) {
        // example url: http://staging.instructure.com/courses/24219/quizzes/11085/history?headless=1&score_updated=1&user_id=242528&version=7
        NSDictionary *parameters = [[request URL] queryParameters];
        NSString *updatedScore = [parameters objectForKey:@"score_updated"];
        if (updatedScore) {
            [self updateQuizScoreFromAPI];
        }
    }
    if ([CSGWebDocumentViewController isAcceptableBoxRenderUpload:self.submission attachment:self.attachment]) {
        BOOL authTokenIsPresent = [[request allHTTPHeaderFields] objectForKey:@"Authorization"] != nil;
        if(authTokenIsPresent) {
            return YES;
        }
        
        [self reloadWebViewWithAuthenticatedRequest:request];
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error.description);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self reloadWebViewControls];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
        return;
    }
    
    if ([CSGWebDocumentViewController isDiscussionEntry:self.submission]) {
        [self runjs:@"var divsToHide = document.getElementsByClassName('author');for(var i = 0; i<divsToHide.length; i++){divsToHide[i].innerHTML='Anonymous';}"];
    } else if ([CSGWebDocumentViewController isOnlineQuiz:self.submission]) {
        [self runjs:@"var divsToHide = document.getElementsByClassName('quiz-header');for(var i = 0; i<divsToHide.length; i++){divsToHide[i].style.visibility='hidden';}"];
    }
}

- (void)reloadWebViewWithAuthenticatedRequest:(NSURLRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [request URL];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request addValue:[NSString stringWithFormat:@"Bearer %@", [TheKeymaster currentClient].accessToken] forHTTPHeaderField:@"Authorization"];
        [self.webView loadRequest:request];
    });
}

#pragma mark - Helper Methods

- (void)runjs:(NSString *)code {
    @try {
        if (self.webView) {
            [self.webView stringByEvaluatingJavaScriptFromString: code];
        }
    } @catch (NSException *exception) {
        NSLog(@"Caught Exception: %@", exception);
    }
}

- (void)updateQuizScoreFromAPI {
    [[[TheKeymaster currentClient] updateModel:self.submissionRecord parameters:nil] subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        [self.dataSource replaceSubmissionRecord:self.submissionRecord withSubmissionRecord:submissionRecord];
        self.submissionRecord = submissionRecord;
    }];
}

#pragma mark - Toolbar Visiblity
+ (BOOL)shouldDisplayToolbar:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    return [self isDiscussionEntry:submission] ||
            [self isOnlineTextEntry:submission] ||
            [self isOnlineURL:submission] ||
            [self canSyntaxHighlightSubmission:submission attachment:attachment];
}

#pragma mark - Source Code

+ (BOOL)shouldSyntaxHighlightSubmission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    BOOL canSyntaxHighlight = [self canSyntaxHighlightSubmission:submission attachment:attachment];
    BOOL userSettingShouldShowSource = [self userSettingShouldShowSource];
    
    return canSyntaxHighlight && userSettingShouldShowSource;
}

+ (BOOL)canSyntaxHighlightSubmission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    return [CSGWebDocumentViewController canSyntaxHighlightSubmission:submission] || [CSGWebDocumentViewController canSyntaxHighlightAttachment:attachment];
}

+ (BOOL)canSyntaxHighlightSubmission:(CKISubmission *)submission {
    return [CSGWebDocumentViewController isOnlineTextEntry:submission];
}

+ (BOOL)canSyntaxHighlightAttachment:(CKIFile *)file
{
    NSString *fileName = file.name;
    NSString *fileExtension = fileName.pathExtension;

    static NSArray *supportedExtensions = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        supportedExtensions = [NSAttributedString supportedSyntaxHighlightFileExtensions];
    });

    return [supportedExtensions containsObject:fileExtension];
}

+ (BOOL)userSettingShouldShowSource {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CSGUserPrefsShowSourceCode];
}

+ (void)setUserSettingShouldShowSource:(BOOL)showSource {
    [[NSUserDefaults standardUserDefaults] setBool:showSource forKey:CSGUserPrefsShowSourceCode];
}

- (void)setView:(UIView *)view visible:(BOOL)visible animated:(BOOL)animated finished:(AnimationBlock)completion{
    CGFloat alpha = visible ? 1.0 : 0.0;
    NSTimeInterval duration = animated ? CSGWebDocumentControllerDefaultAnimationDuration : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [view setAlpha:alpha];
    } completion:^(BOOL finished) {
        if(completion && finished) {
            completion();
        }
    }];
}

- (void)setToolbarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.animatingToolbar) {
        if(completion){
            completion(NO);
        }
        return;
    }
    
    self.toolbarBottomConstraint.constant = visible ? 0 : -self.actionToolbar.frame.size.height;
    [self.view setNeedsUpdateConstraints];
    
    if (animated) {
        self.animatingToolbar = YES;
        
        [UIView animateWithDuration:CSGWebDocumentControllerDefaultAnimationDuration animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.animatingToolbar = NO;
            self.isToolbarVisible = visible;
            if (completion) {
                completion(YES);
            }
        }];
    } else {
        [self.view layoutIfNeeded];
        
    }
    
}

- (NSArray *)additionalBarButtons {
    if (self.pspdfViewController.annotationButtonItem) {
        return @[self.pspdfViewController.annotationButtonItem];
    }
    return @[];
}

- (void)flexibleToolbarWillShow:(PSPDFFlexibleToolbar *)toolbar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCShouldCaptureTouch object:nil];
}

- (void)flexibleToolbarWillHide:(PSPDFFlexibleToolbar *)toolbar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCShouldNotCaptureTouch object:nil];
}

@end
