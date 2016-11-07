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
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import <CanvasKit1/CKAlertViewWithBlocks.h>
#import <CanvasKit1/CKAudioCommentRecorderView.h>

#import "ScheduleItemController.h"
#import "ScheduleItem.h"
#import "PopoverWrapperViewController.h"
#import "ReceivedFilesViewController.h"
#import "RubricViewController.h"
#import "UIWebView+iCanvas.h"
#import "VideoRecorderController.h"
#import "WebBrowserViewController.h"
#import "PopoverWrapperViewController.h"
#import "ThreadedDiscussionViewController.h"
#import "ReceivedFilesViewController.h"
#import "UIWebView+SafeAPIURL.h"
#import "Router.h"
#import <CanvasKit1/CKURLRouter.h>

#import "CKCanvasAPI+RealmAssignmentBridge.h"
#import "CKIClient+CBIClient.h"
#import "CKRichTextInputView.h"
@import CanvasKit;
@import SoPretty;
@import CanvasKeymaster;

#define TOP_INSET 64
#define BOTTOM_INSET 80

@interface ScheduleItemController() <UIWebViewDelegate, UIPopoverControllerDelegate, CKCommentViewControllerDelegate, UIAlertViewDelegate, CKRichTextInputViewDelegate> {
    CKSubmission *currentSubmission;
    CKAssignment *currentAssignment;
    
    UIPopoverController *popover;
    WebBrowserViewController *webBrowserController;
    CGRect showSubmissionsButtonRect;
    CGRect showCommentsButtonRect;
    CGRect showRubricButtonRect;
    CGRect showSpeedGraderButtonRect;
    CGRect showOverridesButtonRect;
    
    __weak CKActionSheetWithBlocks *actionSheet;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
    
    __weak IBOutlet UIToolbar *progressToolbar;
    __weak IBOutlet UIProgressView *progressView;
    UILabel *progressCompleteLabel;
    UILabel *submittingLabel;
    UIActivityIndicatorView *submittingSpinner;
    
    CKAudioCommentRecorderView *audioRecorder;
    CKRichTextInputView *richTextInputView;
    CKCommentViewController *commentController;
}

@property (nonatomic, strong) IBOutlet UIWebView *theWebView;

@property (strong) UIAlertView *appStoreAlert;
@property (strong) NSArray *assignmentOverrides;
@property (strong, nonatomic) NSString *syllabus;
@property (strong, nonatomic) ScheduleItem *rootItem;

@end

@implementation ScheduleItemController

@synthesize theWebView;
@synthesize appStoreAlert;


#pragma mark - View lifecycle

- (id)init
{
    return [[UIStoryboard storyboardWithName:@"ScheduleItemController" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    progressCompleteLabel = [self addProgressViewLabelWithText:NSLocalizedString(@"Submission complete", nil)];
    
    submittingLabel = [self addProgressViewLabelWithText:NSLocalizedString(@"Submitting...", nil)];
    CGSize fittingSize = [submittingLabel sizeThatFits:submittingLabel.bounds.size];
    CGFloat labelRightEdge = submittingLabel.center.x + (fittingSize.width / 2.0);
    submittingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    submittingSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGFloat width = submittingSpinner.bounds.size.width;
    CGFloat bufferSize = 6;
    submittingSpinner.center = CGPointMake(labelRightEdge + (width / 2.0) + bufferSize, submittingLabel.center.y);
    [progressToolbar addSubview:submittingSpinner];
    
    
    // Set up date formatters for the assignment details page. Do it here to improve speed a bit.
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    theWebView.delegate = self;
    
    if (self.rootItem) {
        [self loadDetailsForScheduleItem:self.rootItem];
    } else if (self.syllabus) {
        [self loadDetailsForSyllabus:self.syllabus];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (UILabel *)addProgressViewLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:progressToolbar.bounds];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.0;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [progressToolbar addSubview:label];
    return label;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([popover isPopoverVisible]) {
        CGRect targetRect = CGRectZero;
        // Ick ick ick... this needs a serious refactor
        if ([popover.contentViewController isKindOfClass:[PopoverWrapperViewController class]] ||
            [popover.contentViewController isKindOfClass:[UIImagePickerController class]]) {
            showSubmissionsButtonRect = [theWebView rectForElementInWebviewWithId:@"show-submissions-form"];
            if (CGRectIsEmpty(showSubmissionsButtonRect)) {
                showSubmissionsButtonRect = [theWebView rectForElementInWebviewWithId:@"submit-form"];
            }
            targetRect = showSubmissionsButtonRect;
        }
        else if ([popover.contentViewController isKindOfClass:[CKCommentViewController class]]) {
            showCommentsButtonRect = [theWebView rectForElementInWebviewWithId:@"show-comments-form"];
            targetRect = showCommentsButtonRect;
        }
        else {
            showRubricButtonRect = [theWebView rectForElementInWebviewWithId:@"show-rubric-form"];
            targetRect = showRubricButtonRect;
        }
        [popover presentPopoverFromRect:targetRect inView:theWebView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    if (actionSheet) {
        showSubmissionsButtonRect = [theWebView rectForElementInWebviewWithId:@"show-submissions-form"];
        if (CGRectIsEmpty(showSubmissionsButtonRect)) {
            showSubmissionsButtonRect = [theWebView rectForElementInWebviewWithId:@"submit-form"];
        }
        [actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        [actionSheet showFromRect:showSubmissionsButtonRect inView:theWebView animated:YES];
    }
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Item and Initial Content Path selection


// We pass in both the submission and assignment because the submission could be nil,
// which would mean that we couldn't pull the assignment out of it
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission
{
    
    // Start with a blank string
    NSString *gradeString = @"";
    
    NSString *pointsPossible = [NSString stringWithFormat:@"%g", assignment.pointsPossible];
    
    // If we have pointsPossible, add that
    if (pointsPossible.length > 0) {
        gradeString = [NSString stringWithFormat:NSLocalizedString(@"out of %@", @"The assignment is out of 100 points"),pointsPossible];
    }
    
    // If we have a submission, we might add more to the string
    if (submission) {
        NSString *grade = submission.grade;
        
        // If we have a grade, let's add it to the string. If not, leave it alone
        if (grade.length > 0) {
            switch (assignment.scoringType) {
                case CKAssignmentScoringTypePoints:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@ out of %@", @"88 out of 100 points"),grade,pointsPossible];
                    break;
                case CKAssignmentScoringTypePercentage:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@%% (%g out of %@)", @"83% (83 out of 100 points"),grade,submission.score,pointsPossible];
                    break;
                    
                case CKAssignmentScoringTypePassFail:
                case CKAssignmentScoringTypeLetter:
                    gradeString = [NSString stringWithFormat:NSLocalizedString(@"%@ (%g out of %@)", @"B- (83 out of 100 points"),grade,submission.score,pointsPossible];
                    break;
                default:
                    
                    break;
            }
        }
    }
    
    return gradeString;
}

- (void)updateDisplayWithAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission {
    
    BOOL isStudent = [self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeStudent];
    
    NSString *gradeString = [ScheduleItemController gradeStringForAssignment:assignment andSubmission:submission];
    
    
    // Show submission info and update grade
    [theWebView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"setGradeBlockHTML(\"%@\", 0)" ,gradeString]];
    
    // Reset all forms, showing only as needed
    [theWebView stringByEvaluatingJavaScriptFromString:@"hideAllForms();"];
    
    // Toggle rubric form
    if (submission.assignment.rubric) {
        [theWebView stringByEvaluatingJavaScriptFromString:
         @"showFormWithId('show-rubric-form');"];
    }
    
    // Toggle submission form
    if (isStudent &&
        (assignment.submissionTypes & CKSubmissionTypeOnlineUpload ||
         assignment.submissionTypes & CKSubmissionTypeMediaRecording ||
         assignment.submissionTypes & CKSubmissionTypeOnlineTextEntry ||
         assignment.submissionTypes & CKSubmissionTypeOnlineURL)) {
            
            if (submission.lastAttempt != nil) {
                [theWebView stringByEvaluatingJavaScriptFromString:
                 @"showFormWithId('show-submissions-form');"];
            }
            else {
                [theWebView stringByEvaluatingJavaScriptFromString:
                 @"showFormWithId('submit-form');"];
            }
        }
    else if (submission.lastAttempt.type == CKSubmissionTypeOnlineQuiz) {
        // Only show the button for a quiz if they've actually submitted something
        [theWebView stringByEvaluatingJavaScriptFromString:
         @"showFormWithId('show-submissions-form');"];
    }
    
    if (isStudent && assignment.type == CKAssignmentTypeQuiz) {
        [theWebView stringByEvaluatingJavaScriptFromString:
         @"showFormWithId('show-quiz-form')"];
    }
    
    // Toggle the SpeedGrader button
    // This should only show for Teachers and TAs enrolled in the current course
    // and it should only show if there are assignments that need to be graded
    if ([self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTeacher] || [self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTA]) {
        [theWebView stringByEvaluatingJavaScriptFromString:
         @"showFormWithId('show-speedgrader-form');"];
    }
    
    // Toggle the Go to discussion button
    if (assignment.type == CKAssignmentTypeDiscussion) {
        [theWebView stringByEvaluatingJavaScriptFromString:
         @"showFormWithId('show-discussion-form');"];
    }
    
    // Toggle comments form, but download comments first if necessary.
    {
        void (^commentUpdateBlock)(CKSubmission *) = ^ (CKSubmission *theSubmission) {
            if ([self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeStudent]) {
                [theWebView stringByEvaluatingJavaScriptFromString:
                 @"showFormWithId('show-comments-form');"];
            }
        };
        
        if (submission.comments) {
            commentUpdateBlock(submission);
        }
        else if (submission) {
            CKCanvasAPI *canvasAPI = self.canvasAPI;
            [canvasAPI getCommentsForSubmission:submission block:^(NSError *error, BOOL isFinalValue, NSArray *theComments) {
                submission.comments = theComments;
                commentUpdateBlock(submission);
            }];
        }
    }
    
    // Toggle multiple overrides link
    if (self.assignmentOverrides == nil) {
        [self.canvasAPI getOverridesForCourseIdent:self.course.ident assignmentIdent:assignment.ident pageURL:nil block:^(NSError *error, NSArray *theArray, CKPaginationInfo *pagination) {
            self.assignmentOverrides = theArray;
            if (self.assignmentOverrides.count > 0) {
                
                [theWebView stringByEvaluatingJavaScriptFromString:@"showFormWithId('multiple-due-dates');"];
                [theWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('due').style.display='none'"];
            }
        }];
    }
}

- (void)loadDetailsForSyllabus:(NSString *)syllabusBody
{
    self.syllabus = syllabusBody;
    self.rootItem = nil;
    if (theWebView == nil) {
        return;
    }
    NSString *pathToTemplateFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"SyllabusDetails" ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:[pathToTemplateFile stringByDeletingLastPathComponent] isDirectory:YES];
    NSError *error = nil;
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:pathToTemplateFile encoding:NSUTF8StringEncoding error:&error];
    
    NSString *scrubbedHTML = [htmlTemplate stringByReplacingOccurrencesOfString:@"{$TITLE$}" withString:self.course.name];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$COURSE_CODE$}" withString:self.course.courseCode];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$CONTENT$}" withString:syllabusBody];
    
    theWebView.dataDetectorTypes = UIDataDetectorTypeAll;
    [theWebView loadHTMLString:scrubbedHTML baseURL:baseURL];
}

- (void)loadDetailsForScheduleItem:(ScheduleItem *)item
{
    self.rootItem = item;
    self.syllabus = nil;
    if (theWebView == nil) {
        return;
    }
    if (item.type == CNVScheduleItemTypeAssignment) {
        currentAssignment = item.itemObject;
    }
    
    // TODO: make an HTML template for assignment pages. Then load the appropriate content into the template for displaying in the webview
    NSString *pathToTemplateFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"ScheduleItemDetails" ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:[pathToTemplateFile stringByDeletingLastPathComponent] isDirectory:YES];
    NSError *error = nil;
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:pathToTemplateFile encoding:NSUTF8StringEncoding error:&error];
    
    // Item Title
    
    NSString *itemTitle = item.title ?: @"";
    NSString *scrubbedHTML = [htmlTemplate stringByReplacingOccurrencesOfString:@"{$TITLE$}" withString:itemTitle];
    
    // Event Date
    
    NSString *eventDateString = nil;
    
    NSDate *eventDate = item.eventDate;
    if (eventDate) {
        NSString *formattedDate = [dateFormatter stringFromDate:eventDate];
        NSString *formattedTime = [timeFormatter stringFromDate:eventDate];
        
        if (CNVScheduleItemTypeAssignment == item.type) {
            eventDateString = [NSString stringWithFormat:NSLocalizedString(@"due on %@ at %@",@"Assignment is due on a date at a time"),formattedDate,formattedTime];
        }
        else if (CNVScheduleItemTypeCalendar == item.type) {
            eventDateString = [NSString stringWithFormat:NSLocalizedString(@"%@ at %@",@"Event happens on a date at a time"),formattedDate,formattedTime];
        }
        else {
            eventDateString = @"";
        }
    }
    else {
        eventDateString = @"";
    }
    
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$DUE_DATE$}" withString:eventDateString];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$OTHER_DUE_DATES$}" withString:NSLocalizedString(@"Multiple Due Dates", @"Title of a link to show additional due dates customized for sections or groups.")];
    
    // Item Description
    
    NSString *itemDescription = item.itemDescription ?: @"";
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$CONTENT$}" withString:itemDescription];
    
    // Button Labels
    
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$SUBMISSION$}"  withString:NSLocalizedString(@"Submission", @"View previously submitted assignment")];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$SUBMIT$}"      withString:NSLocalizedString(@"Submit", @"Submit an assignment")];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$RUBRIC$}"      withString:NSLocalizedString(@"Rubric", @"View grading rubric")];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$COMMENTS$}"    withString:NSLocalizedString(@"Comments", @"View comments")];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$SPEEDGRADER$}" withString:NSLocalizedString(@"Grade in SpeedGrader", @"Launch the SpeedGrader app")];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$DISCUSSION$}"  withString:NSLocalizedString(@"Go to discussion", nil)];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$QUIZ$}" withString:NSLocalizedString(@"Go to Quiz", @"text for the \"go to quiz\" button")];
    
    NSInteger gradingCount = currentAssignment.needsGradingCount;
    NSString *gradingCountStr = [NSString stringWithFormat:@"%zd", gradingCount];
    if (gradingCount == 0) {
        gradingCountStr = @"";
    }
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$SPEEDGRADER_COUNT$}" withString:gradingCountStr];
    
    self.assignmentOverrides = nil;
    
    theWebView.dataDetectorTypes = UIDataDetectorTypeLink;
    [theWebView loadHTMLString:scrubbedHTML baseURL:baseURL];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURLRequest *request = webView.request;
    if ([request.URL.scheme isEqualToString:@"file"]) {
        CKCanvasAPI *canvasAPI = self.canvasAPI;
        ScheduleItem *selectedItem = self.rootItem;
        if ([selectedItem isKindOfClass:[ScheduleItem class]]) {
            if (selectedItem.type == CNVScheduleItemTypeAssignment) {
                [canvasAPI getSubmissionForAssignment:currentAssignment
                                            studentID:self.canvasAPI.user.ident
                                       includeHistory:NO
                                                block:^(NSError *error, BOOL isLiveValue, CKSubmission *submission)
                 {
                     if (selectedItem.itemObject == self.rootItem.itemObject) {
                         currentSubmission = submission;
                         [self updateDisplayWithAssignment:currentAssignment andSubmission:currentSubmission];
                     }
                 }];
                
            }
        }
    }
    
    [webView replaceHREFsWithAPISafeURLs];
}

#pragma mark -

- (void)updateProgressViewWithProgress:(float)progress {
    if (progressToolbar.hidden) {
        progressToolbar.hidden = NO;
        progressToolbar.alpha = 0.0;
        [UIView animateWithDuration:0.4 animations:^{
            progressView.alpha = 1.0;
            progressToolbar.alpha = 1.0;
            progressCompleteLabel.alpha = 0.0;
            
            submittingSpinner.alpha = 0.0;
            submittingLabel.alpha = 0.0;
        }];
    }
    [progressView setProgress:progress animated:YES];
}

- (void)updateProgressViewWithIndeterminateProgress {
    if (progressToolbar.hidden) {
        progressToolbar.hidden = NO;
        progressToolbar.alpha = 0.0;
        [UIView animateWithDuration:0.4 animations:^{
            progressView.alpha = 0.0;
            progressCompleteLabel.alpha = 0.0;
            
            progressToolbar.alpha = 1.0;
            submittingLabel.alpha = 1.0;
            submittingSpinner.alpha = 1.0;
        }];
    }
    [submittingSpinner startAnimating];
}

- (void)transitionToUploadCompletedWithError:(NSError *)error {
    double messageDisplayTime = 2.0;
    
    if (error) {
        progressCompleteLabel.text = [error localizedDescription];
        progressCompleteLabel.textColor = [UIColor prettyErrorColor];
        messageDisplayTime = 5.0;
    }
    else {
        progressCompleteLabel.text = NSLocalizedString(@"Submission complete", nil);
        progressCompleteLabel.textColor = [UIColor whiteColor];
    }
    [submittingSpinner stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        progressToolbar.alpha = 1.0; // In case it was previously hidden
        progressView.alpha = 0.0;
        progressCompleteLabel.alpha = 1;
        submittingSpinner.alpha = 0.0;
        submittingLabel.alpha = 0.0;
    }];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, messageDisplayTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:0.4 animations:^{
            progressToolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
            progressToolbar.hidden = YES;
            progressView.progress = 0.0;
        }];
    });
}

// This is a static function so that it can be called from a completion
// block even if the controller has been dealloc'd
static void showErrorForAssignment(NSError *error, CKAssignment *assignment) {
    UIApplication *application = [UIApplication sharedApplication];
    
    NSString *template = NSLocalizedString(@"Upload to assignment \"%@\" failed", @"Error message");
    NSString *message = [NSString stringWithFormat:template, assignment.name];
    if (application.applicationState == UIApplicationStateBackground) {
        UILocalNotification *note = [UILocalNotification new];
        note.alertBody = message;
        [application presentLocalNotificationNow:note];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:message
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)openSpeedGraderWithAssignment:(CKAssignment *)assignment
{
    [popover dismissPopoverAnimated:NO];
    
    // Grab the current course and assignment
    // Generate an open url
    NSURL *url = [CKURLRouter speedGraderOpenAssignmentURLWithCourse:self.course andAssignment:assignment];
    
    // Open the url
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        BOOL successful = [[UIApplication sharedApplication] openURL:url];
        if (successful == NO) {
            NSLog(@"Failed to open the assignment in SpeedGrader. Course id: %qu. Assignment id: %qu", self.course.ident, assignment.ident);
        }
    }
    else {
        // Display a message to the user that they can download SpeedGrader for iPad from the App Store. We could even let them go there.
        appStoreAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need SpeedGrader for iPad",@"Title notifying user that SpeedGrader is available for iPad")
                                                   message:NSLocalizedString(@"You do not have SpeedGrader for iPad. You can download it for free from the App Store.", @"Message in an alert")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Later", @"Button in an alert")
                                         otherButtonTitles:NSLocalizedString(@"Go to App Store", @"Action on an alert"), nil];
        [appStoreAlert show];
    }
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if ([request.URL.scheme isEqualToString:@"file"]) {
        return YES;
    }
    
    if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    
    [[Router sharedRouter] routeFromController:self toURL:request.URL];
    
    return NO;
}

- (void)displayAttachment:(CKAttachment *)attachment
{
    if (attachment && [attachment isStreamingItem] == NO) {
        CKCanvasAPI *canvasAPI = self.canvasAPI;
        [canvasAPI getURLForAttachment:attachment block:^(NSError *error, BOOL isFinalValue, NSURL *theURL) {
            
            // Todo: add error handling
            webBrowserController = [[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
            [webBrowserController setUrl:theURL];
            self.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:webBrowserController animated:YES completion:NULL];
        }];
    }
    else {
        // This means it is a quiz or media file, which has a remote URL
        NSURL *urlToUse = [attachment isMedia] ? [attachment directDownloadURL] : [[currentSubmission lastAttempt] previewURL];
        
        if (urlToUse) {
            webBrowserController = [[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
            [webBrowserController setUrl:urlToUse];
            self.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:webBrowserController animated:YES completion:NULL];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    popover.delegate = nil;
    audioRecorder = nil;
    richTextInputView = nil;
    commentController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    if ((richTextInputView && richTextInputView.isEmpty == NO) ||
        audioRecorder || commentController.hasPendingContent) {
        CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:nil
                                                                            message:NSLocalizedString(@"Discard this entry?", nil)];
        
        [alert addButtonWithTitle:NSLocalizedString(@"Discard", nil) handler:^{
            [popoverController dismissPopoverAnimated:YES];
        }];
        [alert addCancelButtonWithTitle:NSLocalizedString(@"Keep", nil)];
        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark CKCommentViewControllerDelegate

- (void)commentViewController:(id)sender didSelectAttachment:(CKCommentAttachment *)attachment
{
    [self displayAttachment:attachment];
    [popover dismissPopoverAnimated:YES];
}

#pragma mark - CKRichTextInputViewDelegate

- (void)resizeRichTextInputViewToHeight:(CGFloat)height {
    CGSize size = popover.contentViewController.preferredContentSize;
    size.height = height;
    popover.popoverContentSize = size;
}

- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray *)attachments andCompletionBlock:(CKSimpleBlock)block {
    CKCanvasAPI *canvasAPI = self.canvasAPI;
    CKAssignment *assignment = currentAssignment;
    
    [inputView dismissKeyboard];
    
    __weak ScheduleItemController *weakSelf = self;
    
    [self updateProgressViewWithIndeterminateProgress];
    [canvasAPI postHTML:comment asSubmissionForAssignment:assignment session:TheKeymaster.currentClient.authSession
        completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
            if (error) {
                showErrorForAssignment(error, assignment);
            }
            ScheduleItemController *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf->popover dismissPopoverAnimated:NO];
                strongSelf->currentSubmission = submission;
                [strongSelf updateDisplayWithAssignment:assignment andSubmission:submission];
                [strongSelf transitionToUploadCompletedWithError:error];
            }
            block(error, YES);
        }];
}

@end
