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

#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit/CKIAssignment.h>
#import "LTIViewController.h"
#import "ThreadedDiscussionViewController.h"
#import "CBISubmissionInputViewController.h"
#import "Router.h"
#import "CKIClient+CBIClient.h"
#import "CKRichTextInputView.h"
#import "MobileQuizInformationViewController.h"

@import CanvasKeymaster;

@interface SubmissionWorkflowController () <CKRichTextInputViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) UIViewController *viewController;
@property CKAudioCommentRecorderView *audioRecorder;

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

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && self.cancelAction) {
        self.cancelAction();
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && self.continueToQuizAction) {
        self.continueToQuizAction();
    } else if (buttonIndex == 2) {
        [MobileQuizInformationViewController presentFromViewController:self.viewController];
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:message delegate:self cancelButtonTitle:cancelButtonText otherButtonTitles:continueButtonText, moreInfoButtonText, nil];
        
        [alert show];
        return;
    } else if (self.legacyAssignment.type == CKAssignmentTypeDiscussion) {
        ThreadedDiscussionViewController *controller = [[ThreadedDiscussionViewController alloc] init];
        controller.canvasAPI = self.canvasAPI;
        controller.topicIdent = (uint64_t)[self.assignment.discussionTopic.id integerValue];
        controller.contextInfo = self.contextInfo;
        [controller performSelector:@selector(fetchTopic:) withObject:@YES];
        
        [self.viewController.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    CKSubmissionType submissionTypes = self.legacyAssignment.submissionTypes;
    
    // __builtin_popcount returns the number of bits set in the binary rep of the int.
    // Surprisingly, there's not a simpler thing in the C standard to do this.
    int numberOfPossibleTypes = __builtin_popcount(submissionTypes);
    
    if (numberOfPossibleTypes > 1) {
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't submit media", @"Setup only allows media but no Kaltura instance error title")
                                                                    message:NSLocalizedString(@"Your school's configuration does not allow the type of submission selected for this assignment", @"Media submission type selected with no Kaltura set up")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                          otherButtonTitles:nil];
                    [alert show];
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
                if (self.legacyAssignment.url == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't load tool", @"Invalid LTI tool error title")
                                                                    message:NSLocalizedString(@"This assignment doesn't appear to be a valid external tool or is misconfigured.", @"Invalid LTI tool error message")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Dismiss",nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                    break;
                }
                
                LTIViewController *lti = [[LTIViewController alloc] init];
                CKIExternalTool *externalTool = [CKIExternalTool modelWithID:[NSString stringWithFormat: @"%lld", self.legacyAssignment.ident]];
                externalTool.name = self.legacyAssignment.name;
                externalTool.url = self.legacyAssignment.url;
                lti.externalTool = externalTool;
                [self.viewController.navigationController pushViewController:lti animated:YES];
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
                             showErrorForAssignment(error, assignment);
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
                    showErrorForAssignment(error, assignment);
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
                   showErrorForAssignment(error, assignment);
               }
               
               [weakSelf reportCompletionWithSubmission:submission error:error];
           }];
    }];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)showSubmissionLibrary {
    
    ReceivedFilesViewController *controller = [[ReceivedFilesViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [self.viewController presentViewController:controller animated:YES completion:nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    controller.onSubmitBlock = ^(NSArray *urls) {
        
        CKAssignment *assignment = self.legacyAssignment;
        
        for (NSURL *url in urls) {
            if (![assignment allowsExtension:[url pathExtension]]) {
                CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:[assignment notAllowedAlertTitle:[url pathExtension]]
                                                                                    message:[assignment notAllowedAlertMessage]];
                
                [alert addCancelButtonWithTitle:NSLocalizedString(@"OK", nil)];
                [alert show];
                
                [application endBackgroundTask:backgroundTask];
                return;
            }
        }
        
        CKCanvasAPI *canvasAPI = self.canvasAPI;
        [weakSelf reportProgress:0.0];
        [canvasAPI postFileURLs:urls asSubmissionForAssignment:assignment
                  progressBlock:^(float progress) {
                      [weakSelf reportProgress:progress];
                  }
                completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                    if (error) {
                        showErrorForAssignment(error, assignment);
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
                showErrorForAssignment(error, assignment);
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
