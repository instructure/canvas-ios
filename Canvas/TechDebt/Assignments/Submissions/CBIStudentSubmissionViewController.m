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
    
    

#import "CBIStudentSubmissionViewController.h"
#import "CBIStudentSubmissionViewModel.h"
#import "CBISubmissionCommentCell.h"
#import "SubmissionWorkflowController.h"
#import <CanvasKit1/CKCanvasAPI.h>
#import <CanvasKit1/CKContextInfo.h>
#import "EXTScope.h"
#import "CBIModuleProgressNotifications.h"
#import "CBIAddSubmissionCommentViewModel.h"
#import "CBISubmissionCommentViewModel.h"
#import "VideoRecorderController.h"
#import <CanvasKit1/CKSubmissionComment.h>
#import <CanvasKit1/CKMediaComment.h>
#import <CanvasKit1/CKAudioCommentRecorderView.h>
#import <CanvasKit1/CKOverlayViewController.h>
#import "CKCanvasAPI+CurrentAPI.h"
#import "CBILog.h"
#import "CKIClient+CBIClient.h"
#import "MobileQuizInformationViewController.h"
#import "Router.h"
#import "UIAlertController+TechDebt.h"

@import CanvasKeymaster;
@import CanvasCore;

typedef enum CBISubmissionState : NSUInteger {
    CBISubmissionStateNotAllowed,
    CBISubmissionStateAwaitingSubmission,
    CBISubmissionStateUploading,
} CBISubmissionState;

@interface CBIStudentSubmissionViewController () <UIToolbarDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, NewSubmissionViewModelShimProtocol>
@property (strong, nonatomic) IBOutlet UIToolbar *floatingActionBar;
@property (nonatomic) NSCache *avatarImageCache;

@property (nonatomic) IBOutlet UIBarButtonItem *turnInButton;
@property (nonatomic) IBOutlet UIBarButtonItem *turnInToAddCommentSpacing;
@property (nonatomic) IBOutlet UIBarButtonItem *addCommentButton;
@property (nonatomic) SubmissionWorkflowController *workflow;

@property (nonatomic) CKIAssignment *assignment;

@property (nonatomic) CKAssignment *legacyAssignment;
@property (nonatomic) CKContextInfo *legacyContext;

@property (nonatomic, readonly) BOOL userIsCommenting;
@property (nonatomic) CBISubmissionState submissionState;

@property (nonatomic) CKAudioCommentRecorderView *recordAudio;
@property (nonatomic) BOOL allowMediaComments;
@property (nonatomic) RACSignal *isTeacherOrTaSignal;
@property (nonatomic) BOOL isTeacherOrTA;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NewSubmissionViewModelShim *submissionViewModel;
@end


@implementation CBIStudentSubmissionViewController

@dynamic viewModel;

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    self.avatarImageCache = [NSCache new];
    
    RAC(self, assignment) = [RACObserve(self, viewModel.model) flattenMap:^(CKIAssignment *assignment) {
        if (assignment.name.length == 0 && assignment.id != nil) {
            return [[[TheKeymaster.currentClient refreshModel:assignment parameters:nil] map:^id(CKIAssignment *refreshedAssignment) {
                return refreshedAssignment;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal return:assignment];
            }];
        } else {
            return [RACSignal return:assignment];
        }
    }];
    
    [RACObserve(self, assignment) subscribeNext:^(id  _Nullable x) {
        [self updateActions];
    }];
    
    RAC(self, legacyAssignment) = [RACObserve(self, viewModel.model) flattenMap:^(CKIAssignment *assignment) {
        if (assignment.name.length == 0 && assignment.id != nil) {
            return [[[TheKeymaster.currentClient refreshModel:assignment parameters:nil] map:^id(CKIAssignment *assignment) {
                NSDictionary *jsonDict = [assignment JSONDictionary];
                return [[CKAssignment alloc] initWithInfo:jsonDict];
            }] catch:^RACSignal *(NSError *error) {
                NSDictionary *jsonDict = [assignment JSONDictionary];
                return [RACSignal return:[[CKAssignment alloc] initWithInfo:jsonDict]];
            }];
        } else {
            NSDictionary *jsonDict = [assignment JSONDictionary];
            return [RACSignal return:[[CKAssignment alloc] initWithInfo:jsonDict]];
        }
    }];
    
    RAC(self, legacyContext) = [RACObserve(self, viewModel.model.context) map:^id(CKIModel *context) {
        if ([context isKindOfClass:[CKICourse class]]) {
            return [CKContextInfo contextInfoFromCourseIdent:[context.id longLongValue]];
        } else {
            return [CKContextInfo contextInfoFromGroupIdent:[context.id longLongValue]];
        }
    }];

    RAC(self, submissionState) = [RACObserve(self, viewModel.model.submissionTypes) map:^id(NSArray *types) {
        return types.count > 0 ? @(CBISubmissionStateAwaitingSubmission) : @(CBISubmissionStateNotAllowed);
    }];

    self.turnInButton.enabled = NO;
    
    CKCanvasAPI *legacyAPI = CKCanvasAPI.currentAPI;
    [legacyAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL isFinalValue) {
        NSLog(@"check for media comments = %@", @(isFinalValue));
        self.allowMediaComments = legacyAPI.mediaServer != nil;
    }];
    
    self.isTeacherOrTA = NO;
    self.isTeacherOrTaSignal = [RACObserve(self, viewModel.model.context) map:^id(id<CKIContext> context) {
        if ([context isKindOfClass:[CKICourse class]]) {
            
            CKICourse *course = (CKICourse *)context;
            
            if (course.enrollments == nil || course.enrollments.count == 0 || course.name.length == 0) {
                static dispatch_once_t once;
                dispatch_once(&once, ^ {
                    [[TheKeymaster.currentClient refreshModel:course parameters:nil] subscribeCompleted:^{
                        self.viewModel.model.context = course;
                    }];
                });
            }
            
            NSArray *enrollmentTypes = [course.enrollments.rac_sequence map:^id(id value) {
                return [value valueForKey:@"type"];
            }].array;
            
            __block BOOL isTeacherOrTeachingAssistant = NO;
            [enrollmentTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([[NSNumber numberWithInt:CKIEnrollmentTypeTeacher] isEqualToNumber:obj] || [[NSNumber numberWithInt:CKIEnrollmentTypeTA] isEqualToNumber:obj]) {
                    isTeacherOrTeachingAssistant = YES;
                    *stop = YES;
                    return;
                }
            }];
            
            return @(isTeacherOrTeachingAssistant);
        }
        return @(NO);
    }];

    self.submissionViewModel = [NewSubmissionViewModelShim new];

    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor prettyLightGray];
    
    if (self.viewModel.forTeacher) {
        self.addCommentButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Comment", @"add comment button") style:UIBarButtonItemStylePlain target:self action:@selector(tappedAdComment:)];
        self.navigationItem.rightBarButtonItem = self.addCommentButton;
    } else {
        [self addFloatingActionBar];
    }
    
    [CKCanvasAPI.currentAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL isFinalValue) {
        if (error) {
            NSLog(@"error getting the media server");
        }
    }];
    
    [self.isTeacherOrTaSignal subscribeNext:^(NSNumber *isTeacherOrTA) {
        self.addCommentButton.enabled = YES;
        self.isTeacherOrTA = [isTeacherOrTA boolValue];
        [self updateActions];
    }];
    
    self.refreshControl.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    //  url needs to be set before super call for logging
    if(!self.url) {
        self.url = [NSString stringWithFormat:@"%@/submissions", self.assignment.htmlURL.absoluteString];
    }
    [super viewWillDisappear:animated];
}

- (bool)isEnrollmentActiveForCourse {
    
    __block bool isActive = NO;
    
    id context = self.viewModel.model.context;
    if ([context isKindOfClass:[CKICourse class]]) {
         NSArray *enrollments = ((CKICourse *)context).enrollments;
        
        [enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
            if ([enrollment.state isEqualToString:@"active"]){
                isActive = YES;
                *stop = YES;
            }
        }];
    }
    
    //not a course
    return isActive;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    [self floatActionBar];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[CBISubmissionCommentCell class]]) {
        ((CBISubmissionCommentCell *)cell).avatarImageView.imageCache = self.avatarImageCache;
    }
    
    return cell;
}

#pragma mark - floatingActionBar

- (void)addFloatingActionBar {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[UINib nibWithNibName:@"CBIFloatingActionBar" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:self options:nil];
    
    @weakify(self)
    RAC(self, turnInButton.title) = [RACSignal combineLatest:@[RACObserve(self, viewModel.model.submissionTypes), RACObserve(self, viewModel.record.submissionHistory)] reduce:^id(NSArray *types, NSArray *history) {
        if ([types containsObject:CKISubmissionTypeExternalTool]) {
            return NSLocalizedString(@"Launch External Tool", @"title for submission button");
        } else if ([types containsObject:CKISubmissionTypeDiscussion]) {
            return NSLocalizedString(@"Go To Discussion", @"title for discussion assignment submission button");
        } else if ([types containsObject:CKISubmissionTypeQuiz]) {
            return NSLocalizedString(@"Show Quiz", @"title for quiz assignment submission button");
        } else if ([types containsObject:CKISubmissionTypePaper]) {
            @strongify(self)
            self.turnInButton.enabled = NO;
            return @"";
        } else if ([history.rac_sequence filter:^BOOL(CKISubmission *submission) {
            return submission.id != nil && submission.attempt > 0;
        }].array.count > 0) {
            return NSLocalizedString(@"Turn In Again", @"title for re-submitting an assignment");
        } else {
            return NSLocalizedString(@"Turn In", @"title for assignment submission button");
        }
    }];
    
    [self.tableView addSubview:self.floatingActionBar];
    UIView *header = [[UIView alloc] initWithFrame:self.floatingActionBar.bounds];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;

    [self updateActions];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

- (void)floatActionBar {
    [self.tableView bringSubviewToFront:self.floatingActionBar];
    
    CGRect scrollBounds = self.tableView.bounds;
    UIEdgeInsets insets = self.tableView.contentInset;
    
    CGRect floatingFrame = self.floatingActionBar.frame;
    
    floatingFrame.size.width = scrollBounds.size.width;
    floatingFrame.origin.y = scrollBounds.origin.y + insets.top;
    self.floatingActionBar.frame = floatingFrame;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self floatActionBar];
}

#pragma mark - turn in

- (void)setSubmissionState:(CBISubmissionState)submissionState {
    _submissionState = submissionState;
    [self updateActions];
}

- (void)postUploadError {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSString *title = NSLocalizedString(@"Submission Error", @"Title for file submission error");
    NSString *message = NSLocalizedString(@"There was a network problem while attempting to upload your submission", @"message for failed submission upload");
    [UIAlertController showAlertWithTitle:title message:message];
}

- (IBAction)tappedTurnIn:(id)sender {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    SubmissionWorkflowController *controller = [[SubmissionWorkflowController alloc] initWithViewController:self];
    controller.allowsMediaSubmission = CKCanvasAPI.currentAPI.mediaServer.enabled;
    controller.legacyAssignment = self.legacyAssignment;
    controller.assignment = self.assignment;
    controller.canvasAPI = CKCanvasAPI.currentAPI;
    controller.contextInfo = self.legacyContext;
    
    __block UIProgressView *progressView;

    @weakify(self);
    controller.uploadProgressBlock = ^(float progress) {
        @strongify(self);
        self.submissionState = CBISubmissionStateUploading;
        
        if (!progressView) {
            CGRect actionBarBounds = self.floatingActionBar.bounds;
            progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, actionBarBounds.size.height - 2, actionBarBounds.size.width, 2)];
            progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            [self.floatingActionBar addSubview:progressView];
        }
        progressView.progress = progress * 0.8;
    };
    
    controller.uploadCompleteBlock = ^(CKSubmission * _Nullable submission, NSError *error) {
        @strongify(self);
        if (error) {
            DDLogVerbose(@"%@ - %@ : error: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [error localizedDescription]);
            [self postUploadError];
        }
        else {
            DDLogVerbose(@"%@ - %@ : success", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
            progressView.progress = 0.9;
            [[self.viewModel refreshViewModelSignalForced:YES] subscribeError:^(NSError *error) {
                NSLog(@"trouble refreshing after submitting");
                [progressView removeFromSuperview];
                progressView = nil;
            } completed:^{
                progressView.progress = 1.0;
                [UIView animateWithDuration:0.25 animations:^{
                    progressView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [progressView removeFromSuperview];
                    progressView = nil;
                }];
            }];
        }
        self.submissionState = CBISubmissionStateAwaitingSubmission;

        CBIPostModuleItemProgressUpdate(self.viewModel.model.id, CKIModuleItemCompletionRequirementMustSubmit);
        
        self.workflow = nil;
    };
    self.workflow = controller;
    [controller present];
}

- (NSArray *)submissionTypes
{
    CKSubmissionType submissionTypes = self.legacyAssignment.submissionTypes;
    NSMutableArray *strings = [NSMutableArray array];

    if (submissionTypes & CKSubmissionTypeDiscussionTopic) {
        [strings addObject:CKISubmissionTypeDiscussion];
    }

    if (submissionTypes & CKSubmissionTypeOnlineQuiz) {
        [strings addObject:CKISubmissionTypeQuiz];
    }

    if (submissionTypes & CKSubmissionTypeExternalTool) {
        [strings addObject:CKISubmissionTypeExternalTool];
    }

    if (submissionTypes & CKSubmissionTypeOnlineTextEntry) {
        [strings addObject:CKISubmissionTypeOnlineTextEntry];
    }

    if (submissionTypes & CKSubmissionTypeOnlineURL) {
        [strings addObject:CKISubmissionTypeOnlineURL];
    }

    if (submissionTypes & CKSubmissionTypeOnlineUpload) {
        [strings addObject:CKISubmissionTypeOnlineUpload];
    }

    if (submissionTypes & CKSubmissionTypeMediaRecording) {
        [strings addObject:CKISubmissionTypeMediaRecording];
    }

    return strings;
}


#pragma mark - NewSubmissionViewModelObjcProtocol

- (void)newSubmissionViewModel:(NewSubmissionViewModel *)submissionViewModel wantsToPresentViewController:(UIViewController *)viewController completion:(void (^)(void))completion
{
    [self presentViewController:viewController animated:YES completion:completion];
}

- (void)newSubmissionViewModel:(NewSubmissionViewModel *)newSubmissionViewModel wantsToPresentTurnInPrompt:(UIAlertController *)alertController completion:(void (^)(void))completion
{
    alertController.popoverPresentationController.barButtonItem = self.turnInButton;
    [self presentViewController:alertController animated:YES completion:completion];
}

- (void)newSubmissionViewModel:(NewSubmissionViewModel *)submissionViewModel createdSubmission:(Submission *)submission
{
    CBIPostModuleItemProgressUpdate(self.viewModel.model.id, CKIModuleItemCompletionRequirementMustSubmit);
    [[self.viewModel refreshViewModelSignalForced:YES] subscribeError:^(NSError *error) {
        [self postUploadError];
    } completed:^{}];
}

- (void)newSubmissionViewModel:(NewSubmissionViewModel *)submissionViewModel failedWith:(NSString *)error
{
    [self postUploadError];
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        CGRect actionBarBounds = self.floatingActionBar.bounds;
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, actionBarBounds.size.height - 2, actionBarBounds.size.width, 2)];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self.floatingActionBar addSubview:_progressView];
    }

    return _progressView;
}


#pragma mark - comment

- (void)updateActions {
    if (self.userIsCommenting) {
        self.addCommentButton.title = NSLocalizedString(@"Cancel Message", @"Cancel button title");
    } else {
        self.addCommentButton.title = self.isTeacherOrTA ? NSLocalizedString(@"Comment", @"Add message button for teacher or ta") : NSLocalizedString(@"Message Instructor", @"Add message button");
    }

    if (!self.floatingActionBar) {
        return;
    }
    
    NSMutableArray *actions = [NSMutableArray array];

    NSArray *submissionTypes = self.viewModel.model.submissionTypes;
    if (_submissionState == CBISubmissionStateAwaitingSubmission && submissionTypes.count > 0 && ![submissionTypes.firstObject isEqualToString:@"none"]) {
        [actions addObject:self.turnInButton];
        self.turnInButton.enabled = [self isEnrollmentActiveForCourse] && !self.assignment.lockedForUser;
    }

    [actions addObject:self.turnInToAddCommentSpacing];
    [actions addObject:self.addCommentButton];
    

    self.floatingActionBar.items = actions;
}

- (BOOL)userIsCommenting {
    return [[self.viewModel.collectionController.groups.firstObject objects].firstObject isKindOfClass:[CBIAddSubmissionCommentViewModel class]];
}

- (IBAction)tappedAdComment:(id)sender {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (self.userIsCommenting) {
        [self.viewModel.collectionController removeObjectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    } else {
        CBIAddSubmissionCommentViewModel *addComment = [CBIAddSubmissionCommentViewModel new];
        [self.viewModel.collectionController insertObjects:@[addComment]];
        RAC(addComment, allowMediaComments) = RACObserve(self, allowMediaComments);
        addComment.allowMediaComments = self.allowMediaComments;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [self updateActions];
}

- (void)submitComment:(NSString *)commentText onSuccess:(void (^)(void))success onFailure:(void (^)(void))failure {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    CKISubmissionComment *comment = [CKISubmissionComment new];
    comment.context = self.viewModel.record;
    comment.comment = commentText;

    @weakify(self);
    [[TheKeymaster.currentClient createSubmissionComment:comment] subscribeNext:^(CKISubmissionRecord *record){
        @strongify(self);
        [self tappedAdComment:nil];
        
        CBISubmissionCommentViewModel *newComment = [CBISubmissionCommentViewModel viewModelForModel:record.comments.lastObject];
        [self.viewModel.collectionController insertObjects:@[newComment]];
        success();
    } error:^(NSError *error) {
        @strongify(self);
        [self tappedAdComment:nil];
        failure();
    }];
}


- (void)chooseMediaComment:(UIButton *)sender {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSString *recordVideo = NSLocalizedString(@"Record Video", @"Record video submission comment option");
    

    NSString *chooseVideo = NSLocalizedString(@"Choose Video", @"Choose a video to send as a comment");
    
    
    NSString *recordAudio = NSLocalizedString(@"Record Audio", @"Record audio submission comment");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button title") destructiveButtonTitle:nil otherButtonTitles:recordVideo, chooseVideo, recordAudio, nil];

    CGRect r = sender.bounds;
    r = [self.view convertRect:r fromView:sender];
    
    sheet.tintColor = self.viewModel.tintColor;
    [sheet showFromRect:r inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
    case 0:
        [self showVideoRecorderWithSourceType:UIImagePickerControllerSourceTypeCamera];
        break;

    case 1:
        [self showVideoRecorderWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        break;
            
    case 2:
        [self showAudioRecorder];
        break;
            
    default:
        break;
    }
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self tappedAdComment:nil];
}

- (void)uploadMediaCommentAtURL:(NSURL *)localURL {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    
    
    CKCanvasAPI *canvasAPI = CKCanvasAPI.currentAPI;
    
    UIView *bar = self.floatingActionBar ?: self.navigationController.navigationBar;
    __block UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, bar.bounds.size.height-2, bar.bounds.size.width, 2)];
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    progress.trackTintColor = [UIColor clearColor];
    [bar addSubview:progress];
    
    @weakify(self)
    [canvasAPI postMediaCommentURL:localURL forCourseIdent:[((CKICourse *)self.viewModel.model.context).id longLongValue] assignmentIdent:[self.viewModel.model.id longLongValue] studentIdent:[self.viewModel.record.userID longLongValue] progressBlock:^(float percentCompleted) {
        progress.progress = percentCompleted;
    } completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
        [progress removeFromSuperview];
        progress = nil;
        if (error) {
            DDLogVerbose(@"%@ - error=%@", NSStringFromSelector(_cmd), error);
            NSString *title = NSLocalizedString(@"Comment Error", @"title for media comment upload failure");
            NSString *message = NSLocalizedString(@"There was a network error posting your comment.", @"message for media comment upload failure");
            [UIAlertController showAlertWithTitle:title message:message];
        }
        else {
            DDLogVerbose(@"%@ - success!", NSStringFromSelector(_cmd));
            @strongify(self);
            CKSubmissionComment *legacyComment = submission.comments.lastObject;
            CKISubmissionComment *comment = [CKISubmissionComment new];
            CKIMediaComment *mediaComment = [CKIMediaComment new];
            comment.mediaComment = mediaComment;
            mediaComment.mediaID = legacyComment.mediaComment.mediaId;
            mediaComment.mediaType = legacyComment.mediaComment.mediaType == CKAttachmentMediaTypeVideo ? CKIMediaCommentMediaTypeVideo: CKIMediaCommentMediaTypeAudio;
            comment.createdAt = legacyComment.createdAt;
            comment.authorID = [@(legacyComment.authorIdent) description];
            comment.authorName = legacyComment.authorName;
            comment.avatarPath = legacyComment.author.avatarURL.path;
            
            // The server takes a while to transcode it. But we already have it locally, so let's just use that.
            // When they reload the data from the server next, it will hopefully be transcoded.
            comment.mediaComment.url = localURL;
            
            CBISubmissionCommentViewModel *commentViewModel = [CBISubmissionCommentViewModel viewModelForModel:comment];
            [self.viewModel.collectionController insertObjects:@[commentViewModel]];
        }
        [application endBackgroundTask:backgroundTask];
    }];
}

- (void)showVideoRecorderWithSourceType:(UIImagePickerControllerSourceType)type {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    VideoRecorderController *picker = [[VideoRecorderController alloc] initWithSourceType:type Handler:^(NSURL *movieURL) {
        [self uploadMediaCommentAtURL:movieURL];
    }];
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showAudioRecorder {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    CKAudioCommentRecorderView *audioRecorder = [[CKAudioCommentRecorderView alloc] init];
    
    CKOverlayViewController *overlay = [[CKOverlayViewController alloc] initWithView:audioRecorder];
    UIViewController *rootController = self.view.window.rootViewController;
    
    [audioRecorder.leftButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    audioRecorder.leftButton.hidden = NO;
    [audioRecorder.leftButton addTarget:rootController action:@selector(dismissOverlayController) forControlEvents:UIControlEventTouchUpInside];
    
    [audioRecorder.rightButton setTitle:NSLocalizedString(@"Use", nil) forState:UIControlStateNormal];
    audioRecorder.rightButton.hidden = NO;
    [audioRecorder.rightButton addTarget:self action:@selector(postAudioCommentFromAudioRecorder) forControlEvents:UIControlEventTouchUpInside];
    
    self.recordAudio = audioRecorder;
    [self.view.window.rootViewController presentOverlayController:overlay];
}

- (void)postAudioCommentFromAudioRecorder {
    DDLogVerbose(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSURL *audioURL = self.recordAudio.recordedFileURL;
    
    if (!audioURL) {
        return;
    }
    
    [self.view.window.rootViewController dismissOverlayController];
    
    [self uploadMediaCommentAtURL:audioURL];
}
@end
