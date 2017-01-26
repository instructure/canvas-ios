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

#import "CSGGradingCommentsViewController.h"

#import "CSGAppDataSource.h"
#import "CSGGradingCommentsTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VideoRecorderView.h"
#import "AudioRecorderView.h"
#import <CanvasKeymaster/CanvasKeymaster.h>
#import "CSGToaster.h"
#import "UIColor+Canvas.h"
#import "UIImage+Color.h"
#import "CSGGradingViewController.h"

#define INPUT_HEIGHT 47
#define STATUS_IMAGE_VIEW_WIDTH 34
#define STATUS_IMAGE_VIEW_PADDING 16
#define STATUS_LABEL_WIDTH 70
#define STATUS_LABEL_WIDTH_SMALL 40

static NSString *const CSGGradingCommentsTableSegueID = @"embed_comments_table_view";
static CGFloat const CSGPostCommentBottomLayoutConstraintDefaultValue = 8;

static NSTimeInterval const CSGShowHideSendCommentAnimationDuration = 0.25;
static NSTimeInterval const CSGShowSendCommentSubmittedTime = 0.5;

typedef void (^AnimationBlock)();

typedef enum {
    InputSegmentedControlTypeVideo,
    InputSegmentedControlTypeAudio,
    InputSegmentedControlTypeText
} InputSegmentedControlType;

@interface CSGGradingCommentsViewController () < UIActionSheetDelegate, UITextViewDelegate, AudioRecorderViewDelegate, VideoRecorderViewDelegate>

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, weak) IBOutlet UITextView *commentsTextView;
@property (nonatomic, weak) IBOutlet UIView *postCommentSeparatorView;

@property (nonatomic, weak) UIButton *sendCommentButton;
@property (nonatomic, weak) UILabel *activityStatusLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityStatusIndicatorView;
@property (nonatomic, weak) UIImageView *activityStatusImageView;

@property (nonatomic, weak) IBOutlet UIButton *textSendCommentButton;
@property (nonatomic, weak) IBOutlet UILabel *textActivityStatusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *textActivityStatusIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *textActivityStatusImageView;

@property (nonatomic, strong) CSGGradingCommentsTableViewController *tableViewController;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *postCommentBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *InputViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityStatusImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityStatusLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inputTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlBackingView;

@property (nonatomic, copy) void (^changeInputCleanupBlock)(void);
@property (nonatomic, strong) CSGToaster *toaster;

@property (nonatomic, strong) VideoRecorderView *videoRecorderView;
@property (nonatomic, strong) AudioRecorderView *audioRecorderView;

@end

@implementation CSGGradingCommentsViewController

+ (instancetype)instantiateFromStoryboard
{
    CSGGradingCommentsViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.toaster = [CSGToaster new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeComments:) name:CSGGradingRemoveCommentsNotification object:nil];
    
    @weakify(self);
    [RACObserve(self, dataSource.selectedSubmissionRecord) subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        self.commentsTextView.text = @"";
    }];
    [self.textSendCommentButton setEnabled:self.commentsTextView.text.length];
    
    [self setupView];
    self.inputTypeSegmentedControl.selectedSegmentIndex = InputSegmentedControlTypeText;
    self.inputTypeSegmentedControl.tintColor = [UIColor csg_gradingCommentPostCommentSegmentColor];
    [self changeInputHeightTo:INPUT_HEIGHT animated:NO];
    [self changeStatusLabelWidthTo:STATUS_LABEL_WIDTH_SMALL animated:NO];
    [self changeStatusImageViewWidthTo:0 animated:NO];
    self.changeInputCleanupBlock = ^ {
        @strongify(self);
        [UIView animateWithDuration:0.1 animations:^{
            [self.sendCommentButton setAlpha:0.0];
            [self.commentsTextView setAlpha:0.0];
        }];
        self.changeInputCleanupBlock = nil;
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)setupView {
    self.view.backgroundColor = [UIColor csg_gradingCommentTableBackgroundColor];
    self.segmentedControlBackingView.backgroundColor = [UIColor csg_gradingCommentTableBackgroundColor];
    self.postCommentSeparatorView.backgroundColor = [UIColor csg_gradingCommentPostCommentSeparatorColor];
    
    [self setupTextCommentButton];
    [self setupCommentsTextView];
    [self setupActivityStatusViews];
    
    [self.inputTypeSegmentedControl setTitle:NSLocalizedString(@"Video", nil) forSegmentAtIndex:InputSegmentedControlTypeVideo];
    [self.inputTypeSegmentedControl setTitle:NSLocalizedString(@"Audio", nil) forSegmentAtIndex:InputSegmentedControlTypeAudio];
    [self.inputTypeSegmentedControl setTitle:NSLocalizedString(@"Text", nil) forSegmentAtIndex:InputSegmentedControlTypeText];
    
    self.audioRecorderView = [[NSBundle mainBundle] loadNibNamed:@"AudioRecorderView" owner:nil options:nil][0];
    self.videoRecorderView = [[NSBundle mainBundle] loadNibNamed:@"VideoRecorderView" owner:nil options:nil][0];
    
    self.videoRecorderView.delegate = self;
    self.audioRecorderView.delegate = self;
    
    self.sendCommentButton = self.textSendCommentButton;
    self.activityStatusLabel = self.textActivityStatusLabel;
    self.activityStatusImageView = self.textActivityStatusImageView;
    self.activityStatusIndicatorView = self.textActivityStatusIndicatorView;
}

- (void)setupTextCommentButton{
    [self.textSendCommentButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingCommentPostCommentButtonBackgroundColor]] forState:UIControlStateNormal];
    [self.textSendCommentButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingCommentPostCommentButtonDisabledBackgroundColor]] forState:UIControlStateDisabled];
    [self.textSendCommentButton setTitleColor:[UIColor csg_gradingCommentPostCommentButtonTextColor] forState:UIControlStateNormal];
    [self.textSendCommentButton setTitleColor:[UIColor csg_gradingCommentPostCommentButtonDisabledTextColor] forState:UIControlStateDisabled];
    
    [self.textSendCommentButton setTitle:NSLocalizedString(@"Post", @"Post Comment Button Text") forState:UIControlStateNormal];
    
    self.textSendCommentButton.layer.cornerRadius = 3.0f;
    self.textSendCommentButton.clipsToBounds = YES;
}

- (void)setupPostButton{
    [self.sendCommentButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingCommentPostCommentButtonBackgroundColor]] forState:UIControlStateNormal];
    [self.sendCommentButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingCommentPostCommentButtonDisabledBackgroundColor]] forState:UIControlStateDisabled];
    [self.sendCommentButton setTitleColor:[UIColor csg_gradingCommentPostCommentButtonTextColor] forState:UIControlStateNormal];
    [self.sendCommentButton setTitleColor:[UIColor csg_gradingCommentPostCommentButtonDisabledTextColor] forState:UIControlStateDisabled];
    
    [self.sendCommentButton setTitle:NSLocalizedString(@"Post", @"Post Comment Button Text") forState:UIControlStateNormal];
    
    self.sendCommentButton.layer.cornerRadius = 3.0f;
    self.sendCommentButton.clipsToBounds = YES;
}

- (void)setupCommentsTextView {
    self.commentsTextView.delegate = self;
    
    self.commentsTextView.layer.cornerRadius = 3.0f;
    self.commentsTextView.layer.masksToBounds = YES;
    
    self.commentsTextView.layer.borderColor = [RGB(225, 226, 223) CGColor];
    self.commentsTextView.layer.borderWidth = 1.0f;
}

- (void)setupActivityStatusViews {
    // Hide until Send grade is pressed
    self.activityStatusLabel.alpha = 0.0;
    self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorDefault];
    
    self.activityStatusIndicatorView.alpha = 0.0;
    self.activityStatusIndicatorView.color = [UIColor csg_gradingRailStatusActivityIndicatorColor];
    self.activityStatusImageView.alpha = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeComments:(NSNotification *)note {
    DDLogInfo(@"REMOVE COMMENT PRESSED");
    self.commentsTextView.text = @"";
    [self.videoRecorderView deleteVideo];
    [self.audioRecorderView audioDeleteRecording];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CSGGradingCommentsTableSegueID]) {
        self.tableViewController = segue.destinationViewController;
    }
}

- (IBAction)sendCommentButtonPressed:(UIButton *)sender {
    [self postSubmissionComment:self.commentsTextView.text];
}

- (void)postSubmissionComment:(NSString *)comment {
    DDLogInfo(@"POST TEXT PRESSED: %@", comment);
    NSTimeInterval animationDuration = CSGShowHideSendCommentAnimationDuration;
    
    [self changeStatusLabelWidthTo:STATUS_LABEL_WIDTH animated:NO];
    [UIView animateWithDuration:animationDuration animations:[self hideSendCommentButtonAnimation] completion:^(BOOL finished) {
        @weakify(self);
        [[[TheKeymaster currentClient] addComment:comment forSubmissionRecord:self.dataSource.selectedSubmissionRecord] subscribeNext:^(CKISubmissionRecord *submisssionRecord) {
            [self.dataSource replaceSubmissionRecord:self.dataSource.selectedSubmissionRecord withSubmissionRecord:submisssionRecord];
        } error:^(NSError *error) {
            DDLogInfo(@"POST TEXT FAILED: %@", error.localizedDescription);
            @strongify(self);
            [self changeStatusImageViewWidthTo:STATUS_IMAGE_VIEW_WIDTH animated:YES];
            [UIView animateWithDuration:animationDuration animations:[self showCommentSubmitFailedAnimation] completion:^(BOOL finished) {
                // After we show the comment submitted, let it stay for
                [self performSelector:@selector(showSendCommentsButton) withObject:nil afterDelay:CSGShowSendCommentSubmittedTime];
            }];
        } completed:^{
            DDLogInfo(@"POST TEXT SUCCEEDED");
            // mark that the view has changed until comment is submitted
            self.dataSource.selectedSubmissionCommentChanged = NO;
            
            @strongify(self);
            [self changeStatusImageViewWidthTo:STATUS_IMAGE_VIEW_WIDTH animated:YES];
            [UIView animateWithDuration:animationDuration animations:[self showCommentSubmittedAnimation] completion:^(BOOL finished) {
                // After we show the comment submitted, let it stay for
                [self performSelector:@selector(showSendCommentsButton) withObject:nil afterDelay:CSGShowSendCommentSubmittedTime];
            }];
            
            self.commentsTextView.text = @"";
            [self.textSendCommentButton setEnabled:NO];
            [self changeInputHeightTo:INPUT_HEIGHT animated:NO];
        }];
    }];
}

- (void)showSendCommentsButton {
    [UIView animateWithDuration:CSGShowHideSendCommentAnimationDuration animations:^{
        self.sendCommentButton.alpha = 1.0;
        
        self.activityStatusLabel.alpha = 0.0;
        self.activityStatusImageView.alpha = 0.0;
        [self.activityStatusIndicatorView stopAnimating];
    }];
    
    [self changeStatusLabelWidthTo:STATUS_LABEL_WIDTH_SMALL animated:NO];
    [self changeStatusImageViewWidthTo:0-STATUS_IMAGE_VIEW_PADDING animated:YES];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    CGFloat adjustment = self.inputTypeSegmentedControl.frame.size.height + 8 + 8;
    
    self.postCommentBottomLayoutConstraint.constant = CSGPostCommentBottomLayoutConstraintDefaultValue + CGRectGetHeight(keyboardEndFrame) - adjustment;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    self.postCommentBottomLayoutConstraint.constant = CSGPostCommentBottomLayoutConstraintDefaultValue;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - Input View Controls

- (void)textViewDidChange:(UITextView *)textView {
    
    [self.textSendCommentButton setEnabled:textView.text.length];
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    [self changeInputHeightTo:MAX(newFrame.size.height + 8 + 8, 250) animated:YES];

    // mark that the view has changed until comment is submitted
    self.dataSource.selectedSubmissionCommentChanged = textView.text.length;
}

- (IBAction)inputTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case InputSegmentedControlTypeVideo:
            DDLogInfo(@"VIDEO COMMENT SELECTED");
            [self showVideoInput];
            break;
        case InputSegmentedControlTypeAudio:
            DDLogInfo(@"AUDIO COMMENT SELECTED");
            [self showAudioInput];
            break;
        case InputSegmentedControlTypeText:
            DDLogInfo(@"TEXT COMMENT SELECTED");
            [self showTextInput];
            break;
        default:
            break;
    }
    
}

- (void)showVideoInput {
    
    if (self.changeInputCleanupBlock) {
        self.changeInputCleanupBlock();
    }
    
    [self.inputContainerView addSubview:self.videoRecorderView];
    UIView *recorderView = self.videoRecorderView;
    recorderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.inputContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[recorderView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(recorderView)]];
    [self.inputContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recorderView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(recorderView)]];
    
    @weakify(self);
    self.changeInputCleanupBlock = ^ {
        @strongify(self);
        [UIView animateWithDuration:0.1 animations:^{
            [self.videoRecorderView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.videoRecorderView removeFromSuperview];
            self.videoRecorderView.alpha = 1.0;
        }];
        self.changeInputCleanupBlock = nil;
    };
    
    self.sendCommentButton = self.videoRecorderView.videoPostButton;
    self.activityStatusLabel = self.videoRecorderView.videoStatusActivityLabel;
    self.activityStatusImageView = self.videoRecorderView.videoStatusActivityImageView;
    self.activityStatusIndicatorView = self.videoRecorderView.videoStatusActivityIndicator;
    
    [self adjustVideoInputViewHeight];
    [self showSendCommentsButton];
}

- (void)handleRotation:(NSNotification *)note {
    
    if (self.inputTypeSegmentedControl.selectedSegmentIndex == InputSegmentedControlTypeVideo) {
        [self adjustVideoInputViewHeight];
    }
    
}

- (void)adjustVideoInputViewHeight {
    
    CGFloat height;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        height = self.view.frame.size.width * (3.0/4.0);
    } else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        height = self.view.frame.size.width * (4.0/3.0);
    }
    
    [self changeInputHeightTo:height animated:YES];
}

- (void)showAudioInput {
    if (self.changeInputCleanupBlock) {
        self.changeInputCleanupBlock();
    }
    
    [self.inputContainerView addSubview:self.audioRecorderView];
    UIView *audioRecorderView = self.audioRecorderView;
    audioRecorderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.inputContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[audioRecorderView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(audioRecorderView)]];
    [self.inputContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[audioRecorderView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(audioRecorderView)]];
    
    @weakify(self);
    self.changeInputCleanupBlock = ^ {
        @strongify(self);
        [UIView animateWithDuration:0.1 animations:^{
            [self.audioRecorderView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.audioRecorderView removeFromSuperview];
            self.audioRecorderView.alpha = 1.0;
            
        }];
        self.changeInputCleanupBlock = nil;
    };
    
    self.sendCommentButton = self.audioRecorderView.postButton;
    self.activityStatusLabel = self.audioRecorderView.audioActivityStatusLabel;
    self.activityStatusImageView = self.audioRecorderView.audioActivityStatusImageView;
    self.activityStatusIndicatorView = self.audioRecorderView.audioActivityIndicator;
    
    [self setupPostButton];
    
    [self changeInputHeightTo:100 animated:YES];
    [self showSendCommentsButton];
}

- (void)showTextInput {
    if (self.changeInputCleanupBlock) {
        self.changeInputCleanupBlock();
    }

    [UIView animateWithDuration:0.1 animations:^{
        self.sendCommentButton.alpha = 1.0;
        self.commentsTextView.alpha = 1.0;
    }];
    
    @weakify(self);
    self.changeInputCleanupBlock = ^ {
        @strongify(self);
        [UIView animateWithDuration:0.1 animations:^{
            [self.sendCommentButton setAlpha:0.0];
            [self.commentsTextView setAlpha:0.0];
        }];
        self.changeInputCleanupBlock = nil;
    };
    
    self.sendCommentButton = self.textSendCommentButton;
    self.activityStatusLabel = self.textActivityStatusLabel;
    self.activityStatusImageView = self.textActivityStatusImageView;
    self.activityStatusIndicatorView = self.textActivityStatusIndicatorView;
    
    [self changeInputHeightTo:INPUT_HEIGHT animated:YES];
    [self showSendCommentsButton];
}

- (void)changeStatusImageViewWidthTo:(CGFloat)width animated:(BOOL)animated {
    
    self.activityStatusImageViewWidthConstraint.constant = width;
    [self.view updateConstraints];
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)changeStatusLabelWidthTo:(CGFloat)width animated:(BOOL)animated {
    
    self.activityStatusLabelWidthConstraint.constant = width;
    [self.view updateConstraints];
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)changeInputHeightTo:(CGFloat)height animated:(BOOL)animated {
    
    self.InputViewContainerHeightConstraint.constant = height;
    [self.view updateConstraints];

    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
    
}

#pragma mark - Video Recorder View Delegate

- (void)videoStartedRecording {
    DDLogInfo(@"VIDEO STARTED RECORDING");
    self.dataSource.selectedSubmissionCommentChanged = YES;
}

- (void)videoDeletedRecording {
    DDLogInfo(@"VIDEO DELETED");
    self.dataSource.selectedSubmissionCommentChanged = NO;
}

- (void)postVideo:(NSURL *)videoURL {
    DDLogInfo(@"POST VIDEO PRESSED");
    CKIMediaComment *mediaComment = [[CKIMediaComment alloc] init];
    mediaComment.url = videoURL;
    mediaComment.mediaType = CKIMediaCommentMediaTypeVideo;
    
    NSTimeInterval animationDuration = CSGShowHideSendCommentAnimationDuration;
    [UIView animateWithDuration:animationDuration animations:self.hideSendCommentButtonAnimation completion:^(BOOL finished) {
       @weakify(self);
        [TheKeymaster.currentClient createCommentWithMedia:mediaComment forSubmissionRecord:self.dataSource.selectedSubmissionRecord success:^{
            DDLogInfo(@"POST VIDEO SUCCEEDED");
            // mark that the view has changed until comment is submitted
            self.dataSource.selectedSubmissionCommentChanged = NO;
            
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:animationDuration animations:self.showCommentSubmittedAnimation completion:^(BOOL finished) {
                    // After we show the comment submitted, let it stay for
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:CSGShowHideSendCommentAnimationDuration animations:^{
                            self.sendCommentButton.alpha = 1.0;
                            
                            self.activityStatusLabel.alpha = 0.0;
                            self.activityStatusImageView.alpha = 0.0;
                            [self.activityStatusIndicatorView stopAnimating];
                        } completion:^(BOOL finished) {
                            [self.videoRecorderView reset];
                        }];
                        
                        [self changeStatusLabelWidthTo:STATUS_LABEL_WIDTH_SMALL animated:NO];
                        [self changeStatusImageViewWidthTo:0-STATUS_IMAGE_VIEW_PADDING animated:YES];
                    });
                }];
                
                NSString *message = NSLocalizedString(@"Success! Your video can take a few minutes to appear", @"Successfully uploaded video submission comment toast notification");
                [self.toaster statusBarToast:message Color:[UIColor cbi_blue] Duration:5.0f];
            });
        } failure:^(NSError *error) {
            DDLogInfo(@"POST VIDEO FAILED: %@", error.localizedDescription);
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:animationDuration animations:self.showCommentSubmitFailedAnimation completion:^(BOOL finished) {
                    // After we show the comment submitted, let it stay for
                    [self performSelector:@selector(showSendCommentsButton) withObject:nil afterDelay:CSGShowSendCommentSubmittedTime];
                }];
            });
        }];
    }];
}

#pragma mark - Audio Recorder View Delegate

- (void)audioStartedRecording {
    DDLogInfo(@"AUDIO STARTED RECORDING");
    self.dataSource.selectedSubmissionCommentChanged = YES;
}

- (void)audioDeleteRecording {
    DDLogInfo(@"AUDIO DELETED");
    self.dataSource.selectedSubmissionCommentChanged = NO;
}

- (void)postAudio:(NSURL *)audioURL {
    DDLogInfo(@"POST AUDIO PRESSED");
    NSError *error = nil;
    
    if (error) {
        NSLog(@"Error converting submission record. Bailing out.");
        return;
    }
    
    NSTimeInterval animationDuration = CSGShowHideSendCommentAnimationDuration;
    [UIView animateWithDuration:animationDuration animations:[self hideSendCommentButtonAnimation] completion:^(BOOL finished) {
        // mark that the view has changed until comment is submitted
        self.dataSource.selectedSubmissionCommentChanged = NO;
        
        @weakify(self);
        CKIMediaComment *mediaComment = [[CKIMediaComment alloc] init];
        mediaComment.url = audioURL;
        mediaComment.mediaType = CKIMediaCommentMediaTypeAudio;
        
        [TheKeymaster.currentClient createCommentWithMedia:mediaComment forSubmissionRecord:self.dataSource.selectedSubmissionRecord success:^{
            DDLogInfo(@"POST AUDIO SUCCEEDED");
            @strongify(self);
            
            [UIView animateWithDuration:animationDuration animations:self.showCommentSubmittedAnimation completion:^(BOOL finished) {
                // After we show the comment submitted, let it stay for
                [self performSelector:@selector(showSendCommentsButton) withObject:nil afterDelay:CSGShowSendCommentSubmittedTime];
            }];
            
            self.commentsTextView.text = @"";
            [self.audioRecorderView audioDeleteRecording];
            NSString *message = NSLocalizedString(@"Success! Your recording can take a few minutes to appear", @"Successfully uploaded audio submission comment toast notification");
            [self.toaster statusBarToast:message Color:[UIColor cbi_blue] Duration:5.0f];
        } failure:^(NSError *error) {
            DDLogInfo(@"POST AUDIO FAILED: %@", error.localizedDescription);
            @strongify(self);
            [UIView animateWithDuration:animationDuration animations:self.showCommentSubmitFailedAnimation completion:^(BOOL finished) {
                // After we show the comment submitted, let it stay for
                [self performSelector:@selector(showSendCommentsButton) withObject:nil afterDelay:CSGShowSendCommentSubmittedTime];
            }];
        }];
    }];
}

#pragma mark - Animation Helper methods

- (AnimationBlock) hideSendCommentButtonAnimation {
    return ^{
        self.sendCommentButton.alpha = 0.0;
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorDefault];
        self.activityStatusLabel.text = NSLocalizedString(@"Submitting", @"Comment Sending Activity Status");
        
        self.activityStatusIndicatorView.alpha = 1.0;
        [self.activityStatusIndicatorView startAnimating];
    };
}

- (AnimationBlock) showCommentSubmittedAnimation {
    return ^{
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorSuccess];
        self.activityStatusLabel.text = NSLocalizedString(@"Success!", @"Comment Sent Success Activity Status");
        
        self.activityStatusIndicatorView.alpha = 0.0;
        [self.activityStatusIndicatorView stopAnimating];
        
        self.activityStatusImageView.alpha = 1.0;
        self.activityStatusImageView.image = [[UIImage imageNamed:@"icon_check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.activityStatusImageView.tintColor = [UIColor csg_gradingRailStatusColorSuccess];
    };
}

- (AnimationBlock) showCommentSubmitFailedAnimation {
    return ^{
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorFailure];
        self.activityStatusLabel.text = NSLocalizedString(@"Failed!", @"Comment Sent Failure Activity Status");
        
        self.activityStatusIndicatorView.alpha = 0.0;
        [self.activityStatusIndicatorView stopAnimating];
        
        self.activityStatusImageView.alpha = 1.0;
        self.activityStatusImageView.image = [[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.activityStatusImageView.tintColor = [UIColor csg_gradingRailStatusColorFailure];
    };
}

@end
