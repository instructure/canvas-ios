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
    
    

#import "SubmissionWorkflowController.h"
#import "VideoRecorderController.h"
#import "URLSubmissionPreviewViewController.h"
#import "ReceivedFilesViewController.h"
#import "UIAlertController+TechDebt.h"
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit/CKIAssignment.h>
#import "CBISubmissionInputViewController.h"
#import "Router.h"
#import "CKIClient+CBIClient.h"
#import "CKRichTextInputView.h"
#import "MobileQuizInformationViewController.h"
#import "UIAlertController+TechDebt.h"

@import CanvasKeymaster;
@import CanvasCore;

@interface SubmissionWorkflowController () <CKRichTextInputViewDelegate>
@property (weak, nonatomic) UIViewController *viewController;
@property CKAudioCommentRecorderView *audioRecorder;
@property (copy, nonatomic, nullable) NSString *arcLTIToolID;

@property (copy) void (^continueToQuizAction)(void);
@property (copy) void (^cancelAction)(void);

@end

@implementation SubmissionWorkflowController

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)present {
    if (self.legacyAssignment.type == CKAssignmentTypeQuiz) {
        
        CKAssignment *assignment = self.legacyAssignment;
        UIViewController *vc = self.viewController;
        self.continueToQuizAction = ^(void) {
            NSURL *url = [TheKeymaster.currentClient.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/courses/%@/quizzes/%@", @(assignment.courseIdent), @(assignment.quizIdent)]];
            [[Router sharedRouter] routeFromController:vc toURL:url];
        };
        
        self.cancelAction = ^(void) {
        };
        NSString *alertTitle = NSLocalizedString(@"Quiz Alert", @"Title for alert notifying users that support for quizzes on mobile is limited.");
        NSString *message = NSLocalizedString(@"Currently there is limited quiz support on mobile", @"Message telling users that quiz support on mobile is limited");
        NSString *moreInfoButtonText = NSLocalizedString(@"More Info", @"Button title for selecting to view more info about the limitations of mobile quizzes");
        NSString *continueButtonText = NSLocalizedString(@"Continue", @"Button title for selecting to continue on to quiz. The will appear in the alert view notfifying the user of mobile quiz limitations.");
        NSString *cancelButtonText = NSLocalizedString(@"Cancel", @"Cancel button title");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:moreInfoButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MobileQuizInformationViewController presentFromViewController:self.viewController];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:continueButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.continueToQuizAction) {
                self.continueToQuizAction();
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:cancelButtonText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.cancelAction();
        }]];
        
        [self.viewController presentViewController:alert animated:YES completion:nil];
        
        return;
    } else if (self.legacyAssignment.type == CKAssignmentTypeDiscussion) {
        NSURL *url = [TheKeymaster.currentClient.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/courses/%@/discussion_topics/%@", @(self.legacyAssignment.courseIdent), @([self.assignment.discussionTopic.id integerValue])]];
        [[Router sharedRouter] routeFromController:self.viewController toURL:url];
        return;
    }
    
    CKSubmissionType submissionTypes = self.legacyAssignment.submissionTypes;
    
    // __builtin_popcount returns the number of bits set in the binary rep of the int.
    // Surprisingly, there's not a simpler thing in the C standard to do this.
    int numberOfPossibleTypes = __builtin_popcount(submissionTypes);
    
    NSString *canvasContext = @"";
    switch (self.contextInfo.contextType) {
        case CKContextTypeCourse:
            canvasContext = [NSString stringWithFormat:@"%@_%lld", @"course", self.contextInfo.ident];
            break;
        case CKContextTypeGroup:
            canvasContext = [NSString stringWithFormat:@"%@_%lld", @"group", self.contextInfo.ident];
            break;
        default:
            canvasContext = @"";
    }
    self.arcLTIToolID = [TheKeymaster.currentClient.authSession.enrollmentsDataSource arcLTIToolIdForCanvasContext:canvasContext];
    
    BOOL submissionTypesIncludesArc = (submissionTypes & CKSubmissionTypeOnlineUpload) && self.arcLTIToolID != nil;
    if (numberOfPossibleTypes > 1 || (numberOfPossibleTypes == 1 && submissionTypesIncludesArc)) {
        [self showSubmissionTypePicker];
    }
    else {
        switch (submissionTypes) {
            case CKSubmissionTypeOnlineUpload:
                [self showSubmissionLibrary];
                break;
                
            case CKSubmissionTypeMediaRecording: {
                if (self.allowsMediaSubmission) {
                    [self showMediaRecorderPicker];
                }
                else {
                    NSString *title = NSLocalizedString(@"Can't submit media", @"Setup only allows media but no Kaltura instance error title");
                    NSString *message = NSLocalizedString(@"Your school's configuration does not allow the type of submission selected for this assignment", @"Media submission type selected with no Kaltura set up");
                    [UIAlertController showAlertWithTitle:title message:message];
                }
                break;
            }
            case CKSubmissionTypeOnlineTextEntry:
                [self showTextInput];
                break;
                
            case CKSubmissionTypeOnlineURL:
                [self showURLInput];
                break;
            case CKSubmissionTypeExternalTool:
            {
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Can't load tool", nil)
                                                                                    message:NSLocalizedString(@"This assignment doesn't appear to be a valid external tool or is misconfigured.", nil)
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil];
                [errorAlert addAction:dismissAction];
                if (self.legacyAssignment.url == nil) {
                    [self.viewController presentViewController:errorAlert animated:YES completion:nil];
                    break;
                }

                Session *currentSession = TheKeymaster.currentClient.authSession;

                // Launch QuizzesNext in a WebView so that we can intercept the 'Return' button action.
                NSURL *externalToolTagAttributesURL = self.assignment.externalToolTagAttributes.url;
                if ([ExternalToolManager isQuizzesNext: externalToolTagAttributesURL] && self.legacyAssignment.courseIdent) {
                    [[ExternalToolManager shared] getSessionlessLaunchURLForLaunchURL:self.legacyAssignment.url in:currentSession completionHandler:^(NSURL * _Nullable url, NSString* _Nullable pageViewPath, NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error) {
                                [self.viewController presentViewController:errorAlert animated:YES completion:nil];
                                return;
                            }
                            if (url) {
                                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                                CanvasWebView *webView = [[CanvasWebView alloc] init];
                                CanvasWebViewController *controller = [[CanvasWebViewController alloc] initWithWebView:webView showDoneButton:YES showShareButton:YES];
                                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
                                [self.viewController presentViewController:nav animated:YES completion:^{
                                    [webView loadRequest:request];
                                }];
                                return;
                            }

                        });
                    }];

                    break;
                }
                
                if (self.legacyAssignment.name && self.legacyAssignment.url && self.legacyAssignment.courseIdent) {
                    NSString *courseID = [NSString stringWithFormat:@"%lld", self.legacyAssignment.courseIdent];
                    [[ExternalToolManager shared] launch:self.legacyAssignment.url
                                                      in:TheKeymaster.currentClient.authSession
                                                    from:self.viewController
                                                courseID:courseID
                                       completionHandler:nil];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)reportProgress:(float)progress {
    if (self.uploadProgressBlock) {
        self.uploadProgressBlock(progress);
    }
}

- (void)reportCompletionWithSubmission:(CKSubmission *)submission error:(NSError *)error {
    [self reportProgress:1.0];
    if (self.uploadCompleteBlock) {
        self.uploadCompleteBlock(submission, error);
    }
}

// This is a static function so that it can be called from a completion
// block even if the controller has been dealloc'd
static void showErrorForAssignment(NSError *error, NSString *assignmentName) {
    UIApplication *application = [UIApplication sharedApplication];
    
    NSString *template = NSLocalizedString(@"Upload to assignment \"%@\" failed", @"Error message");
    NSString *message = [NSString stringWithFormat:template, assignmentName];
    if (application.applicationState == UIApplicationStateBackground) {
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.body = message;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"assignment-upload-failure" content:content trigger:nil];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        [UIAlertController showAlertWithTitle:[error localizedDescription] message:message];
    }
}

static void deleteFiles(NSArray *fileURLs) {
    NSFileManager *fileManager = [NSFileManager new];
    for (NSURL *fileURL in fileURLs) {
        // If there's an error, we don't really care; it was probably
        // already gone. And this is just some tidy-up work; if somehow
        // we fail, the user can still delete it themselves.
        [fileManager removeItemAtURL:fileURL error:NULL];
    }
}

- (void)showSubmissionTypePicker {
    CKActionSheetWithBlocks *sheet = [[CKActionSheetWithBlocks alloc] initWithTitle:NSLocalizedString(@"Choose a submission type", nil)];
    
    CKSubmissionType submissionTypes = self.legacyAssignment.submissionTypes;
    
    if (submissionTypes & CKSubmissionTypeOnlineUpload) {
        [sheet addButtonWithTitle:NSLocalizedString(@"File upload", @"File upload submission type") handler:^{
            [self showSubmissionLibrary];
        }];
        
        if (self.arcLTIToolID.length > 0) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Arc", @"Assignment submission type for selecting an Arc video") handler:^{
                [self showArcPicker];
            }];
        }
    }
    if (submissionTypes & CKSubmissionTypeMediaRecording) {
        if (self.allowsMediaSubmission) {
            [sheet addButtonWithTitle:NSLocalizedString(@"Media recording", @"Media recording submission type") handler:^{
                [self showMediaRecorderPicker];
            }];
        }
    }
    if (submissionTypes & CKSubmissionTypeOnlineTextEntry) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Text entry", @"Text entry submission type") handler:^{
            [self showTextInput];
        }];
    }
    if (submissionTypes & CKSubmissionTypeOnlineURL) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Online URL", @"Online URL submission type") handler:^{
            [self showURLInput];
        }];
    }
    
    [sheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    if (self.viewController.tabBarController) {
        [sheet showFromTabBar:self.viewController.tabBarController.tabBar];
    }
    else {
        [sheet showInView:self.viewController.parentViewController.parentViewController.view];
    }
}

- (void)showMediaRecorderPicker {
    CKActionSheetWithBlocks *picker = [[CKActionSheetWithBlocks alloc] initWithTitle:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [picker addButtonWithTitle:NSLocalizedString(@"Record video", nil) handler:^{
            [self showVideoRecorderWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
    }
    [picker addButtonWithTitle:NSLocalizedString(@"Choose video", @"action sheet text for picking video from library") handler:^{
        [self showVideoRecorderWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [picker addButtonWithTitle:NSLocalizedString(@"Record audio", nil) handler:^{
        [self showAudioRecorder];
    }];
    [picker addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    if (self.viewController.tabBarController) {
        [picker showFromTabBar:self.viewController.tabBarController.tabBar];
    }
    else {
        [picker showInView:self.viewController.view.window];
    }
}

- (void)showVideoRecorderWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    __weak typeof(self) weakSelf = self;
    
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    VideoRecorderController *picker = [[VideoRecorderController alloc] initWithSourceType:sourceType Handler:^(NSURL *movieURL) {
        
        CKAssignment *assignment = self.legacyAssignment;
        [weakSelf reportProgress:0.0];
        [self.canvasAPI postMediaURL:movieURL asSubmissionForAssignment:assignment
                       progressBlock:^(float progress) {
                           [weakSelf reportProgress:progress];
                       }
                     completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                         if (error) {
                             showErrorForAssignment(error, assignment.name);
                         }
                         [weakSelf reportCompletionWithSubmission:submission error:error];
                         [application endBackgroundTask:backgroundTask];
                     }];
    }];
    picker.allowsEditing = YES;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:picker animated:YES completion:NULL];
}

- (void)showAudioRecorder {
    
    /// TODO: Unify duplicate code
    ///       CKAttachmentManager.m:239 and SubmissionWorkflowController.m:286
    CKAudioCommentRecorderView *audioRecorder = [[CKAudioCommentRecorderView alloc] init];
    CGFloat height = audioRecorder.bounds.size.height;
    CGRect frame = CGRectMake(0, 0, self.viewController.view.bounds.size.width, height);
    audioRecorder.frame = frame;
    
    CKOverlayViewController *overlay = [[CKOverlayViewController alloc] initWithView:audioRecorder];
    UIViewController *rootController = self.viewController.view.window.rootViewController;
    
    [audioRecorder.leftButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    audioRecorder.leftButton.hidden = NO;
    [audioRecorder.leftButton addTarget:rootController action:@selector(dismissOverlayController) forControlEvents:UIControlEventTouchUpInside];
    
    [audioRecorder.rightButton setTitle:NSLocalizedString(@"Use", nil) forState:UIControlStateNormal];
    audioRecorder.rightButton.hidden = NO;
    [audioRecorder.rightButton addTarget:self action:@selector(takeAudioFromRecorder) forControlEvents:UIControlEventTouchUpInside];
    
    self.audioRecorder = audioRecorder;
    
    [rootController presentOverlayController:overlay];
}

- (void)takeAudioFromRecorder {
    NSURL *audioURL = self.audioRecorder.recordedFileURL;
    
    if (!audioURL) {
        return;
    }
    
    
    [self.viewController.view.window.rootViewController dismissOverlayController];
    
    __weak typeof(self) weakSelf = self;
    
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    CKCanvasAPI *canvasAPI = self.canvasAPI;
    CKAssignment *assignment = self.legacyAssignment;
    [weakSelf reportProgress:0.0];
    
    [canvasAPI postMediaURL:audioURL asSubmissionForAssignment:assignment
              progressBlock:^(float progress) {
                  [weakSelf reportProgress:progress];
              }
            completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                if (error) {
                    showErrorForAssignment(error, assignment.name);
                }
                [weakSelf reportCompletionWithSubmission:submission error:error];
                [application endBackgroundTask:backgroundTask];
            }];
}

- (void)showTextInput {
    CBISubmissionInputViewController *textInput = [CBISubmissionInputViewController new];
    textInput.canvasAPI = self.canvasAPI;
    textInput.assignment = self.legacyAssignment;
    
    __weak typeof(self) weakSelf = self;
    textInput.submissionCompletionBlock = ^(CKSubmission *submission, NSError *error) {
        __strong typeof (weakSelf) self = weakSelf;
        [self reportCompletionWithSubmission:submission error:error];
    };
    [self.viewController presentViewController:textInput animated:YES completion:nil];
}

- (void)showURLInput {
    __weak typeof(self) weakSelf = self;
    
    CKCanvasAPI *canvasAPI = self.canvasAPI;
    CKAssignment *assignment = self.legacyAssignment;
    
    
    UIViewController *controller = [URLSubmissionPreviewViewController createWithSubmissionHandler:^(NSURL *url) {
        
        [weakSelf reportProgress:-1];
        [canvasAPI postURL:url asSubmissionForAssignment:assignment
           completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
               if (error) {
                   showErrorForAssignment(error, assignment.name);
               }
               
               [weakSelf reportCompletionWithSubmission:submission error:error];
           }];
    }];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)showArcPicker {
    NSString *contextType = @"";
    if (self.contextInfo.contextType == CKContextTypeCourse) {
        contextType = @"course";
    } else if (self.contextInfo.contextType == CKContextTypeGroup) {
        contextType = @"group";
    }
    
    NSString *contextID = [NSString stringWithFormat:@"%llu", self.contextInfo.ident];
    NSString *courseID = [NSString stringWithFormat:@"%llu", self.legacyAssignment.courseIdent];
    NSURL *url = [Assignment arcSubmissionLTILaunchURLWithSession:TheKeymaster.currentClient.authSession contextType:contextType contextID: contextID assignmentID:_assignment.id arcLTIToolID:self.arcLTIToolID];
    ArcVideoPickerViewController *picker = [[ArcVideoPickerViewController alloc] initWithArcLTIURL:url videoPickedAction:^(NSURL * _Nonnull url) {
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.instructure.TechDebt"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Confirm Submission", @"Localizable", bundle, @"Confirm an arc video submission for an assignment") message:NSLocalizedStringFromTableInBundle(@"Are you sure you want to submit this Arc video for this assignment?", @"Localizable", bundle, @"Confirmation alert text for submitting an Arc video for an assignment") preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = url.absoluteString;
            textField.userInteractionEnabled = NO;
        }];
        
        UIAlertAction *submitAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Submit", @"Localizable", bundle, @"Submit Arc video as assignment button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            [Submission submitArcSubmission:url session:TheKeymaster.currentClient.authSession courseID:courseID assignmentID:self.assignment.id completion:^(NSError * _Nullable error) {
                if (error != nil) {
                    showErrorForAssignment(error, _assignment.name);
                }
                
                if (self.uploadCompleteBlock) {
                    self.uploadCompleteBlock(nil, error);
                }

            }];
        }];
        [alert addAction:submitAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", bundle, @"Cancel button title to cancel submitting an Arc video as an assignment submission") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
        [self.viewController presentViewController:alert animated:YES completion:nil];
    }];
    [self.viewController.navigationController pushViewController:picker animated:YES];
}

- (void)showSubmissionLibrary {
    
    ReceivedFilesViewController *controller = [ReceivedFilesViewController presentReceivedFilesViewControllerFrom:self.viewController];
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    __weak typeof(self) weakSelf = self;
    controller.onSubmitBlock = ^(NSArray *urls) {
        
        CKAssignment *assignment = weakSelf.legacyAssignment;
        
        for (NSURL *url in urls) {
            if (![assignment allowsExtension:[url pathExtension]]) {
                [UIAlertController showAlertWithTitle:[assignment notAllowedAlertTitle:[url pathExtension]] message:[assignment notAllowedAlertMessage]];
                [application endBackgroundTask:backgroundTask];
                return;
            }
        }
        
        CKCanvasAPI *canvasAPI = weakSelf.canvasAPI;
        [weakSelf reportProgress:0.0];
        [canvasAPI postFileURLs:urls asSubmissionForAssignment:assignment
                  progressBlock:^(float progress) {
                      [weakSelf reportProgress:progress];
                  }
                completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                    if (error) {
                        showErrorForAssignment(error, assignment.name);
                    }
                    [weakSelf reportCompletionWithSubmission:submission error:error];
                    deleteFiles(urls);
                    
                    [application endBackgroundTask:backgroundTask];
                }];
        [weakSelf.viewController dismissViewControllerAnimated:YES completion:NULL];
    };
}

#pragma mark - CKRichTextInputDelegate

- (void)resizeRichTextInputViewToHeight:(CGFloat)height {
    // We're not doing resizing on this one.
}

- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray *)attachments andCompletionBlock:(CKSimpleBlock)block {
    
    CKCanvasAPI *canvasAPI = self.canvasAPI;
    CKAssignment *assignment = self.legacyAssignment;
    
    [inputView dismissKeyboard];
    
    __weak typeof(self) weakSelf = self;
    
    [self reportProgress:-1];
    [canvasAPI postHTML:comment asSubmissionForAssignment:assignment
        completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
            if (error) {
                showErrorForAssignment(error, assignment.name);
            }
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf reportCompletionWithSubmission:submission error:error];
            }
            block(error, YES);
        }];
    [self.viewController.view.window.rootViewController dismissOverlayController];
}

@end
