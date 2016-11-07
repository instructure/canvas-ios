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

#import "CSGStudentPickerTableViewController.h"
#import "CSGStudentPickerCell.h"
#import "CSGAppDataSource.h"

#import "UIImage+Color.h"

#import <CanvasKit/CanvasKit.h>

static NSString *const STUDENT_PICKER_CELL_ID = @"CSGStudentPickerCell";
static NSString *const STUDENT_PICKER_NIB_NAME = @"CSGStudentPickerCell";

@interface CSGStudentPickerTableViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchControllerTableViewController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSArray *sortedUsersByName;
@property (nonatomic, strong) NSDictionary *sortedUsersByGrade;
@property (nonatomic, strong) RACSubject *submissionRecordPickedSubject;
@property (nonatomic, strong) CSGAppDataSource *dataSource;

@end

@implementation CSGStudentPickerTableViewController

+ (instancetype)instantiateFromStoryboard
{
    CSGStudentPickerTableViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 54.0f;
    self.tableView.rowHeight = 54.0f;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor darkGrayColor];
    self.refreshControl = refreshControl;
    
    [self setupSearchBar];
    
    @weakify(self);
    [RACObserve(self, dataSource.sortedStudentsByName) subscribeNext:^(NSArray *users) {
        @strongify(self);
        self.sortedUsersByName = users;
        [self.tableView reloadData];
    }];
    [RACObserve(self, dataSource.sortedStudentsByGrade) subscribeNext:^(NSDictionary *users) {
        @strongify(self);
        self.sortedUsersByGrade = users;
        [self.tableView reloadData];
    }];
    
    // because we're using a UISearchController and we want to use the same cell we're using Nibs for this class
    [self.tableView registerNib:[UINib nibWithNibName:STUDENT_PICKER_NIB_NAME bundle:[NSBundle mainBundle]] forCellReuseIdentifier:STUDENT_PICKER_CELL_ID];
    
}

- (void)setupSearchBar {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
        self.tableView.tableHeaderView = nil;
        return;
    }
    
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.dataSource.sortedStudentsByName count]];
    
    self.searchControllerTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchControllerTableViewController.tableView.dataSource = self;
    self.searchControllerTableViewController.tableView.delegate = self;
    [self.searchControllerTableViewController.tableView registerNib:[UINib nibWithNibName:STUDENT_PICKER_NIB_NAME bundle:[NSBundle mainBundle]] forCellReuseIdentifier:STUDENT_PICKER_CELL_ID];
    self.searchControllerTableViewController.tableView.tableFooterView = [UIView new];
    
    // Create and style the searchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchControllerTableViewController];
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    [self.searchController.searchBar setBarTintColor:[UIColor csg_studentPickerBackgroundColor]];
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.tintColor = [UIColor csg_studentPickerBackgroundColor];
    self.searchController.searchResultsUpdater = self;

    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return 1;
    } else {
        if (self.dataSource.studentSortOrder == CSGStudentSortOrderGrade || self.dataSource.studentSortOrder == CSGStudentSortOrderGradeRandom) {
            return 3; // Needs Grading, Graded, Unsubmitted
        } else {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*  If the requesting table view is the search controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.searchResults count];
    } else {
        if (self.dataSource.studentSortOrder == CSGStudentSortOrderGrade || self.dataSource.studentSortOrder == CSGStudentSortOrderGradeRandom) {
            switch (section) {
                case 0:
                    return [self.sortedUsersByGrade[CSGStudentSubmissionSectionNeedsGrading] count];
                    
                case 1:
                    return [self.sortedUsersByGrade[CSGStudentSubmissionSectionGraded] count];
                    
                case 2:
                    return [self.sortedUsersByGrade[CSGStudentSubmissionSectionNoSubmission] count];
                    
                default: // should never get here
                    return [self.sortedUsersByName count];
            }
        } else {
            return [self.sortedUsersByName count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSGStudentPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:STUDENT_PICKER_CELL_ID forIndexPath:indexPath];
    CKIUser *user = [self tableView:tableView userForIndexPath:indexPath];
    [self configureCell:cell withUser:user];
    return cell;
}

- (void)configureCell:(CSGStudentPickerCell *)cell withUser:(CKIUser *)user {
    CKISubmissionRecord *submissionRecordForUser = [self.dataSource submissionForUser:user];
    
    // Unless the assignments are anonymous, we will show the student name
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
        cell.studentNameLabel.text = [NSString stringWithFormat:@"Student %lu",(unsigned long)[self.dataSource userIndexForSubmission:submissionRecordForUser]];
        cell.studentNameLabelWhenLate.text = [NSString stringWithFormat:@"Student %lu",(unsigned long)[self.dataSource userIndexForSubmission:submissionRecordForUser]];
    } else {
        cell.studentNameLabel.text = user.sortableName;
        cell.studentNameLabelWhenLate.text = user.sortableName;
    }
    
    // if the user has no submission, the text is not bold
    if (!submissionRecordForUser || [submissionRecordForUser isDummySubmission]) {
        cell.studentNameLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.studentNameLabelWhenLate.font = [UIFont systemFontOfSize:15.0f];
        cell.scoreLabel.font = [UIFont systemFontOfSize:13.0f];
    } else {
        cell.studentNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        cell.studentNameLabelWhenLate.font = [UIFont boldSystemFontOfSize:15.0f];
        cell.scoreLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    
    // if we have graded it we put the check
    CKISubmission *lastSubmission = (CKISubmission *)submissionRecordForUser.submissionHistory.lastObject;
    if (lastSubmission.gradeMatchesCurrentSubmission && lastSubmission.score != nil) {
        cell.checkmarkImageView.hidden = NO;
    } else {
        cell.checkmarkImageView.hidden = YES;
    }
    
    cell.scoreLabel.text = [[self scoreTextForSubmissionRecord:submissionRecordForUser assignment:self.dataSource.assignment] uppercaseString];
    
    if (submissionRecordForUser) {
        cell.lateLabel.hidden = !submissionRecordForUser.late;
        cell.studentNameLabelWhenLate.hidden = !submissionRecordForUser.late;
        cell.studentNameLabel.hidden = submissionRecordForUser.late;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMM d, yyyy hh:mma"];
        NSString *late = NSLocalizedString(@"Late", @"Late submission subtitle text");
        NSString *dateString = [dateFormatter stringFromDate:submissionRecordForUser.submittedAt];
        cell.lateLabel.text = [NSString stringWithFormat: @"%@ (%@)", late, dateString];
    } else {
        cell.lateLabel.hidden = YES;
        cell.studentNameLabelWhenLate.hidden = YES;
        cell.studentNameLabel.hidden = NO;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.dataSource.studentSortOrder == CSGStudentSortOrderAlphabetical) {
        return nil;
    }
    
    if (section == 0) {
        if ([self.sortedUsersByGrade[CSGStudentSubmissionSectionNeedsGrading] count]) {
            return NSLocalizedString(@"Needs Grading", @"Section header for submissions that need grading");
        }
    } else if (section == 1) {
        if ([self.sortedUsersByGrade[CSGStudentSubmissionSectionGraded] count]) {
            return NSLocalizedString(@"Graded", @"Section header for graded submissions");
        }
    } else if (section == 2) {
        if ([self.sortedUsersByGrade[CSGStudentSubmissionSectionNoSubmission] count]) {
            return NSLocalizedString(@"No Submission", @"Section header for unsubmitted submissions");
        }
    }
    
    return nil;
}

- (NSString *)scoreTextForSubmissionRecord:(CKISubmissionRecord *)submissionRecord assignment:(CKIAssignment *)assignment {
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSInteger scoringType = assignment.scoringType;
    
    NSString *userScore = submissionRecord.score ? [formatter stringFromNumber:submissionRecord.score] : @"-";
    NSString *pointsPossible = assignment.pointsPossible ? [NSString stringWithFormat:@"%.0f", assignment.pointsPossible] : @"-";
    NSString *userGrade = submissionRecord.grade;
    if (!submissionRecord.grade) {
        return [NSString stringWithFormat:@"- / %@", pointsPossible];
    }
    
    NSString *returnString = nil;
    
    switch (scoringType) {
        case CKIAssignmentScoringTypePoints:
            returnString = [NSString stringWithFormat:@"%@ / %@", userGrade, pointsPossible];
            break;
        case CKIAssignmentScoringTypePercentage:
        case CKIAssignmentScoringTypeLetter:
            returnString = [NSString stringWithFormat:@"%@ (%@ / %@)", userGrade, userScore, pointsPossible];
            break;
        case CKIAssignmentScoringTypeGPAScale:
        case CKIAssignmentScoringTypePassFail:
            returnString = [NSString stringWithFormat:@"%@", userGrade];
            break;
        case CKIAssignmentScoringTypeNotGraded:
            returnString = @"";
        default:
            break;
    }

    return returnString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"INDEX SELECTED: %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKIUser *user = [self tableView:tableView userForIndexPath:indexPath];
    CKISubmissionRecord *submissionRecordForStudent = [self.dataSource submissionForUser:user];
    DDLogInfo(@"USER SELECTED: %@ (%@)", user.sortableName, user.id);
    DDLogInfo(@"SUBMISSION SELECTED: %@ (%ld)", submissionRecordForStudent.id, (long)submissionRecordForStudent.attempt);
    [self.submissionRecordPickedSubject sendNext:submissionRecordForStudent];
}

- (void)refreshData:(UIRefreshControl *)refreshControl
{
    DDLogInfo(@"REFRESH STUDENT DATA");
    [self.refreshControl beginRefreshing];
    [self.dataSource reloadSubmissionsWithStudentsWithSuccess:^{
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        // TODO: Notify people that there is an error
        [self.refreshControl endRefreshing];
    }];
    
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    DDLogInfo(@"SEARCH FOR STUDENT - SEARCHSTRING: %@", searchString);
    
    [self updateFilteredContentForSearchString:searchString];
    
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

#pragma mark - Content Filtering

- (void)updateFilteredContentForSearchString:(NSString *)searchString {
    if (!searchString.length) {
        self.searchResults = [NSMutableArray arrayWithArray:self.sortedUsersByName];
        return;
    }
    
    [self.searchResults removeAllObjects];
    
    for (CKIUser *user in self.sortedUsersByName) {
        NSRange nameRange = [user.sortableName rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound) {
            [self.searchResults addObject:user];
        }
    }
}

- (CKIUser *)tableView:(UITableView *)tableView userForIndexPath:(NSIndexPath *)indexPath {
    CKIUser *user = nil;
    if (tableView == self.searchControllerTableViewController.tableView) {
        user = self.searchResults[indexPath.row];
    } else {
        if (self.dataSource.studentSortOrder == CSGStudentSortOrderGrade || self.dataSource.studentSortOrder == CSGStudentSortOrderGradeRandom) {
            switch (indexPath.section) {
                case 0:
                    user = self.sortedUsersByGrade[CSGStudentSubmissionSectionNeedsGrading][indexPath.row];
                    break;
                    
                case 1:
                    user = self.sortedUsersByGrade[CSGStudentSubmissionSectionGraded][indexPath.row];
                    break;
                    
                case 2:
                    user = self.sortedUsersByGrade[CSGStudentSubmissionSectionNoSubmission][indexPath.row];
                    break;
                    
                default:
                    break;
            }
        } else {
            user = self.sortedUsersByName[indexPath.row];
        }
    }
    return user;
}

- (RACSubject *)submissionRecordPickedSubject {
    if (!_submissionRecordPickedSubject) {
        _submissionRecordPickedSubject = [RACSubject subject];
    }
    return _submissionRecordPickedSubject;
}

- (RACSignal *)submissionRecordPickedSignal {
    return self.submissionRecordPickedSubject;
}

@end
