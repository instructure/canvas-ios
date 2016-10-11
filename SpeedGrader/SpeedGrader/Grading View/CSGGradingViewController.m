//
// CSGGradingViewController.m
// Created by Jason Larsen on 5/1/14.
//

#import <CanvasKit/CKIClient+CKIAssignment.h>
#import <CanvasKit/CanvasKit.h>
#import <CanvasKeymaster/CanvasKeymaster.h>

#import "CSGGradingViewController.h"
#import "CSGSidebarViewController.h"
#import "CSGDocumentHandler.h"
#import "CSGDocumentViewControllerFactory.h"
#import "CSGStudentPickerViewController.h"
#import "CSGSubmissionViewController.h"
#import "CSGAppDataSource.h"
#import "CSGFlyingPandaActivityView.h"
#import "CSGNoResultsView.h"
#import "CSGToaster.h"
#import "UIImage+Color.h"
#import "UIColor+Canvas.h"
#import "UIColor+CSGColor.h"

@import Masonry;

static CGFloat const DrawerMaxWidth = 301.0f;
static CGFloat const DrawerDefaultAnimationDuration = 0.25f;
static CGFloat const MenuPanVelocityXThreshold = 200.0f;
static CGFloat const MaxXCloseConstantThreshold = -200.0f;
static CGFloat const MinXOpenConstantThreshold = -100.0f;

static CGFloat const CSGGradingTitleViewMaxWidth = 300.0f;
static CGFloat const CSGGradingTitleViewMinWidth = 150.0f;
static CGFloat const CSGGradingTitleViewHeight = 34.0f;

static NSString *const CSGGradingEmbedGradingSegueID = @"embed_grading_view";
static NSString *const CSGGradingEmbedPreviewSegueID = @"embed_preview_view";

static NSString *const CSGDidBounceGradingDrawerKey = @"bounced_grading_drawer";


NSString *const CSGGradingRemoveCommentsNotification = @"CSGGradingRemoveCommentsNotification";

@interface CSGGradingViewController () <UIGestureRecognizerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *documentViewContainer;
@property (nonatomic, weak) IBOutlet UIView *sidebarViewContainer;
@property (nonatomic, weak) IBOutlet UIView *sidebarWithTabView;

@property (nonatomic, weak) IBOutlet CSGFlyingPandaActivityView *flyingPandaView;

@property (nonatomic, strong) UIPageViewController *previewPageViewController;
@property (nonatomic, strong) CSGSidebarViewController *sidebarViewController;
@property (nonatomic, strong) CSGStudentPickerViewController *studentPickerViewController;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIBarButtonItem *muteButton;
@property (nonatomic, strong) UIPopoverController *studentPopoverController;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic) BOOL animatingDrawer;
@property (nonatomic) BOOL drawerOpen;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) CGPoint referencePanLocation;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sidebarRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentRightConstraint;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

@property (nonatomic, strong) CSGAppDataSource *dataSource;
@property (nonatomic, strong) CSGToaster *toaster;
@property (nonatomic, assign) BOOL willFetchModels;
@end

@implementation CSGGradingViewController

+ (instancetype)instantiateFromStoryboard {
    CSGGradingViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toaster = [CSGToaster new];
    self.dataSource = [CSGAppDataSource sharedInstance];
    [self setupView];
    // start drawer closed
    [self closeDrawerAnimated:NO completion:nil];
    
    if (self.willFetchModels == NO) {
        [self fetchSubmissionsAndEnrollments];
    }
    
    @weakify(self);
    [RACObserve(self, dataSource.selectedSubmissionRecord) subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        [self updateActionButtonForSubmissionRecord:submissionRecord];
        [self updateTitleForSubmissionRecord:submissionRecord];
        [self updateBarButtons];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentVCFinishedLoading:) name:kDocumentVCFinishedLoading object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentVCShouldCaptureTouch:) name:kDocumentVCShouldCaptureTouch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentVCShouldNotCaptureTouch:) name:kDocumentVCShouldNotCaptureTouch object:nil];
}

- (void)fetchDataForAssignment:(CKIAssignment *)assignment forCourse:(CKICourse *)course {
    self.willFetchModels = YES;
    [[CSGAppDataSource sharedInstance] fetchAssignmentModel:assignment withCourse:course withSuccess:^{
        [self fetchSubmissionsAndEnrollments];
        self.willFetchModels = NO;
    } failure:^(NSError *error) {
        DDLogError(@"Error while fetching data for course/assignment models: %@", error);
        self.willFetchModels = NO;
        [self.navigationController pushViewController:[CSGDocumentViewControllerFactory createViewControllerForHandlingError] animated:NO];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)documentVCFinishedLoading:(NSNotification *)notification {
    [self.flyingPandaView dismiss];
    [self updateBarButtons];
}

- (void)documentVCShouldCaptureTouch:(NSNotification *)notification {
    for (UIScrollView *view in self.previewPageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
}

- (void)documentVCShouldNotCaptureTouch:(NSNotification *)notification {
    for (UIScrollView *view in self.previewPageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = YES;
        }
    }
}

#pragma mark - SetupView

- (void)initializeStudentPicker {
    self.studentPickerViewController = [CSGStudentPickerViewController instantiateFromStoryboard];
    
    // when a new student is picked we reload all views at the new center view controller
    @weakify(self);
    [self.studentPickerViewController.submissionRecordPickedSignal subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            // first dismiss the student picker
            if (self.studentPopoverController.isPopoverVisible) {
                [self.studentPopoverController dismissPopoverAnimated:YES];
            }
            
            [self reloadCenterViewControllerWithSubmissionRecord:submissionRecord];
        });
    }];
}

- (void)setupView {
    self.sidebarWithTabView.alpha = 0.0;
}

- (void)activateSubmissionSpecificViews {
    [self initializeStudentPicker];
    [self setupSidebarWithTabView];
    [self setupSidebarView];
    [self setupNavigationItems];
    
    [UIView animateWithDuration:DrawerDefaultAnimationDuration animations:^{
        self.sidebarWithTabView.alpha = 1.0f;
    }];
}

- (void)setupTitleViewWithTitle:(NSString *)title {
    if (!title) {
        return;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]};
    CGSize titleRect = [title sizeWithAttributes:attributes];
    CGFloat width = titleRect.width < CSGGradingTitleViewMaxWidth ? titleRect.width : CSGGradingTitleViewMaxWidth;
    width = width >= CSGGradingTitleViewMinWidth ? width : CSGGradingTitleViewMinWidth;
    
    self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, CSGGradingTitleViewHeight)];
    [self.titleButton addTarget:self action:@selector(studentPickerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleButton setBackgroundColor:[UIColor csg_tappableButtonBackgroundColor]];
    [self.titleButton.layer setMasksToBounds:YES];
    [self.titleButton.layer setCornerRadius:10.0f];
    self.navigationItem.titleView = self.titleButton;
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    self.titleButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
}

- (void)setupSidebarWithTabView {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanSidebar:)];
    [self.sidebarWithTabView addGestureRecognizer:panGestureRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSidebar:)];
    tapGestureRecognizer.delegate = self;
    [self.sidebarWithTabView addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupSidebarView {
    self.sidebarWithTabView.clipsToBounds = NO;
    self.sidebarViewContainer.backgroundColor = [UIColor csg_offWhite];
}

- (void)setupNavigationItems {
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPressed:)];
    self.navigationItem.rightBarButtonItem = self.actionButton;
    

    if (self.dataSource.assignment.muted) {
        self.muteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_mute"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMute:)];
    } else {
        self.muteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_unmute"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMute:)];
    }
    
    self.navigationItem.rightBarButtonItems = @[self.actionButton, self.muteButton];
}

- (BOOL)navigationShouldPopOnBackButton {
    if (self.dataSource.selectedSubmissionCommentChanged || self.dataSource.selectedSubmissionGradeOrAssessmentChanged) {
        void (^noHandler)() = ^void() {
            self.dataSource.selectedSubmissionCommentChanged = NO;
            self.dataSource.selectedSubmissionGradeOrAssessmentChanged = NO;
            [self.navigationController popViewControllerAnimated:YES];
        };
        void (^yesHandler)() = ^void() {
            // Nothing to do here :)  Proceed
        };
        
        [self presentUnfinishedGradingAlertWithYesAction:yesHandler noAction:noHandler];
        
        return NO;
    }
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    *rect = [self frameForStudentPopoverPoint];
}

#pragma mark - Helpers

- (CGRect)frameForStudentPopoverPoint {
    return CGRectMake(self.navigationItem.titleView.center.x, self.navigationItem.titleView.center.y, 1, self.navigationItem.titleView.frame.size.height - 10);
}

#pragma mark - UI Actions

- (void)toggleMute:(id)sender {
    self.dataSource.assignment.muted = !self.dataSource.assignment.muted;
    DDLogInfo(@"MUTE PRESSED: %@", self.dataSource.assignment.muted ? @"MUTED" : @"UNMUTED");
    
    [self.muteButton setEnabled:NO];
    RACSignal *muteSignal = [[TheKeymaster currentClient] updateMutedForAssignment:self.dataSource.assignment];
    [muteSignal subscribeNext:^(CKIAssignment *assignment) {
        //you could do stuff here if you wanted
    } error:^(NSError *error) {
        DDLogInfo(@"MUTE SET FAILED: %@", error.localizedDescription);
        self.dataSource.assignment.muted = !self.dataSource.assignment.muted;
        if (self.dataSource.assignment.muted) {
            [self.muteButton setImage:[[UIImage imageNamed:@"icon_mute"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        } else {
            [self.muteButton setImage:[UIImage imageNamed:@"icon_unmute"]];
        }
        [self.muteButton setEnabled:YES];
        
        NSString *message = NSLocalizedString(@"Error trying to toggle the mute property for this assignment", @"Error toggling mute button for assignment");
          [self.toaster statusBarToast:message Color:[UIColor cbi_red] Duration:5.0f];
    } completed:^{
        DDLogInfo(@"MUTE SET SUCCEEDED: %@", self.dataSource.assignment.muted ? @"MUTED" : @"UNMUTED");
        if (self.dataSource.assignment.muted) {
          [self.muteButton setImage:[[UIImage imageNamed:@"icon_mute"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        } else {
          [self.muteButton setImage:[UIImage imageNamed:@"icon_unmute"]];
        }
        [self.muteButton setEnabled:YES];
    }];
}

- (void)actionPressed:(id)sender {
    DDLogInfo(@"ACTION PRESSED");
    
    CSGSubmissionViewController *currentController = self.previewPageViewController.viewControllers[0];
    CKISubmissionRecord *submissionRecord = currentController.submissionRecord;
    if (currentController.documentViewController.cachedAttachmentURL) {
        DDLogInfo(@"ACTION URL: %@", currentController.documentViewController.cachedAttachmentURL);
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:currentController.documentViewController.cachedAttachmentURL];
        [self.documentInteractionController presentOpenInMenuFromBarButtonItem:self.actionButton animated:YES];
    } else {
        NSMutableArray *items = [NSMutableArray array];
        if (submissionRecord.body) {
            [items addObject:submissionRecord.body];
        }
        if (submissionRecord.url) {
            [items addObject:submissionRecord.url];
        }
        DDLogInfo(@"ACTION URL: %@ BODY: %@", submissionRecord.url, submissionRecord.body);
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
            activityViewController.popoverPresentationController.barButtonItem = self.actionButton;
        }
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    
}

- (void)studentPickerPressed:(UIButton *)sender {
    
    DDLogInfo(@"STUDENT PICKER PRESSED");
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    navController.navigationBar.barTintColor = [UIColor csg_studentPickerHeaderBackgroundColor];
    [navController pushViewController:self.studentPickerViewController animated:NO];
    [navController.navigationBar setBarTintColor:[UIColor csg_studentPickerBackgroundColor]];

    navController.navigationController.navigationBar.barTintColor = [UIColor csg_studentPickerBackgroundColor];
    navController.navigationController.navigationBar.shadowImage = [UIImage new];
    navController.navigationController.navigationBar.translucent = NO;

    self.studentPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.studentPopoverController.backgroundColor = [UIColor csg_studentPopoverBackgroundColor];
    self.studentPopoverController.delegate = self;
    [self.studentPopoverController presentPopoverFromRect:[self frameForStudentPopoverPoint] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)didPanSidebar:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];

    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            if(self.animatingDrawer) {
                [panGestureRecognizer setEnabled:NO];
                break;
            }
            else {
                self.animatingDrawer = YES;
                self.referencePanLocation = location;
            }
        }
        case UIGestureRecognizerStateChanged:{
            CGFloat xDelta = location.x - self.referencePanLocation.x;
            CGFloat newSidebarConstant = self.sidebarRightConstraint.constant - xDelta;
            newSidebarConstant = fmaxf(-DrawerMaxWidth, newSidebarConstant);
            newSidebarConstant = fminf(newSidebarConstant, 0.0f);

            self.referencePanLocation = location;

            self.sidebarRightConstraint.constant = newSidebarConstant;
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            self.animatingDrawer = NO;
            
            CGFloat xVelocity = velocity.x;
            if(xVelocity < MenuPanVelocityXThreshold){
                [self openDrawerAnimated:YES completion:nil];
            }
            else if(xVelocity > MenuPanVelocityXThreshold){
                [self closeDrawerAnimated:YES completion:nil];
            }
            else if(self.sidebarRightConstraint.constant > MaxXCloseConstantThreshold){
                [self closeDrawerAnimated:YES completion:nil];
            }
            else if(self.sidebarRightConstraint.constant > MinXOpenConstantThreshold){
                [self openDrawerAnimated:YES completion:nil];
            }
            else {
                [self openDrawerAnimated:YES completion:nil];
            }
            
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            self.animatingDrawer = NO;
            
            [panGestureRecognizer setEnabled:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didTapSidebar:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self toggleDrawerAnimated:YES completion:nil];
}

#pragma mark - Grading Sidebar Controls

- (void)bounceDrawerIfNeeded {
    if (self.animatingDrawer || [[NSUserDefaults standardUserDefaults] boolForKey:CSGDidBounceGradingDrawerKey]) {
        return;
    }
    
    self.animatingDrawer = YES;
    
    self.sidebarRightConstraint.constant = -(DrawerMaxWidth + 50);
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];

    self.sidebarRightConstraint.constant = -DrawerMaxWidth;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.0f delay:0 usingSpringWithDamping:0.3f initialSpringVelocity:0.5f options:0 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.animatingDrawer = NO;
    }];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CSGDidBounceGradingDrawerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.drawerOpen) {
        [self closeDrawerAnimated:animated completion:completion];
    } else {
        [self openDrawerAnimated:animated completion:completion];
    }
}

- (void)openDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.animatingDrawer) {
        if(completion){
            completion(NO);
        }
        return;
    }

    self.animatingDrawer = animated;

    self.sidebarRightConstraint.constant = -2.0f;
    self.contentRightConstraint.constant = DrawerMaxWidth;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animated ? DrawerDefaultAnimationDuration : 0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.animatingDrawer = NO;
        self.drawerOpen = YES;
        if (completion) {
            completion(YES);
        }
    }];
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if(self.animatingDrawer){
        if(completion){
            completion(NO);
        }
        return;
    }

    self.animatingDrawer = animated;

    self.sidebarRightConstraint.constant = -DrawerMaxWidth;
    self.contentRightConstraint.constant = 0.0f;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animated ? DrawerDefaultAnimationDuration : 0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.animatingDrawer = NO;
        self.drawerOpen = NO;

        if (completion) {
            completion(YES);
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // ignore touches that are in descendant views of the sidebar container.  We only want the touch to go through if it's on the container view.
    if (self.sidebarViewContainer.superview != nil) {
        if ([touch.view isDescendantOfView:self.sidebarViewContainer]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Data Fetching

- (void)fetchSubmissionsAndEnrollments {
    
    [self.flyingPandaView show];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
            self.dataSource.studentSortOrder = CSGStudentSortOrderGradeRandom;
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsShowUngradedFirst]]) {
            self.dataSource.studentSortOrder = CSGStudentSortOrderGrade;
        } else {
            self.dataSource.studentSortOrder = CSGStudentSortOrderAlphabetical;
        }
    }
    
    [self.dataSource reloadSubmissionsWithStudentsWithSuccess:^{
        [self bounceDrawerIfNeeded];

        // Update the view once data has returned
        [self activateSubmissionSpecificViews];
        [self setupTitleViewWithTitle:@""];
        
        // Prevent the previewPageController from swiping until we have some data to populate.
        // If the delegate/dataSource is nil then we can't swipe
        self.previewPageViewController.delegate = self;
        self.previewPageViewController.dataSource = self;
        
        if ([self.dataSource.initialSubmission.defaultAttempt isEqual:[NSNull null]]){
            [self.flyingPandaView dismiss];
        }
        
        if (![self.dataSource.sortedStudentsByName count]) {
            [self reloadCenterViewControllerWithNoResultsView];
            [self.flyingPandaView dismiss];
        } else {
            [self reloadCenterViewControllerWithSubmissionRecord:[self.dataSource initialSubmission]];
        }
    } failure:^(NSError *error) {
        //TODO: Handle Errors
        [self.flyingPandaView dismiss];
    }];
}

- (void)reloadCenterViewControllerWithNoResultsView {
    UIViewController *noResultsViewController = [UIViewController new];
    CSGNoResultsView *noResultsView = [CSGNoResultsView instantiateFromXib];
    noResultsView.imageView.image = [UIImage imageNamed:@"panda_superman"];
    noResultsView.tintColor = [UIColor lightGrayColor];
    
    noResultsView.commentLabel.text = NSLocalizedString(@"SuperPanda found no students in this assignment for you to grade.", @"No Submissions Text");
        noResultsView.frame = noResultsViewController.view.bounds;
    noResultsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [noResultsViewController.view addSubview:noResultsView];
    
    [self.previewPageViewController setViewControllers:@[noResultsViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)reloadCenterViewControllerWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord {
    
    void (^noHandler)() = ^void() {
        self.dataSource.selectedSubmissionGradeOrAssessmentChanged = NO;
        self.dataSource.selectedSubmissionCommentChanged = NO;
        self.dataSource.selectedSubmissionRecord = submissionRecord;
        self.dataSource.selectedStudent = [self.dataSource userForSubmission:submissionRecord];
        
        CSGSubmissionViewController *submissionViewController = [CSGSubmissionViewController instantiateFromStoryboard];
        submissionViewController.submissionRecord = submissionRecord;
        [self.previewPageViewController setViewControllers:@[submissionViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    };
    
    if (self.dataSource.selectedSubmissionGradeOrAssessmentChanged || self.dataSource.selectedSubmissionCommentChanged) {
        [self presentUnfinishedGradingAlertWithYesAction:nil noAction:noHandler];
    } else {
        noHandler();
    }
}

#pragma mark - Transitions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CSGGradingEmbedGradingSegueID]) {
        self.sidebarViewController = segue.destinationViewController;
    }
    if ([segue.identifier isEqualToString:CSGGradingEmbedPreviewSegueID]) {
        self.previewPageViewController = segue.destinationViewController;
    }
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController<CSGDocumentHandler> *currentViewController = (UIViewController<CSGDocumentHandler> *)viewController;
    
    CKISubmissionRecord *submissionRecord = [self.dataSource submissionRecordForStudentPriorTo:currentViewController.submissionRecord];
    if (submissionRecord != nil) {
        CSGSubmissionViewController *submissionViewController = [CSGSubmissionViewController instantiateFromStoryboard];
        submissionViewController.submissionRecord = submissionRecord;
        return submissionViewController;
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController<CSGDocumentHandler> *currentViewController = (UIViewController<CSGDocumentHandler> *)viewController;
    
    CKISubmissionRecord *submissionRecord = [self.dataSource submissionRecordForStudentFollowing:currentViewController.submissionRecord];
    if (submissionRecord != nil) {
        CSGSubmissionViewController *submissionViewController = [CSGSubmissionViewController instantiateFromStoryboard];
        submissionViewController.submissionRecord = submissionRecord;
        return submissionViewController;
    } else {
        return nil;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        return;
    }

    void (^noHandler)() = ^void() {
        [self updateBarButtons];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CSGGradingRemoveCommentsNotification object:nil];
        
        CSGSubmissionViewController *currentController = pageViewController.viewControllers[0];
        CKISubmissionRecord *submissionRecord = currentController.submissionRecord;
        self.dataSource.selectedSubmissionRecord = submissionRecord;
        self.dataSource.selectedStudent = [self.dataSource userForSubmission:submissionRecord];
        self.dataSource.selectedSubmissionGradeOrAssessmentChanged = NO;
        self.dataSource.selectedSubmissionCommentChanged = NO;
    };
    void (^yesHandler)() = ^void() {
        UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionReverse;
        CSGSubmissionViewController *previousVC = previousViewControllers[0];
        CSGSubmissionViewController *nextVC = (CSGSubmissionViewController *)[self pageViewController:pageViewController viewControllerAfterViewController:pageViewController.viewControllers[0]];
        if ([nextVC.submissionRecord.id isEqualToString:previousVC.submissionRecord.id]) {
            // just went backwards, so go forward instead
            direction = UIPageViewControllerNavigationDirectionForward;
        }
        [pageViewController setViewControllers:previousViewControllers direction:direction animated:YES completion:nil];
    };

    if (self.dataSource.selectedSubmissionGradeOrAssessmentChanged || self.dataSource.selectedSubmissionCommentChanged) {
        [self presentUnfinishedGradingAlertWithYesAction:yesHandler noAction:noHandler];
    } else {
        noHandler();
    }

}

- (void)presentUnfinishedGradingAlertWithYesAction:(void (^)(UIAlertAction *action))yesHandler noAction:(void (^)(UIAlertAction *action))noHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unfinished Grading", @"Title for alert displayed when the user has graded an assignment to some extend and hasn't submitted that assessment.") message:NSLocalizedString(@"You have began assessing the prior submission but you didn't submit that assessment. Would you like to go back and do so?", @"Text for alert displayed when the user has graded an assignment to some extend and hasn't submitted that assessment.") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:noHandler];
    [alertController addAction:noAction];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:yesHandler];
    [alertController addAction:yesAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// Hopefully Unnecessary after changes
- (void)updateTitleForSubmissionRecord:(CKISubmissionRecord *)submissionRecord {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
        NSUInteger submissionIndex = [self.dataSource userIndexForSubmission:submissionRecord];
        [self setupTitleViewWithTitle:[NSString stringWithFormat:@"Student %lu", (unsigned long)submissionIndex]];
    } else {
        CKIUser *userForSubmission = [self.dataSource userForSubmission:submissionRecord];
        [self setupTitleViewWithTitle:userForSubmission.sortableName];
    }
}

- (void)updateActionButtonForSubmissionRecord:(CKISubmissionRecord *)submissionRecord {
    BOOL enabled = ![submissionRecord isDummySubmission];
    if ([submissionRecord.submissionType isEqualToString:CKISubmissionTypeMediaRecording] || [submissionRecord.submissionType isEqualToString:CKISubmissionTypeDiscussion] || [submissionRecord.submissionType isEqualToString:CKISubmissionTypeQuiz]) {
        enabled = NO;
    }
    self.actionButton.enabled = enabled;
}

- (void)updateBarButtons {
    [self setupNavigationItems];
    
    if (self.previewPageViewController.viewControllers.firstObject) {
        CSGSubmissionViewController *currentController = self.previewPageViewController.viewControllers[0];
        if ([currentController.documentViewController respondsToSelector:@selector(additionalBarButtons)]) {
            NSArray *additionalBarButtons = [currentController.documentViewController additionalBarButtons];
            self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItems arrayByAddingObjectsFromArray:additionalBarButtons];
        }
    }
}

@end
