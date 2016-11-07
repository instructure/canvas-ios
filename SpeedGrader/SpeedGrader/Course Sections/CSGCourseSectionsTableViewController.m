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

#import "CSGCourseSectionsTableViewController.h"

#import "CSGSectionTableViewCell.h"
#import <CanvasKit/CKIClient+CKISection.h>
#import "CSGAppDataSource.h"

#import "UITableViewController+CSGFetchedResultsController.h"

static NSString *const CSGSectionTableViewCellID = @"CSGSectionTableViewCellID";

static CGFloat const PREFFERED_CONTENT_WIDTH = 300.0f;
static CGFloat const MINIMUM_PREFFERED_CONTENT_HEIGHT = 60.0f;
static CGFloat const MAXIMUM_PREFFERED_CONTENT_HEIGHT = 439.0f;

@interface CSGCourseSectionsTableViewController ()

@property (nonatomic, strong) CSGAppDataSource *dataSource;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation CSGCourseSectionsTableViewController

+ (instancetype)instantiateFromStoryboard
{
    CSGCourseSectionsTableViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[CSGCourseSectionsTableViewController class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.sections = self.dataSource.sections;
    
    self.preferredContentSize = CGSizeMake([self preferredWidth], [self preferredHeight]);
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor darkGrayColor];
    self.refreshControl = refreshControl;
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor csg_sectionPickerBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refresh:(UIRefreshControl *)control {
    DDLogInfo(@"REFRESH SECTION DATA");
    [self fetchSections];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSGSectionTableViewCell *cell = (CSGSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CSGSectionTableViewCellID forIndexPath:indexPath];
    CKISection *section = [self sectionAtIndex:indexPath.row];
    
    cell.sectionNameLabel.text = section.name ? section.name : @"All Sections";
    cell.checkmarkImageView.hidden = section != self.dataSource.section;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"INDEX SELECTED: %@", indexPath);
    CKISection *section = [self sectionAtIndex:indexPath.row];
    DDLogInfo(@"SECTION SELECTED - %@ (%@)", section.name, section.id);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.dataSource.section = section;
}



- (CGFloat)preferredHeight
{
    // Add one for the All Sections Cell
    CGFloat preferredHeight = (self.sections.count + 1) * 44;
    preferredHeight = preferredHeight < MINIMUM_PREFFERED_CONTENT_HEIGHT ? MINIMUM_PREFFERED_CONTENT_HEIGHT : preferredHeight;
    preferredHeight = preferredHeight > MAXIMUM_PREFFERED_CONTENT_HEIGHT ? MAXIMUM_PREFFERED_CONTENT_HEIGHT : preferredHeight;
    return  preferredHeight;
}

- (CGFloat)preferredWidth
{
    return PREFFERED_CONTENT_WIDTH;
}

- (CKISection *)sectionAtIndex:(NSUInteger)index
{
    if (index == 0) {
        return nil;
    }
    return self.sections[index - 1];
}

#pragma mark - Networking
- (void)fetchSections
{
    [self.refreshControl beginRefreshing];
    
    NSMutableArray *sections = [NSMutableArray new];
    
    [[[TheKeymaster currentClient] fetchSectionsForCourse:self.dataSource.course] subscribeNext:^(NSArray *newSections) {
        [sections addObjectsFromArray:newSections];
    } error:^(NSError *error) {
        // TODO: Notify of error
    } completed:^{
        [sections sortedArrayUsingComparator:^NSComparisonResult(CKISection *section1, CKISection *section2) {
            return [section1.name caseInsensitiveCompare:section2.name];
        }];
        self.sections = [NSArray arrayWithArray:sections];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

@end
