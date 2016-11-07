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

#import "CSGPickFileTableViewController.h"
#import "CSGAppDataSource.h"

static NSString *const CSGPickFileTableViewControllerCellID = @"CSGPickVersionTableViewControllerCellID";

static CGFloat const CSGPickFileTableViewControllerHeightForRow = 44.0f;

static CGFloat const CSGPickFileTableViewControllerPreferredContentSizeWidth = 250.0f;
static CGFloat const CSGPickFileTableViewControllerPreferredContentSizeMaxHeight = 439.0f;

@interface CSGPickFileTableViewController ()

@property (nonatomic, strong) CSGAppDataSource *dataSource;
@property (nonatomic, strong) NSArray *sortedFiles;

@end

@implementation CSGPickFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CSGPickFileTableViewControllerCellID];
    
    self.sortedFiles = [self.dataSource.selectedSubmission.attachments sortedArrayUsingComparator:^NSComparisonResult(CKIFile *attachment1, CKIFile *attachment2) {
        return [attachment1.createdAt compare:attachment2.createdAt];
    }];
    [self.tableView reloadData];
    
    self.preferredContentSize = CGSizeMake(CSGPickFileTableViewControllerPreferredContentSizeWidth, [self preferredContentSizeHeight]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CSGPickFileTableViewControllerHeightForRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sortedFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CSGPickFileTableViewControllerCellID forIndexPath:indexPath];
    
    CKIFile *attachment = self.sortedFiles[indexPath.row];
    cell.textLabel.text = attachment.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKIFile *attachment = [self.sortedFiles objectAtIndex:indexPath.row];
    self.dataSource.selectedAttachment = attachment;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (CGFloat)preferredContentSizeHeight {
    if (![self.sortedFiles count]) {
        return 250.0f;
    }
    
    CGFloat estimatedContentHeight = [self.sortedFiles count] * CSGPickFileTableViewControllerHeightForRow - 1.0f;
    return estimatedContentHeight > CSGPickFileTableViewControllerPreferredContentSizeMaxHeight ? CSGPickFileTableViewControllerPreferredContentSizeMaxHeight : estimatedContentHeight;
}

@end
