//
//  CSGPickVersionTableViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
