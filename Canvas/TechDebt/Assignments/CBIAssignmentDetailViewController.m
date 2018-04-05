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
    
    

#define DETAIL_TAB_INDEX 0
#define SUBMISSION_TAB_INDEX 1
#define GRADE_TAB_INDEX 2

#import "CBIAssignmentDetailViewController.h"
#import "RubricViewController.h"
#import "AssignmentDetailsViewController.h"
#import "CBIGradeDetailView.h"
#import <CanvasKit/CanvasKit.h>
#import <CanvasKit1/CanvasKit1.h>
#import "CBIAssignmentViewModel.h"
#import "CBIContentLockViewController.h"
#import "CBIStudentSubmissionViewModel.h"
#import "CBIStudentSubmissionViewController.h"
#import "CBITeacherSubmissionViewModel.h"
#import "CBILocalNotificationHandler.h"
#import <StoreKit/StoreKit.h>
#import "EXTScope.h"
#import "CKCanvasAPI+CurrentAPI.h"
#import "CBILog.h"
#import "UIImage+TechDebt.h"

@import CanvasKeymaster;
@import Masonry;
@import CanvasCore;

static NSUInteger const CBIAssignmentDetailNumMinutesInHour = 60;
static NSUInteger const CBIAssignmentDetailNumMinutesInDay = 60 * 24;

@interface CBIAssignmentDetailViewController () <UIActionSheetDelegate, SKStoreProductViewControllerDelegate, ModuleItemEmbeddedProtocol>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) AssignmentDetailsViewController *detailsController;
@property (strong, nonatomic) MLVCTableViewController *submissionController;
@property (strong, nonatomic) RubricViewController *rubricController;
@property (strong, nonatomic) NSArray *unselectedTabs;
@property (strong, nonatomic) CBILocalNotificationHandler *localNotificationHandler;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *preparingTabsActivityIndicator;
@property (nonatomic) NSInteger previousSelectedTab;
@property (nonatomic) PageViewEventLoggerLegacySupport *pageViewEventLog;
@end

@implementation CBIAssignmentDetailViewController

@dynamic viewModel;

- (id)init
{
    return [[UIStoryboard storyboardWithName:@"CBIAssignmentDetail" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewEventLog = [PageViewEventLoggerLegacySupport new];
    
    RAC(self, view.tintColor) = RACObserve(self, viewModel.tintColor);
    
    self.localNotificationHandler = [CBILocalNotificationHandler sharedInstance];

    RACSignal *haveSubmissionViewController = [RACObserve(self, submissionController) map:^id(id value) {
        return @(value != nil);
    }];
    
    RAC(self, preparingTabsActivityIndicator.hidden) = haveSubmissionViewController;
    RAC(self, segmentedControl.layer.opacity) = haveSubmissionViewController;
    @weakify(self);
    
    [self displayContentLockIfNecessary];
    self.contentView.hidden = YES;
    [[[CKIClient currentClient] refreshModel:self.viewModel.model parameters:nil] subscribeError:^(NSError *error) {
        if (error.code == NSURLErrorBadServerResponse) {
            [self display404ErrorMessage];
        }
    } completed:^{
        @strongify(self);
        self.contentView.hidden = NO;
        [self initializeTabs];
        [self setupSegmentedControl];
        [self setTab:DETAIL_TAB_INDEX];
        [self displayContentLockIfNecessary];
        [self setupRightBarButtonItems];

        [[[self.viewModel fetchSubmissionsViewModel] map:^id(id<CBISubmissionsViewModel> submissionViewModel) {
            return [submissionViewModel createViewController];
        }] subscribeNext:^(MLVCTableViewController *submissionController) {
            @strongify(self);
            self.submissionController = submissionController;
        } error:^(NSError *error) {
            @strongify(self);

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Network Error", nil, [NSBundle bundleForClass:[self class]], @"Network error title") message:NSLocalizedStringFromTableInBundle(@"Please check your network connection and try again.", nil, [NSBundle bundleForClass:[self class]], @"Network error message") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Dismiss", nil, [NSBundle bundleForClass:[self class]], @"Dismiss button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // nothing to do.
            }]];
            [self presentViewController:alert animated:true completion:nil];
        }];
    }];
    
    [self initializeTabs];
    [self setupSegmentedControl];
    [self setTab:DETAIL_TAB_INDEX];

    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pageViewEventLog start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CKIAssignment *assignment = self.viewModel.model;
    NSString *path = [NSString stringWithFormat:@"%@", assignment.htmlURL.absoluteString];
    if (self.moduleItemID) {
        path = [NSString stringWithFormat:@"%@?module_item_id=%@", path, self.moduleItemID];
    }
    [self.pageViewEventLog stopWithEventName:path];
}


- (void)setupRightBarButtonItems {
    CKIAssignment *assignment = self.viewModel.model;
    if ([assignment.dueAt compare:[NSDate date]] == NSOrderedDescending) {
        [self setAlarmButton:[self.localNotificationHandler localNotificationExists:assignment.id]];
    }
}

- (CGFloat) getContentInset{
    return self.toolbarControl.frame.origin.y + self.toolbarControl.frame.size.height;
}

- (void)initializeTabs
{
    CKIAssignment *assignment = self.viewModel.model;
    CKAssignment *backwardsCompatibleAssignment = [[CKAssignment new] initWithInfo:[assignment JSONDictionary]];
    
    self.detailsController = [AssignmentDetailsViewController new];
    self.detailsController.prependAssignmentInfoToContent = YES;
    [self.detailsController setAssignment:backwardsCompatibleAssignment];

    self.rubricController = [[RubricViewController alloc] init];
    self.rubricController.canvasAPI = CKCanvasAPI.currentAPI;
    self.rubricController.assignment = backwardsCompatibleAssignment;
    
    CKCanvasAPI *canvasAPI = CKCanvasAPI.currentAPI;;
    [canvasAPI getSubmissionForAssignment:backwardsCompatibleAssignment
                                studentID:TheKeymaster.currentClient.currentUser.id.longLongValue
                           includeHistory:NO
                                    block:^(NSError *error, BOOL isLiveValue, CKSubmission *submission)
     {
         submission.assignment = backwardsCompatibleAssignment;
         self.rubricController = [self.rubricController initWithSubmission:submission];
         self.rubricController.pageViewName = [NSString stringWithFormat:@"%@/submissions/%llu", assignment.htmlURL.absoluteString, submission.ident];
         CBIGradeDetailView *gradeView = [[CBIGradeDetailView alloc] initWithAssignment:backwardsCompatibleAssignment andSubmission:submission];
         self.rubricController.rubricTableView.tableHeaderView = gradeView;
     }];

    if (!self.submissionController) {
        [self.preparingTabsActivityIndicator startAnimating];
    }
    
    self.detailsController.view.backgroundColor = [UIColor whiteColor];
    self.rubricController.view.backgroundColor = [UIColor whiteColor];
    
    [self.detailsController.view setAccessibilityElementsHidden:YES];
    [self.submissionController.tableView setAccessibilityElementsHidden:YES];
    [self.rubricController.rubricTableView setAccessibilityElementsHidden:YES];
}

- (void)setTitles
{
    [self.segmentedControl setTitle:NSLocalizedString(@"Detail", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Submission", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"Grade", nil) forSegmentAtIndex:2];
}

- (void)setSegmentImages
{
    [self.segmentedControl setBackgroundImage:[[UIImage techDebtImageNamed:@"img_details_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[[UIImage techDebtImageNamed:@"img_details_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[[UIImage techDebtImageNamed:@"img_details_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}

- (void)setDividerImages
{
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_right_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_both_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_left_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_both_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_right_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_left_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_divider_both_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_both_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[[UIImage techDebtImageNamed:@"divider_both_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
}

- (void)styleFont
{
    NSInteger dividerWidth = [[UIImage techDebtImageNamed:@"divider_right_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal].size.width;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor darkTextColor], NSForegroundColorAttributeName,
                                [UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName,
                                nil];
    
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor darkTextColor], NSForegroundColorAttributeName,
                                           [UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName,
                                           nil];
    
    [self.segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    [self.segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    [self.segmentedControl setContentPositionAdjustment:UIOffsetMake(dividerWidth / 4, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setContentPositionAdjustment:UIOffsetMake(-dividerWidth / 4, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
}

- (void)setupSegmentedControl
{
    [self setTitles];
    [self setSegmentImages];
    [self setDividerImages];
    [self styleFont];
}

- (void)setTab:(NSInteger)index
{
    self.previousSelectedTab = index;
    UIViewController *newController;
    if (index == DETAIL_TAB_INDEX) {
        newController = self.detailsController;
        self.detailsController.topContentInset = [self getContentInset];
        self.detailsController.bottomContentInset = self.tabBarController.tabBar.frame.size.height;
        [self.detailsController.view setAccessibilityElementsHidden:NO];
        [self.submissionController.tableView setAccessibilityElementsHidden:YES];
        [self.rubricController.rubricTableView setAccessibilityElementsHidden:YES];
    } else if (index == GRADE_TAB_INDEX) {
        newController = self.rubricController;
        [self.rubricController.rubricTableView setContentInset:UIEdgeInsetsMake([self getContentInset], 0, self.tabBarController.tabBar.frame.size.height, 0)];
        [self.rubricController.rubricTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self.rubricController.rubricTableView setAccessibilityElementsHidden:NO];
        [self.detailsController.view setAccessibilityElementsHidden:YES];
        [self.submissionController.tableView setAccessibilityElementsHidden:YES];
    } else if (index == SUBMISSION_TAB_INDEX) {
        newController = self.submissionController;
        UIScrollView *scrollView = (UIScrollView *)newController.view;
        UIEdgeInsets insets = UIEdgeInsetsMake([self getContentInset], 0, self.tabBarController.tabBar.frame.size.height, 0);
        scrollView.scrollIndicatorInsets = scrollView.contentInset = insets;
        [self.submissionController.tableView setAccessibilityElementsHidden:NO];
        [self.detailsController.view setAccessibilityElementsHidden:YES];
        [self.rubricController.rubricTableView setAccessibilityElementsHidden:YES];
    }
    
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [newController willMoveToParentViewController:self];
    newController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:newController.view];
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (IBAction)tabSelected:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    for (UIView *segment in [segmentedControl subviews]) {
        [segment.layer removeAllAnimations];

        for (UIView *view in [segment subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view.layer removeAllAnimations];
            }
        }
    }
    
    [self setTab:self.segmentedControl.selectedSegmentIndex];
}

- (void)displayContentLockIfNecessary {
    if (self.viewModel.model.lockInfo == nil || [self.viewModel.model.lockInfo.canView boolValue]) {
        return;
    }
    
    ContentLockViewController *contentLockVC = [[CBIContentLockViewController alloc] initWithViewModel:self.viewModel];
    
    [contentLockVC lockViewController:self];
}

- (void)schedule:(UIBarButtonItem *)barButtonItem {
    CKIAssignment *assignment = self.viewModel.model;
    NSString *assignmentID = assignment.id;
    
    BOOL alarmExists = NO;
    if ([self.localNotificationHandler localNotificationExists:assignmentID]) {
        [self.localNotificationHandler removeLocalNotification:assignmentID];
        alarmExists = NO;
    }
    else {
        [self showAssignmentNotificationSheet:barButtonItem];
        alarmExists = YES;
    }
    
    [self setAlarmButton:alarmExists];
}

- (void)setAlarmButton:(BOOL)alarmExists {
    UIImage *alarmImage = [UIImage techDebtImageNamed:@"icon_alarm"];
    if (alarmExists) {
        alarmImage = [UIImage techDebtImageNamed:@"icon_alarm_fill"];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:alarmImage style:UIBarButtonItemStylePlain target:self action:@selector(schedule:)];
}

- (void)showAssignmentNotificationSheet:(UIBarButtonItem *)alarmButton {
    NSString *fiveMinutes = NSLocalizedString(@"5 minutes", @"five minutes");
    NSString *oneHour = NSLocalizedString(@"1 hour", @"one hour");
    NSString *oneDay = NSLocalizedString(@"1 day", @"one day");
    NSString *threeDays = NSLocalizedString(@"3 days", @"three days");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Schedule Notification", @"Title for Assignment Notifications Sheet") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel button title")  destructiveButtonTitle:nil otherButtonTitles:fiveMinutes, oneHour, oneDay, threeDays, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:alarmButton animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CKIAssignment *assignment = self.viewModel.model;
    NSInteger offsetMinutes = 0;
    
    switch (buttonIndex) {
        case 0:
            // 5 mins
            offsetMinutes = 5;
            break;
        case 1:
            // 1 Hour
            offsetMinutes = CBIAssignmentDetailNumMinutesInHour;
            break;
        case 2:
            // 1 Day
            offsetMinutes = CBIAssignmentDetailNumMinutesInDay;
            break;
        case 3:
            // 3 Day
            offsetMinutes = CBIAssignmentDetailNumMinutesInDay * 3;
            break;
        case 4:
        default:
            // Do nothing, it was a cancel
            return;
            break;
    }
    
    [self scheduleLocalNotificationForAssignmentDue:assignment offsetInMinutes:offsetMinutes];
}

- (void)scheduleLocalNotificationForAssignmentDue:(CKIAssignment *)assignment offsetInMinutes:(NSUInteger)minutes {
    [self.localNotificationHandler scheduleLocalNotificationForAssignmentDue:assignment offsetInMinutes:minutes];
}

#pragma mark - 404 Error Handling
- (void) display404ErrorMessage {
    CGFloat textPadding = 20;
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSString *message = NSLocalizedString(@"Sorry, we couldn't find the assignment. This assignment may have been deleted.", @"404 Error for missing assignment");
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [message boundingRectWithSize:CGSizeMake(messageView.frame.size.width - textPadding, messageView.frame.size.height)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [messageLabel setPreferredMaxLayoutWidth:rect.size.width];
    messageLabel.font = font;
    messageLabel.text = message;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 0;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    
    [messageView addSubview:messageLabel];

    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(messageView.mas_centerX);
        make.centerY.equalTo(messageView.mas_centerY);
    }];
    
    [self.view addSubview:messageView];
    [messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

@end
