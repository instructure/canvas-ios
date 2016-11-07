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

#import "CSGAssignmentGroupTableViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSGNoResultsView.h"
#import "CSGAssignmentTableViewCell.h"
#import "CSGGradingViewController.h"
#import "CSGAppDataSource.h"
#import "CSGFlyingPandaRefreshControl.h"
#import "CSGCourseSectionsTableViewController.h"
#import "UIColor+CSGColor.h"

static NSString *const CSGAssignmentGroupTableViewCellID = @"CSGAssignmentGroupTableViewCellID";
static NSString *const CSGAssignmentGroupEmptyTableViewCellID = @"CSGAssignmentGroupEmptyTableViewCellID";

static CGFloat const CSGGradingSectionMaxWidth = 3000.0f;
static CGFloat const CSGGradingSectionMinWidth = 100.0f;
static CGFloat const CSGGradingSectionHeight = 34.0f;

@interface CSGAssignmentGroupTableViewController ()

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) NSArray *assignmentGroups;
@property (nonatomic, strong) NSDictionary *assignmentsByGroupID;

@property (nonatomic, strong) CSGNoResultsView *noResultsView;
@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, strong) CSGFlyingPandaRefreshControl *customRefreshControl;
@property (nonatomic, strong) UIBarButtonItem *sectionSelectionBarButtonItem;
@property (nonatomic, strong) CSGCourseSectionsTableViewController *sectionsTableViewController;
@property (nonatomic, strong) UIPopoverController *sectionsPopoverController;
@property (nonatomic) BOOL hasLoaded;

@end

@implementation CSGAssignmentGroupTableViewController

+ (instancetype)instantiateFromStoryboard {
    CSGAssignmentGroupTableViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    
    [self setupView];    
    [self.customRefreshControl startLoading];
    
    
    @weakify(self)
    [RACObserve(self.dataSource, section) subscribeNext:^(CKISection *section) {
        @strongify(self)
        NSString *title = section ? section.name : @"All Sections";
        [self setupSectionBarButtonItemWithTitle:title];
        [self.sectionsPopoverController dismissPopoverAnimated:YES];

        [self.tableView reloadData];
    }];
}

- (void)setupSectionBarButtonItemWithTitle:(NSString *)title {
    if (!title || !self.hasLoaded) {
        return;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18.0f]};
    CGSize titleRect = [title sizeWithAttributes:attributes];
    CGFloat width = titleRect.width < CSGGradingSectionMaxWidth ? titleRect.width : CSGGradingSectionMaxWidth;
    width = width >= CSGGradingSectionMinWidth ? width : CSGGradingSectionMinWidth;
    CGFloat padding = 20;
    
    UIButton *sectionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width + padding, CSGGradingSectionHeight)];
    [sectionButton addTarget:self action:@selector(showSections) forControlEvents:UIControlEventTouchUpInside];
    [sectionButton setBackgroundColor:[UIColor csg_tappableButtonBackgroundColor]];
    [sectionButton.layer setMasksToBounds:YES];
    [sectionButton.layer setCornerRadius:10.0f];
    [sectionButton setTitle:title forState:UIControlStateNormal];
    sectionButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    
    self.sectionSelectionBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sectionButton];
    self.navigationItem.rightBarButtonItem = self.sectionSelectionBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.dataSource.course.name;
    self.tintColor = [CSGUserPrefsKeys colorForCourseID:self.dataSource.course.id];
    self.navigationController.navigationBar.barTintColor = self.tintColor;
    
    [self reloadDataFromDataSource];
}

- (void)showSectionsSelectionBarButton {
    self.sectionsTableViewController = [CSGCourseSectionsTableViewController instantiateFromStoryboard];

    self.sectionsPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.sectionsTableViewController];
    NSString *selectedSectionName = self.dataSource.section ? self.dataSource.section.name : @"All Sections";
    self.hasLoaded = YES;
    [self setupSectionBarButtonItemWithTitle:selectedSectionName];
}

- (void)showSections {
    DDLogInfo(@"SELECT SECTION PRESSED");
    [self.sectionsPopoverController presentPopoverFromBarButtonItem:self.sectionSelectionBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.assignmentGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKIAssignmentGroup *group = self.assignmentGroups[section];
    NSArray *assignmentsForGroup = self.assignmentsByGroupID[group.id];
    // Adding an empty cell if the count is 0
    return ([assignmentsForGroup count] > 0) ? [assignmentsForGroup count] : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor csg_offWhiteLowAlpha];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width - 40, view.frame.size.height)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.textColor = [UIColor darkGrayColor];
    textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [view addSubview:textLabel];
    
    CKIAssignmentGroup *group = self.assignmentGroups[section];
    textLabel.text = group.name;
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKIAssignmentGroup *group = self.assignmentGroups[indexPath.section];
    NSArray *assignmentsForGroup = self.assignmentsByGroupID[group.id];
    if (![assignmentsForGroup count]) {
        return [tableView dequeueReusableCellWithIdentifier:CSGAssignmentGroupEmptyTableViewCellID forIndexPath:indexPath];
    }
    
    CSGAssignmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CSGAssignmentGroupTableViewCellID forIndexPath:indexPath];
    [self configureAssignmentCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"INDEX SELECTED: %@", indexPath);
    CKIAssignment *assignment = [self assignmentAtIndexPath:indexPath];
    [self pushGradingViewForAssignment:assignment];
}

#pragma mark - Cell Configuration

- (void)configureAssignmentCell:(CSGAssignmentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CKIAssignment *assignment = [self assignmentAtIndexPath:indexPath];
    cell.tintColor = self.tintColor;
    [cell setAssignment:assignment];
    [cell setNeedsGradingCountForSection:self.dataSource.section.id];
}

- (CKIAssignment *)assignmentAtIndexPath:(NSIndexPath *)indexPath
{
    CKIAssignmentGroup *group = self.assignmentGroups[indexPath.section];
    NSArray *assignments = self.assignmentsByGroupID[group.id];
    return assignments[indexPath.row];
}

#pragma mark - SetupView

- (void)setupView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 60.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor csg_offWhite];
    
    // Setup Pull To Refresh
    self.customRefreshControl = [[CSGFlyingPandaRefreshControl alloc] initWithScrollView:self.tableView target:self action:@selector(reloadData:)];
    [self.tableView addSubview:self.customRefreshControl];

    [self setupNoResults];
}

- (void)setupNoResults
{
    self.noResultsView = [CSGNoResultsView instantiateFromXib];
    self.noResultsView.alpha = 0.0;
    self.noResultsView.imageView.image = [UIImage imageNamed:@"panda_superman"];
    self.noResultsView.tintColor = [UIColor lightGrayColor];
    self.tableView.backgroundView = self.noResultsView;
    
    self.noResultsView.commentLabel.text = NSLocalizedString(@"SuperPanda found no assignments for you to grade.", @"No Assignments Text");
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.customRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.customRefreshControl scrollViewDidEndDragging];
}

#pragma mark - UI Actions

- (void)showNoResults:(BOOL)results
{
    [UIView animateWithDuration:0.25 animations:^{
        self.noResultsView.alpha = !results;
    }];
}

#pragma mark - Data Fetching

- (void)reloadData:(UIRefreshControl *)refreshControl {
    DDLogInfo(@"REFRESH ASSIGNMENT GROUPS DATA");
    
    [self showNoResults:YES];
    [self.dataSource reloadAssignmentsWithGroupsWithSuccess:^{
        [self.customRefreshControl finishLoading];
        
        [self reloadDataFromDataSource];
        [self showSectionsSelectionBarButton];
        
        __block NSUInteger numAssignments = 0;
        [self.assignmentsByGroupID enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *assignments, BOOL *stop) {
            numAssignments += [assignments count];
        }];
        [self showNoResults:numAssignments];
    } failure:^(NSError *error) {
        // TODO: notify of error here
        [self.customRefreshControl finishLoading];
        
        [self showNoResults:NO];
        [self reloadDataFromDataSource];
    }];
}

- (void)reloadDataFromDataSource {
    self.assignmentGroups = self.dataSource.assignmentGroups;
    self.assignmentsByGroupID = self.dataSource.assignmentsByGroupID;
    [self.tableView reloadData];
}

#pragma mark - Transitions

- (void)pushGradingViewForAssignment:(CKIAssignment *)assignment {
    DDLogInfo(@"ASSIGNMENT SELECTED - %@ (%@)", assignment.name, assignment.id);
    [[CSGAppDataSource sharedInstance] setAssignment:assignment];
    CSGGradingViewController *gradingViewController = [CSGGradingViewController instantiateFromStoryboard];
    [self.navigationController pushViewController:gradingViewController animated:YES];
}

#pragma mark - Utility Methods

- (UIImage *)iconForAssignment:(CKIAssignment *)assignment
{
    NSArray *submissionTypes = assignment.submissionTypes;
    NSString *imageName = nil;
    
    if ([submissionTypes containsObject:@"discussion_topic"]) {
        imageName = @"icon_discussions";
    }
    else if ([submissionTypes containsObject:@"online_quiz"]) {
        imageName = @"icon_quizzes";
    }
    else {
        imageName = @"icon_assignments";
    }
    
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
