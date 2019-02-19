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
    
    

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "CKCanvasAPI.h"
#import "CKCommentViewController.h"
#import "CKSubmissionComment.h"
#import "CKCommentAttachment.h"
#import "CKStylingButton.h"
#import "CKTextCommentInputView.h"
#import "CKMediaCommentRecorderView.h"
#import "CKSubmission.h"
#import "CKUser.h"

typedef enum {
    CKCommentInputModeText,
    CKCommentInputModeMedia,
} CKCommentInputMode;


NSString *CKCommentsViewHeightDidChangeNotification = @"CKCommentsViewHeightDidChangeNotification";

#define MIN_WEBVIEW_HEIGHT 0.0
#define MAX_WEBVIEW_HEIGHT_PORTRAIT 715.0
#define MAX_WEBVIEW_HEIGHT_LANDSCAPE 480.0

@interface CKCommentViewController ()  <UIWebViewDelegate,UIDocumentInteractionControllerDelegate> 
{
    CKCommentInputMode commentInputMode;
    CKMediaCommentMode preferredMediaCommentMode;
    NSMutableDictionary *commentAttachments;
}
@property (nonatomic, strong) IBOutlet UIView *commentsContainerView;
@property (nonatomic, strong) IBOutlet UIWebView *commentsView;
@property (nonatomic, strong) IBOutlet UIView *formContainerView;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, weak) CKSubmission *displayedSubmission;

@property (nonatomic, strong) CKTextCommentInputView *textInputView;
@property (nonatomic, strong) CKMediaCommentRecorderView *recorderView;

@property (nonatomic, strong) UIView *keyboardMaskBackground;

@property (nonatomic) BOOL htmlIsLoaded;
@property BOOL visible;

- (void)loadBaseHTMLForComments;
- (CGFloat)computedViewHeight;
- (void)resizeFormContainer;
- (NSString *)javaScriptStringForComment:(CKSubmissionComment *)comment;
- (void)expandMediaComment:(CKCommentAttachment *)attachment;
- (CGFloat)maxWebViewHeightForInterfaceOrientation:(UIInterfaceOrientation)orientation;
@end

static void * MediaCommentFrameContext = &MediaCommentFrameContext;

@implementation CKCommentViewController

@synthesize commentsContainerView, commentsView, commentsHeight, submission, displayedSubmission, htmlIsLoaded, delegate;
@synthesize progressView, placeholderActivityView, visible;
@synthesize formContainerView;
@synthesize textInputView;
@synthesize recorderView;
@synthesize canvasAPI;
@synthesize keyboardMaskBackground;

- (id)init {
    return [self initWithNibName:@"CommentView" bundle:[NSBundle bundleForClass:[self class]]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDidRotateFromInterfaceOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // Don't slide the keyboard on the iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    
    // Hacky way to hide the shadows from the webview when we scroll. Note that this
    // does not use a private API but it is kind of fragile, so it might break in the future.
    // You can see that I made it as defensive as I could. Borrowed from
    // http://stackoverflow.com/questions/2238914/how-to-remove-grey-shadow-on-the-top-uiwebview-when-overscroll
    if ([commentsView.subviews count] > 0) {
        id scroller = (commentsView.subviews)[0];
        if ([scroller isKindOfClass:[UIScrollView class]]) {
            for (UIView *subview in [scroller subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    subview.hidden = YES;
                }
            }
        }
    }
    
    commentsView.delegate = self;
    commentAttachments = [[NSMutableDictionary alloc] init];
    
    self.recorderView = [[CKMediaCommentRecorderView alloc] init];
    self.textInputView = [[CKTextCommentInputView alloc] init];
    
    [self.textInputView.flipToMediaCommentButton addTarget:self action:@selector(flipInputPanel:) forControlEvents:UIControlEventTouchUpInside];
    [self.textInputView.postTextCommentButton addTarget:self action:@selector(tappedPostTextCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recorderView.flipToTextCommentButton addTarget:self action:@selector(flipInputPanel:) forControlEvents:UIControlEventTouchUpInside];
    [self.recorderView.postMediaCommentButton addTarget:self action:@selector(tappedPostMediaCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recorderView addObserver:self
                        forKeyPath:@"frame"
                           options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                           context:MediaCommentFrameContext];
    
    [self.formContainerView addSubview:self.textInputView];
    commentInputMode = CKCommentInputModeText;
    
    commentsView.backgroundColor = [UIColor clearColor];
    [self loadBaseHTMLForComments];
    [self resizeCommentsPopover:nil];
    
    preferredMediaCommentMode = self.recorderView.mode;
    NSAssert(preferredMediaCommentMode != 0, @"Preferred comment mode should always be non-zero");
    
    // Set up a  nice background for text entry on the iPhone.
    // It's alpha is zero for now. It will be changed when the keyboard is shown/hidden.
    self.keyboardMaskBackground = [[UIView alloc] initWithFrame:self.view.bounds];
    self.keyboardMaskBackground.backgroundColor = [UIColor blackColor];
    self.keyboardMaskBackground.alpha = 0.0;
    [self.view insertSubview:self.keyboardMaskBackground belowSubview:self.formContainerView];
}

- (void)resizeFormContainer {
    UIView *formView = nil;
    if (commentInputMode == CKCommentInputModeMedia) {
        formView = self.recorderView;
    }
    else {
        formView = self.textInputView;
    }
    
    CGSize newSize = formView.frame.size;
    CGRect frame = formContainerView.frame;
    frame.origin.y = CGRectGetMaxY(frame) - newSize.height;
    frame.size.height = newSize.height;
    formContainerView.frame = frame;
}

- (void)resizeCommentsPopover:(NSNotification *)note
{
    [self resizeFormContainer];
    
    CGFloat newHeight = [self computedViewHeight];
    
    CGSize newSize = CGSizeMake(self.formContainerView.frame.size.width, newHeight);
    self.preferredContentSize = newSize;
    
    CGRect newCommentsFrame = commentsContainerView.frame;
    newCommentsFrame.size.height = self.view.bounds.size.height - CGRectGetHeight(formContainerView.frame);
    newCommentsFrame.origin.y = 0;
    commentsContainerView.frame = newCommentsFrame;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)noteDidRotateFromInterfaceOrientation:(NSNotification *)note {
    NSNumber *from = [note userInfo][UIApplicationStatusBarOrientationUserInfoKey];
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [self didRotateFromInterfaceOrientation:[from intValue]];
#pragma GCC diagnostic pop
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.recorderView rotateVideoToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    [self resizeCommentsPopover:nil];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillUnload {
    [super viewWillUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // We only register for these in the iPhone version
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
    [self.recorderView removeObserver:self forKeyPath:@"frame" context:MediaCommentFrameContext];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.htmlIsLoaded = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // We only register for these in the iPhone version
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
    [self.recorderView removeObserver:self forKeyPath:@"frame" context:MediaCommentFrameContext];
    [self.submission removeObserver:self forKeyPath:@"comments" context:CommentsObservationContext];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.visible = YES;
    if (submission == displayedSubmission && self.htmlIsLoaded) {
        [self scrollCommentsViewToBottom:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (submission != displayedSubmission) {
        if (self.htmlIsLoaded) {
            [self reloadIfVisible];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.visible = NO;
}

static void *CommentsObservationContext = &CommentsObservationContext;
- (void)setSubmission:(CKSubmission *)aSubmission {
    [self->submission removeObserver:self forKeyPath:@"comments" context:CommentsObservationContext];
    
    self->submission = aSubmission;
    [self reloadIfVisible];
    
    [self->submission addObserver:self forKeyPath:@"comments" options:0 context:CommentsObservationContext];
}

#pragma mark -
#pragma mark Adding Comments

- (void)loadBaseHTMLForComments
{
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"CKcomments" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSString *bundlePath = [htmlPath stringByDeletingLastPathComponent];
    [commentsView loadHTMLString:html baseURL:[NSURL fileURLWithPath:bundlePath]];
}

- (void)reloadIfVisible
{
    if (self.visible) {
        [self reload];
    }
}


- (IBAction)flipInputPanel:(id)sender
{
    UIView *viewToRemove = nil;
    UIView *viewToAdd = nil;
    UIViewAnimationOptions transitionToUse;
    
    if (commentInputMode == CKCommentInputModeText) {
        commentInputMode = CKCommentInputModeMedia;
        viewToRemove = self.textInputView;
        viewToAdd = self.recorderView;
        viewToAdd.frame = self.formContainerView.bounds;
        transitionToUse = UIViewAnimationOptionTransitionFlipFromRight;
        
        [self.recorderView setMode:CKMediaCommentModeAudio animated:NO];
        [UIView transitionWithView:self.formContainerView duration:0.8 options:transitionToUse animations:^(void) {
            [self.formContainerView insertSubview:viewToAdd belowSubview:viewToRemove];
            [viewToRemove removeFromSuperview];
            [self resizeCommentsPopover:nil];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self.recorderView setMode:preferredMediaCommentMode];
                             } completion:NULL];
        }];
    }
    else { //if (commentInputMode == CKCommentInputModeMedia) {
        commentInputMode = CKCommentInputModeText;
        viewToRemove = self.recorderView;
        viewToAdd = self.textInputView;
        transitionToUse = UIViewAnimationOptionTransitionFlipFromLeft;
        preferredMediaCommentMode = self.recorderView.mode;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.recorderView setMode:CKMediaCommentModeAudio];
                         } completion:^(BOOL finished) {
                             [UIView transitionWithView:self.formContainerView duration:1.0 options:transitionToUse animations:^(void) {
                                 [self.formContainerView insertSubview:viewToAdd belowSubview:viewToRemove];
                                 [viewToRemove removeFromSuperview];
                                 [self resizeCommentsPopover:nil];
                             } completion:NULL];
                         }];
    }
    

}


#pragma mark -
#pragma mark Displaying Attachments

- (void)selectAttachmentWithId:(NSString *)attachmentId {
    CKCommentAttachment *theAttachment = commentAttachments[attachmentId];
    if ([delegate respondsToSelector:@selector(commentViewController:didSelectAttachment:)]) {
        [delegate commentViewController:self didSelectAttachment:theAttachment];
    }
}

#pragma mark -
#pragma mark Displaying Comments

- (void)reload:(id)obj
{
    [self reload];
}

- (void)reload
{
    // Get rid of the placeholder spinning from posting media comments, if it is there
    [self.placeholderActivityView stopAnimating];
    
    self.displayedSubmission = self.submission;
    
    // Stop any playing videos
    [self.commentsView stringByEvaluatingJavaScriptFromString:@"stopAllMedia();"];
    
    //Clear out stale comments
    [self.commentsView stringByEvaluatingJavaScriptFromString:@"document.getElementById('comments').innerHTML = \"\";"];
    
    // Clear comment attachment mapping
    [commentAttachments removeAllObjects];
    
    for (CKSubmissionComment *comment in self.submission.comments) {
        [self loadComment:comment];
    }
    
    [self setCommentsHeightFromJavascript];
}

- (void)loadComment:(CKSubmissionComment *)comment {
    NSString *commentJavascript = [self javaScriptStringForComment:comment];
    NSString *javascript = [NSString stringWithFormat:@"addComment(%@);", commentJavascript];
    [self.commentsView stringByEvaluatingJavaScriptFromString:javascript];
    
    // TODO: clean this up later. We loop through the attachments here and in javaScriptStringForComment
    for (CKCommentAttachment *attachment in comment.attachments) {
        if ([attachment isMedia]) {
            [self expandMediaComment:attachment];
        }
    }
}

- (NSString *)javaScriptStringForComment:(CKSubmissionComment *)comment {
    NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterTime = [[NSDateFormatter alloc] init];
    [dateFormatterDate setDateFormat:@"MMM d"];
    [dateFormatterTime setTimeStyle:NSDateFormatterShortStyle];
    NSString *createdAt = [NSString stringWithFormat:@"%@, %@",
                           [dateFormatterDate stringFromDate:comment.createdAt],
                           [dateFormatterTime stringFromDate:comment.createdAt]];
    
    NSMutableArray *attachmentInfoArray = [NSMutableArray array];
    BOOL commentContainsMediaAttachment = NO;
    for (CKCommentAttachment *attachment in comment.attachments) {
        if ([attachment isMedia]) {
            commentContainsMediaAttachment = YES;
        }
        commentAttachments[attachment.internalIdent] = attachment;
        [attachmentInfoArray addObject:[attachment dictionaryValue]];
    }
    
    BOOL isMe = comment.authorIdent == self.canvasAPI.user.ident ? YES : NO;
    
    // If the media comment is less than three minutes old, append a message to the body about kaltura processing
    NSString *footer = @"";
    if (commentContainsMediaAttachment && [comment.createdAt timeIntervalSinceNow] > -180) {
        footer = [NSString stringWithFormat:@"<br><br>%@",NSLocalizedString(@"Note: Media files are not immediately available for playback while they are processed on the server.",nil)];
    }
    
    NSDictionary *commentInfo = @{@"createdAt": createdAt,
                                 @"author": comment.author.displayName,
                                 @"body": comment.body,
                                 @"footer": footer,
                                 @"attachments": attachmentInfoArray,
                                 @"isMe": @(isMe)};
    
    NSError *error;
    NSString *commentJSON;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"Error getting json data from dictionary: %@", error);
    } else {
        commentJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return commentJSON;
}

- (void)expandMediaComment:(CKCommentAttachment *)attachment
{
    [self.canvasAPI getURLForAttachment:attachment block:
     ^(NSError *error, BOOL done, NSURL *url) {
         if (done && self.visible) {
             if ([attachment isMedia]) {
                 
                 NSError *error;
                 NSString *attachmentJSON;
                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[attachment dictionaryValue] options:NSJSONWritingPrettyPrinted error:&error];
                 if (! jsonData) {
                     NSLog(@"Error getting json data from dictionary: %@", error);
                 } else {
                     attachmentJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                 }
                 
                 [self.commentsView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadThumbnailForMediaAttachment(%@,'%@')", attachmentJSON, [url absoluteString]]];
             }
         }
     }];
}

- (void)setCommentsHeightFromJavascript
{
    NSString *commentsHeightString = [self.commentsView stringByEvaluatingJavaScriptFromString:@"document.getElementById('comments').offsetHeight"];
    self.commentsHeight = [commentsHeightString floatValue];
    
    // Tells the CommentsPopover to resize
    [self resizeCommentsPopover:nil];
    
    [self scrollCommentsViewToBottom:NO];
}

- (CGFloat)maxWebViewHeightForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ? MAX_WEBVIEW_HEIGHT_PORTRAIT : MAX_WEBVIEW_HEIGHT_LANDSCAPE;
}

- (void)scrollCommentsViewToBottom:(BOOL)force
{
    CGFloat maxWebviewHeight = [self maxWebViewHeightForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (self.commentsHeight > maxWebviewHeight || force) {
        [self.commentsView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0, document.body.scrollHeight);"];
    }
}

- (CGFloat)computedViewHeight
{
    CGFloat margin = 0.0f;
    
    CGFloat heightToUseForComments = 0.0f;
    CGFloat maxWebviewHeight = [self maxWebViewHeightForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (self.commentsHeight < MIN_WEBVIEW_HEIGHT) {
        heightToUseForComments = MIN_WEBVIEW_HEIGHT;
    }
    else if (self.commentsHeight > maxWebviewHeight) {
        heightToUseForComments = maxWebviewHeight;
    }
    else {
        heightToUseForComments = self.commentsHeight;
    }
    
    // add in the height of the input panel at the bottom
    CGFloat inputPanelHeight = self.formContainerView.frame.size.height;
    
    CGFloat totalHeight = margin + heightToUseForComments + inputPanelHeight;
    return totalHeight;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == MediaCommentFrameContext) {
        [self resizeCommentsPopover:nil];
    }
    else if (context == CommentsObservationContext) {
        [self reloadIfVisible];
    }
}

#pragma mark - Posting

- (BOOL)hasPendingContent {
    if (commentInputMode == CKCommentInputModeText) {
        NSString *text = textInputView.inputCommentTextView.text;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return (text.length > 0);
    }
    else {
        NSAssert(commentInputMode == CKCommentInputModeMedia, @"Unhandled comment input mode");
        return recorderView.recordedFileURL != nil;
    }
}

- (IBAction)tappedPostMediaCommentButton:(id)sender
{
    // Grab the path to the recorded file, depending on the mode of the media panel
    NSString *pathToUse = nil;
    CKAttachmentMediaType mediaTypeToUse = CKAttachmentMediaTypeUnknown;
    if (self.recorderView.mode == CKMediaCommentModeAudio) {
        pathToUse = self.recorderView.recordedFileURL.path;
        mediaTypeToUse = CKAttachmentMediaTypeAudio;
    }
    else {
        pathToUse = [self.recorderView.recordedFileURL path];
        mediaTypeToUse = CKAttachmentMediaTypeVideo;
    }
    
    if (!pathToUse || mediaTypeToUse == CKAttachmentMediaTypeUnknown) {
        // This means that they tried to submit a media comment without actually recording anything
        return;
    }
    
    [self.recorderView stopAllMedia];
    
    CKSubmission *updatedSubmission = self.submission;
    
    [self.canvasAPI postMediaCommentAtPath:pathToUse ofMediaType:mediaTypeToUse block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
        
        [self.canvasAPI postComment:@"" mediaId:mediaId mediaType:mediaType forSubmission:updatedSubmission block:^(NSError *error, BOOL done, CKSubmission *newSubmission) {
            if (error) {
                NSLog(@"There was an error when submitting the media comment:\n%@",error);
            }
            if (done) {
                [self.recorderView clearRecordedMedia];
                if (self.visible && updatedSubmission.ident == self.submission.ident) {
                    if ([delegate respondsToSelector:@selector(commentViewController:didPostNewAttachmentForSubmission:)]) {
                        [delegate commentViewController:self didPostNewAttachmentForSubmission:submission];
                    } else {
                        // If the delegate doesn't implement the above method, we'll just update it ourselves.
                        [self reloadIfVisible];
                    }
                }
            }
        }];
    }];
    
    
    // Put a placeholder comment with an activity indicator. This will get replaced in the postMediaComment block when it redraws the comments for the submission
    CKSubmissionComment *placeholderComment = [[CKSubmissionComment alloc] initPlaceholdCommentWithSubmission:self.submission user:self.canvasAPI.user];
    placeholderComment.authorName = NSLocalizedString(@"Me", nil);
    [self loadComment:placeholderComment];
    [self setCommentsHeightFromJavascript];
    [self scrollCommentsViewToBottom:YES];
    
    [self.placeholderActivityView startAnimating];
    
    // Put the video screen back into preview mode (not playback mode)
    if (self.recorderView.mode == CKMediaCommentModeVideo) {
        [self.recorderView tappedDonePlayingVideoButton:sender];
    }
}


- (IBAction)tappedPostTextCommentButton:(id)sender
{
    [self.textInputView.textCommentActivityView startAnimating];
    
    NSString *comment = self.textInputView.inputCommentTextView.text;
    
    self.textInputView.inputCommentTextView.text = @"";
    [self.textInputView.inputCommentTextView endEditing:YES];
    
    CKSubmission *updatedSubmission = self.submission;
    [self.canvasAPI postComment:comment
                                 mediaId:nil
                               mediaType:CKAttachmentMediaTypeUnknown
                           forSubmission:updatedSubmission
                                   block:^(NSError *error, BOOL done, CKSubmission *submission) {
                                       if (error) {
                                           NSLog(@"There was an error when submitting the comment:\n%@\n\n%@",error,comment);
                                       }
                                       // Make sure we only update if we're still on the same submission
                                       if (done) {
                                           [self.textInputView.textCommentActivityView stopAnimating];
                                           
                                           if (updatedSubmission.ident == self.submission.ident) {
                                               [self reload];
                                               if ([delegate respondsToSelector:@selector(commentViewController:didPostNewAttachmentForSubmission:)]) {
                                                   [delegate commentViewController:self didPostNewAttachmentForSubmission:updatedSubmission];
                                               }
                                           }
                                       }
                                   }];
}

                                

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"/"];
    
    if ([components count] > 1 && [components[0] isEqualToString:@"speedgrader:"]) {
        NSArray *methodComponents = [[components lastObject] componentsSeparatedByString:@":"];
        if ([methodComponents[0] isEqualToString:@"getAttachmentURLForAttachmentId"]) {
            // TODO: perform this on a different thread if it takes too long to process.
            [self selectAttachmentWithId:methodComponents[1]];
        }
        else if ([methodComponents[0] isEqualToString:@"setCommentsHeightFromJavascript"]) {
            [self setCommentsHeightFromJavascript];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.htmlIsLoaded = YES;
    [self performSelector:@selector(reloadIfVisible) withObject:nil afterDelay:0.0];
}

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification *)note
{
    // This notification isn't observed in the iPad version
    
    CGRect keyboardBounds;
    NSValue *keyboardBoundsValue = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    // Pull out the animation timing
    NSNumber *animationCurve = [note userInfo][UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [note userInfo][UIKeyboardAnimationDurationUserInfoKey];
    
    // Animate the view to move at the same time the keyboard does
    [UIView animateWithDuration:[animationDuration doubleValue] 
                          delay:0 
                        options:[animationCurve intValue] 
                     animations:
     ^ {         
         CGRect viewFrame =  self.view.frame;
         viewFrame.origin.y -= keyboardBounds.size.height * .75;
         self.view.frame = viewFrame;
         
         self.keyboardMaskBackground.alpha = 0.8;
     }
                     completion:
     ^(BOOL finished) {
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedDoneButton:)];
     }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    // This notification isn't observed in the iPad version
    
    CGRect keyboardBounds;
    NSValue *keyboardBoundsValue = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    // Pull out the animation timing
    NSNumber *animationCurve = [note userInfo][UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [note userInfo][UIKeyboardAnimationDurationUserInfoKey];
    
    // Animate the view to move at the same time the keyboard does
    [UIView animateWithDuration:[animationDuration doubleValue] 
                          delay:0 
                        options:[animationCurve intValue] 
                     animations:
     ^ {
         CGRect viewFrame =  self.view.frame;
         viewFrame.origin.y += keyboardBounds.size.height * .75;
         self.view.frame = viewFrame;
         
         self.keyboardMaskBackground.alpha = 0.0;
     }
                     completion:
     ^(BOOL finished) {
         self.navigationItem.rightBarButtonItem = nil;
     }];
    
}

- (void)tappedDoneButton:(id)sender
{
    [self.textInputView.inputCommentTextView resignFirstResponder];
}

@end
