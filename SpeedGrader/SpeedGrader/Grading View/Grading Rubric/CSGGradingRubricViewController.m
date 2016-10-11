
//  CSGGradingRubricViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGGradingRubricViewController.h"

#import "CSGPickFileTableViewController.h"
#import "CSGPickVersionTableViewController.h"
#import "CSGGradingRubricTableViewController.h"
#import "CSGToaster.h"
#import "UIColor+Canvas.h"

#import "CSGAppDataSource.h"
#import "UIImage+Color.h"
#import <CanvasKit/CanvasKit.h>

typedef NS_ENUM(NSInteger, CSGGradingRubricPassFailState) {
    CSGGradingRubricPassFailStatePass,
    CSGGradingRubricPassFailStateFail
};

typedef void (^AnimationBlock)();

static NSTimeInterval const CSGShowHideSendGradeAnimationDuration = 0.25;
static NSTimeInterval const CSGShowSendGradeSubmittedTime = 0.5;

static NSString *const CSGGradingRubricTableSegueID = @"embed_grading_table_view";

@interface CSGGradingRubricViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, weak) IBOutlet UIView *pickVersionView;
@property (nonatomic, weak) IBOutlet UILabel *pickVersionAttemptLabel;
@property (nonatomic, weak) IBOutlet UILabel *pickVersionDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *noSubmissionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *pickVersionAccessoryView;

@property (nonatomic, weak) IBOutlet UIView *pickFileView;
@property (nonatomic, weak) IBOutlet UILabel *pickFileNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *pickFileAccessoryView;
@property (nonatomic, weak) IBOutlet UILabel *useRubricGradingLabel;

@property (nonatomic, weak) IBOutlet UIButton *sendGradeButton;

@property (nonatomic, weak) IBOutlet UISegmentedControl *passFailSegmentedControl;
@property (nonatomic, weak) IBOutlet UITextField *gradeTextField;
@property (nonatomic, weak) IBOutlet UIView *gradeContainer;
@property (nonatomic, weak) IBOutlet UILabel *gradeContextLabel;

@property (nonatomic, weak) IBOutlet UILabel *activityStatusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityStatusIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *activityStatusImageView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickVersionHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickVersionVerticalPaddingConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickFileHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickFileVerticalPaddingConstraint;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) CSGGradingRubricTableViewController *tableViewController;
@property (nonatomic, strong) UIPopoverController *popController;

@property (nonatomic, strong) UITapGestureRecognizer *pickVersionTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *pickFileTapGestureRecognizer;

@property (nonatomic, strong) CSGToaster *toaster;
@end

@implementation CSGGradingRubricViewController

+ (instancetype)instantiateFromStoryboard {
    CSGGradingRubricViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toaster = [CSGToaster new];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMM d, yyyy hh:mma"];
    
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup View Methods

- (void)setupView {
    self.view.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];
    
    [self setupVersionPickView];
    [self setupFilePickView];
    
    [self setupPassFailSegmentedControl];
    [self setupGradeTextField];
    [self setupGradeContextLabel];
    [self setupSendGradeButton];
    [self setupActivityStatusViews];
    
    [self setupRACBindings];
}

- (void)setupVersionPickView {
    self.pickVersionView.layer.cornerRadius = 3.0f;
    self.pickVersionView.layer.shadowOpacity = 1.0;
    self.pickVersionView.layer.shadowRadius = 1.0;
    self.pickVersionView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.pickVersionView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    
    self.pickVersionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickVersionPressed:)];
}

- (void)setupFilePickView {
    self.pickFileView.layer.cornerRadius = 3.0f;
    self.pickFileView.layer.borderColor = [RGB(225, 226, 223) CGColor];
    self.pickFileView.layer.borderWidth = 1.0f;
    
    self.pickFileTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickFilePressed:)];
}

- (void)setupPassFailSegmentedControl {
    self.passFailSegmentedControl.tintColor = [UIColor csg_gradingRailDarkSegmentControlColor];
    [self.passFailSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}
                                                 forState:UIControlStateNormal];
    [self.passFailSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}
                                                 forState:UIControlStateSelected];
    [self.passFailSegmentedControl addTarget:self action:@selector(passFailValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setupGradeTextField {
    self.gradeTextField.textAlignment = NSTextAlignmentRight;
    self.gradeContainer.layer.cornerRadius = 3.0f;
    self.gradeContainer.layer.masksToBounds = YES;
    self.gradeContainer.layer.borderColor = [RGB(225, 226, 223) CGColor];
    self.gradeContainer.layer.borderWidth = 1.0f;
}

- (void)setupGradeContextLabel {
    self.gradeContextLabel.textColor = [UIColor csg_gradingRailGradeContextLabelTextColor];
    self.gradeContextLabel.font = [UIFont boldSystemFontOfSize:17.0f];
}

- (void)setupSendGradeButton {
    
    [self.sendGradeButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingRailSubmitGradeButtonBackgroundColor]] forState:UIControlStateNormal];
    [self.sendGradeButton setBackgroundImage:[UIImage imageWithColor:[UIColor csg_gradingRailSubmitGradeDisabledButtonBackgroundColor]] forState:UIControlStateDisabled];
    [self.sendGradeButton setTitleColor:[UIColor csg_gradingRailSubmitGradeButtonTextColor] forState:UIControlStateNormal];
    [self.sendGradeButton setTitleColor:[UIColor csg_gradingRailSubmitGradeDisabledButtonTextColor] forState:UIControlStateDisabled];
    
    self.sendGradeButton.layer.cornerRadius = 3.0f;
    self.sendGradeButton.layer.masksToBounds = YES;
}

- (void)setupActivityStatusViews {
    // Hide until Send grade is pressed
    self.activityStatusLabel.alpha = 0.0;
    self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorDefault];
    
    self.activityStatusIndicatorView.alpha = 0.0;
    self.activityStatusIndicatorView.color = [UIColor csg_gradingRailStatusActivityIndicatorColor];
    self.activityStatusImageView.alpha = 0.0;
}

- (void)setupRACBindings {
    
    @weakify(self);
    [RACObserve(self, dataSource.assignment) subscribeNext:^(CKIAssignment *assignment) {
        @strongify(self);
        [self reloadGradingTypeForAssignment:assignment];
        self.gradeTextField.enabled = !assignment.useRubricForGrading;
        self.gradeTextField.textColor = assignment.useRubricForGrading ? [UIColor lightGrayColor] : [UIColor darkGrayColor];
        self.useRubricGradingLabel.hidden = !assignment.useRubricForGrading;
    }];
    
    RACSignal *mergedInputs = [RACSignal merge:@[RACObserve(self, dataSource.selectedSubmissionRecord), RACObserve(self, dataSource.selectedSubmission), RACObserve(self, dataSource.selectedAttachment)]];
    [mergedInputs subscribeNext:^(id changedValue) {
        @strongify(self);
        if ([self.popController isPopoverVisible]) {
            [self.popController dismissPopoverAnimated:YES];
        }
        
        [self reloadSubmissionViews];
    }];

    [self.tableViewController.assessmentChangedSignal subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        [self reloadGradeSubmissionViewsWithScore:self.dataSource.assignment.useRubricForGrading];
    }];
    
    RAC(self, sendGradeButton.enabled) = [RACObserve(self, dataSource.selectedSubmissionGradeOrAssessmentChanged) map:^id(NSNumber *changed) {
        @strongify(self);
        return @(changed.boolValue || (self.dataSource.selectedSubmissionRecord.grade && ![self.dataSource.selectedSubmission isEqual:[NSNull null]] && !self.dataSource.selectedSubmission.gradeMatchesCurrentSubmission));
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CSGGradingRubricTableSegueID]) {
        self.tableViewController = segue.destinationViewController;
    }
}

#pragma mark - UI Actions

- (void)pickVersionPressed:(UITapGestureRecognizer *)sender {
    DDLogInfo(@"PICK VERSION PRESSED");
    CSGPickVersionTableViewController *pickVersionTVC = [CSGPickVersionTableViewController instantiateFromStoryboard];
    self.popController = [[UIPopoverController alloc] initWithContentViewController:pickVersionTVC];
    self.popController.backgroundColor = [UIColor csg_gradingPickerBackgroundColor];
    [self.popController presentPopoverFromRect:sender.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)pickFilePressed:(UITapGestureRecognizer *)sender {
    DDLogInfo(@"PICK FILE PRESSED");
    CSGPickFileTableViewController *pickFileTVC = [[CSGPickFileTableViewController alloc] init];
    self.popController = [[UIPopoverController alloc] initWithContentViewController:pickFileTVC];
    self.popController.backgroundColor = [UIColor csg_studentPickerBackgroundColor];
    [self.popController presentPopoverFromRect:sender.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)sendGrade:(id)sender {
    DDLogInfo(@"SEND GRADE PRESSED");
    NSInteger scoringType = self.dataSource.assignment.scoringType;
    
    NSString *grade = @"";
    switch (scoringType) {
        case CKIAssignmentScoringTypePoints:
            grade = self.gradeTextField.text;
            break;
        case CKIAssignmentScoringTypePercentage:
            grade = [NSString stringWithFormat:@"%@%%", self.gradeTextField.text];
            break;
        case CKIAssignmentScoringTypePassFail:
            grade = (self.passFailSegmentedControl.selectedSegmentIndex == CSGGradingRubricPassFailStatePass) ? NSLocalizedString(@"complete", @"complete title for grade") : NSLocalizedString(@"incomplete", @"incomplete title for grade");
            break;
        case CKIAssignmentScoringTypeLetter:
            grade = self.gradeTextField.text;
            break;
        case CKIAssignmentScoringTypeGPAScale:
            grade = self.gradeTextField.text;
            break;
        default:
            break;
    }
    
    [self postGradeAssessmentsIfNecessary:grade];
}

- (void)postGradeAssessmentsIfNecessary:(NSString *)grade {
    NSTimeInterval animationDuration = CSGShowHideSendGradeAnimationDuration;
    AnimationBlock hideSendGradeButtonAnimation = ^{
        self.sendGradeButton.alpha = 0.0;
        self.gradeContextLabel.alpha = 0.0f;
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorDefault];
        self.activityStatusLabel.text = NSLocalizedString(@"Sending Grade", @"Grade Sending Activity Status");
        
        self.activityStatusIndicatorView.alpha = 1.0;
        [self.activityStatusIndicatorView startAnimating];
    };
    AnimationBlock showGradeSubmittedAnimation = ^{
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorSuccess];
        self.activityStatusLabel.text = NSLocalizedString(@"Success!", @"Grade Sent Success Activity Status");
        
        self.activityStatusIndicatorView.alpha = 0.0;
        [self.activityStatusIndicatorView stopAnimating];
        
        self.activityStatusImageView.alpha = 1.0;
        self.activityStatusImageView.image = [[UIImage imageNamed:@"icon_check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.activityStatusImageView.tintColor = [UIColor csg_gradingRailStatusColorSuccess];
    };
    
    AnimationBlock showGradeSubmitFailedAnimation = ^{
        self.activityStatusLabel.alpha = 1.0;
        self.activityStatusLabel.textColor = [UIColor csg_gradingRailStatusColorFailure];
        self.activityStatusLabel.text = NSLocalizedString(@"Failed!", @"Grade Sent Failure Activity Status");
        
        self.activityStatusIndicatorView.alpha = 0.0;
        [self.activityStatusIndicatorView stopAnimating];
        
        self.activityStatusImageView.alpha = 1.0;
        self.activityStatusImageView.image = [[UIImage imageNamed:@"icon_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.activityStatusImageView.tintColor = [UIColor csg_gradingRailStatusColorFailure];
    };
    
    __block NSString *previousGraderID = self.dataSource.selectedSubmissionRecord.graderID;
    __block BOOL previousWasDummySubmission = [self.dataSource.selectedSubmissionRecord isDummySubmission];
    [UIView animateWithDuration:animationDuration animations:hideSendGradeButtonAnimation completion:^(BOOL finished) {
        // TODO: update the score/rubric etc
        [[TheKeymaster.currentClient updateGrade:grade forSubmissionRecord:self.dataSource.selectedSubmissionRecord] subscribeNext:^(CKISubmissionRecord *submisssionRecord) {
            [self.dataSource replaceSubmissionRecord:self.dataSource.selectedSubmissionRecord withSubmissionRecord:submisssionRecord];
        } error:^(NSError *error) {
            DDLogInfo(@"SEND GRADE ERROR: %@", error.localizedDescription);
            [UIView animateWithDuration:animationDuration animations:showGradeSubmitFailedAnimation completion:^(BOOL finished) {
                // After we show the grade submitted, let it stay for
                [self performSelector:@selector(showSendGradeButton) withObject:nil afterDelay:CSGShowSendGradeSubmittedTime];
            }];
        } completed:^{
            DDLogInfo(@"SEND GRADE COMPLETED");
            self.dataSource.selectedSubmissionGradeOrAssessmentChanged = NO;
            // if the score was updated and the user did not have a score prior, decrement our needs grading count
            if (!previousGraderID && !previousWasDummySubmission) {
                [self decrementNeedsGradingCount];
            }
            [self reloadGradeSubmissionViewsWithScore:NO];
            
            CKIAssignment *assignment = self.dataSource.assignment;
            NSInteger scoringType = assignment.scoringType;
            
            if (scoringType == CKIAssignmentScoringTypeGPAScale && [self.gradeTextField.text isEqualToString:@""]) {
                NSString *message = NSLocalizedString(@"Not what you expected? Check the assignments Grading Scheme for valid scores", @"GPA save grade error handling");
                [self.toaster statusBarToast:message Color:[UIColor redColor] Duration:5.0f];
            }
            
            [UIView animateWithDuration:animationDuration animations:showGradeSubmittedAnimation completion:^(BOOL finished) {
                // After we show the grade submitted, let it stay for CSGShowSendGradeSubmittedTime
                [self performSelector:@selector(showSendGradeButton) withObject:nil afterDelay:CSGShowSendGradeSubmittedTime];
            }];
        }];
    }];
}

- (void)decrementNeedsGradingCount {
    [[CSGAppDataSource sharedInstance] decrementNeedsGradingCount];
}

- (void)showSendGradeButton {
    [UIView animateWithDuration:CSGShowHideSendGradeAnimationDuration animations:^{
        self.sendGradeButton.alpha = 1.0;
        self.gradeContextLabel.alpha = 1.0f;

        self.activityStatusLabel.alpha = 0.0;
        self.activityStatusImageView.alpha = 0.0;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length + string.length - range.length;
    if (textField == self.gradeTextField && newLength > 0) {
        self.dataSource.selectedSubmissionGradeOrAssessmentChanged = YES;
    }

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([CSGAppDataSource sharedInstance].selectedSubmission.type == CKISubmissionEnumTypeQuiz) {
        CSGToaster *toaster = [[CSGToaster alloc] init];
        [toaster statusBarToast:NSLocalizedString(@"Use the quiz submission pane to modify the grade for this quiz!", @"Message telling the user to don't grade in this portion of the UI") Color:[UIColor cbi_blue] Duration:2.65f];
        return NO;
    }

    return YES;
}

#pragma mark - UISegmentedControl value changed

- (void)passFailValueChanged
{
    self.dataSource.selectedSubmissionGradeOrAssessmentChanged = YES;
}

#pragma mark - Reload View Methods

- (void)reloadSubmissionViews {
    [self reloadVersionPickView];
    [self reloadFilePickView];
    [self reloadGradeSubmissionViewsWithScore:NO];
}

- (void)reloadGradingTypeForAssignment:(CKIAssignment *)assignment {
    NSInteger scoringType = assignment.scoringType;
    
    self.sendGradeButton.hidden = NO;
    // default visible
    self.passFailSegmentedControl.hidden = YES;
    self.gradeContextLabel.hidden = NO;
    self.gradeTextField.hidden = NO;
    self.gradeContainer.hidden = NO;
    
    switch (scoringType) {
        case CKIAssignmentScoringTypePoints:
            self.gradeTextField.placeholder = @"Points";
            self.gradeTextField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case CKIAssignmentScoringTypePercentage:
            self.gradeTextField.placeholder = @"%";
            self.gradeTextField.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case CKIAssignmentScoringTypeLetter:
            self.gradeTextField.placeholder = @"Letter";
            self.gradeTextField.keyboardType = UIKeyboardTypeDefault;
            break;
        case CKIAssignmentScoringTypeGPAScale:
            self.gradeTextField.placeholder = @"GPA";
            self.gradeTextField.keyboardType = UIKeyboardTypeDefault;
            break;
        case CKIAssignmentScoringTypePassFail:
            self.passFailSegmentedControl.hidden = NO;
            
            // hide everything else so it doesn't show up below
            self.gradeContextLabel.hidden = YES;
            self.gradeTextField.hidden = YES;
            self.gradeContainer.hidden = YES;
            break;
        case CKIAssignmentScoringTypeNotGraded:
            // This shouldn't be needed as there won't be any assignments in this category in the app
            self.gradeContextLabel.hidden = YES;
            self.gradeTextField.hidden = YES;
            self.gradeContainer.hidden = YES;
            self.sendGradeButton.hidden = [self.dataSource.assignment.rubricCriterion count] || self.dataSource.assignment.rubric ? NO : YES;
        default:
            break;
    }
}

- (void)reloadVersionPickView {
    NSUInteger numSubmissions = [self.dataSource.selectedSubmissionRecord.submissionHistory count];
    
    CKISubmission * selectedSubmission = self.dataSource.selectedSubmission;
    
    if (selectedSubmission && ![selectedSubmission isEqual:[NSNull null]]) {
        self.pickVersionAttemptLabel.text = [NSString stringWithFormat:@"Attempt %lu", (unsigned long)selectedSubmission.attempt];
        if ([selectedSubmission late]) {
            NSString *late = NSLocalizedString(@"Late", @"Late submission subtitle text");
            NSString *dateString = [self.dateFormatter stringFromDate:selectedSubmission.submittedAt];
            self.pickVersionDateLabel.text = [NSString stringWithFormat: @"%@ (%@)", late, dateString];
            [self.pickVersionDateLabel setTextColor:[UIColor redColor]];
        } else {
            self.pickVersionDateLabel.text = [self.dateFormatter stringFromDate:selectedSubmission.submittedAt];
            [self.pickVersionDateLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    [self.pickVersionView removeGestureRecognizer:self.pickVersionTapGestureRecognizer];
    self.pickVersionAccessoryView.alpha = numSubmissions > 1;
    
    // if we have 0 submissions, we hide this sucker
    if (numSubmissions == 0 || [self.dataSource.selectedSubmissionRecord isDummySubmission]) {
        self.pickVersionAttemptLabel.alpha = 0.0f;
        self.pickVersionDateLabel.alpha = 0.0f;
        
        self.noSubmissionLabel.alpha = 1.0f;
        self.noSubmissionLabel.text = @"No Submission";
    } else {
        self.pickVersionAttemptLabel.alpha = 1.0f;
        self.pickVersionDateLabel.alpha = 1.0f;
        
        self.noSubmissionLabel.alpha = 0.0f;
        
        // only allow the picker to be tapped if there is more than 1 file
        if (numSubmissions > 1) {
            [self.pickVersionView addGestureRecognizer:self.pickVersionTapGestureRecognizer];
        }
    }
}

- (void)reloadFilePickView {
    self.pickFileNameLabel.text = self.dataSource.selectedAttachment.name;
    
    [self.pickFileView removeGestureRecognizer:self.pickFileTapGestureRecognizer];
    
    CKISubmission * selectedSubmission = self.dataSource.selectedSubmission;
    
    if (selectedSubmission && ![selectedSubmission isEqual:[NSNull null]]) {
        NSUInteger numberOfAttachments = [selectedSubmission.attachments count];
        // if we have 0 submissions, we hide this sucker
        if (numberOfAttachments == 0) {
            self.pickFileView.alpha = 0.0f;
            self.pickFileHeightConstraint.constant = 0.0f;
            self.pickFileVerticalPaddingConstraint.constant = 0.0f;
            [self.view layoutIfNeeded];
        } else {
            self.pickFileView.alpha = 1.0f;
            self.pickFileHeightConstraint.constant = 40.0f;
            self.pickFileVerticalPaddingConstraint.constant = 8.0f;
            [self.view layoutIfNeeded];
            
            self.pickFileAccessoryView.alpha = numberOfAttachments > 1;
            
            // only allow the picker to be tapped if there is more than 1 file
            if (numberOfAttachments > 1) {
                [self.pickFileView addGestureRecognizer:self.pickFileTapGestureRecognizer];
            }
        }
    }
}

- (void)reloadGradeSubmissionViewsWithScore:(BOOL)useScore {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.maximumFractionDigits = 2;
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    CKIAssignment *assignment = self.dataSource.assignment;
    CKISubmissionRecord *submissionRecord = self.dataSource.selectedSubmissionRecord;
    NSInteger scoringType = assignment.scoringType;
    
    NSNumber *grade = [formatter numberFromString:submissionRecord.grade];
    NSString *userGrade = grade ? [formatter stringFromNumber:grade] : submissionRecord.grade;
    NSString *userScore = submissionRecord.score ? [formatter stringFromNumber:submissionRecord.score] : @"";
    NSString *pointsPossible = assignment.pointsPossible ? [NSString stringWithFormat:@"%.0f", assignment.pointsPossible] : @"-";
    
    if (useScore) {
        self.gradeTextField.text = userScore;
    } else {
        self.gradeTextField.text = userGrade;
    }
    
    userScore = userScore ? userScore : @"-";
    switch (scoringType) {
        case CKIAssignmentScoringTypePoints:
            self.gradeContextLabel.text = [NSString stringWithFormat:@"(%@ / %@)", userScore, pointsPossible];
            self.gradeTextField.placeholder = @"Points";
            break;
        case CKIAssignmentScoringTypePercentage:
            self.gradeContextLabel.text = [NSString stringWithFormat:@"(%@ / %@)", userScore, pointsPossible];
            self.gradeTextField.placeholder = @"%";
            break;
        case CKIAssignmentScoringTypePassFail:
            if (submissionRecord.grade == nil || submissionRecord.grade.length <= 0) {
                [self.passFailSegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
                break;
            }
            
            if ([self stringValueIsComplete:submissionRecord.grade]) {
                self.passFailSegmentedControl.selectedSegmentIndex = CSGGradingRubricPassFailStatePass;
            } else {
                self.passFailSegmentedControl.selectedSegmentIndex = CSGGradingRubricPassFailStateFail;
            }
            break;
        case CKIAssignmentScoringTypeLetter:
            self.gradeContextLabel.text = [NSString stringWithFormat:@"(%@ / %@)", userScore, pointsPossible];
            self.gradeTextField.placeholder = @"Letter";
            break;
        case CKIAssignmentScoringTypeGPAScale:
            self.gradeContextLabel.text = @"";
            self.gradeTextField.placeholder = @"GPA";
            break;
        case CKIAssignmentScoringTypeNotGraded:
            // Do Nothing, this assignment is not graded
        default:
            break;
    }
}

- (BOOL)stringValueIsComplete:(NSString *)string {
    return [string isEqualToString:@"complete"] || [string isEqualToString:@"pass"];
}

@end
