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

#import "CSGPickVersionTableViewController.h"

#import "CSGAppDataSource.h"

static NSString *const CSGPickVersionTableViewControllerCellID = @"CSGPickVersionTableViewControllerCellID";

static CGFloat const CSGPickVersionTableViewControllerHeightForRow = 44.0f;

static CGFloat const CSGPickVersionTableViewControllerPreferredContentSizeWidth = 250.0f;
static CGFloat const CSGPickVersionTableViewControllerPreferredContentSizeMaxHeight = 439.0f;

@interface CSGPickVersionTableViewController ()

@property (nonatomic, strong) CSGAppDataSource *dataSource;
@property (nonatomic, strong) NSArray *sortedSubmissions;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CSGPickVersionTableViewController

+ (instancetype)instantiateFromStoryboard
{
    CSGPickVersionTableViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMM d, yyyy hh:mma"];
    
    self.sortedSubmissions = [self.dataSource.selectedSubmissionRecord.submissionHistory sortedArrayUsingComparator:^NSComparisonResult(CKISubmission *submission1, CKISubmission *submission2) {
        return [submission1.submittedAt compare:submission2.submittedAt];
    }];
    [self.tableView reloadData];
    
    self.preferredContentSize = CGSizeMake(CSGPickVersionTableViewControllerPreferredContentSizeWidth, [self preferredContentSizeHeight]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CSGPickVersionTableViewControllerHeightForRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sortedSubmissions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CSGPickVersionTableViewControllerCellID forIndexPath:indexPath];
    
    CKISubmission *submission = self.sortedSubmissions[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Attempt %lu", (unsigned long)submission.attempt];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:submission.submittedAt];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKISubmission *submission = self.sortedSubmissions[indexPath.row];
    self.dataSource.selectedSubmission = submission;
}

- (CGFloat)preferredContentSizeHeight {
    if (![self.sortedSubmissions count]) {
        return 250.0f;
    }
    
    CGFloat estimatedContentHeight = [self.sortedSubmissions count] * CSGPickVersionTableViewControllerHeightForRow - 1.0f;  //subtract one point for the separator so it doesn't show
    return estimatedContentHeight > CSGPickVersionTableViewControllerPreferredContentSizeMaxHeight ? CSGPickVersionTableViewControllerPreferredContentSizeMaxHeight : estimatedContentHeight;
}

@end
