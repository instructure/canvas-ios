//
//  CSGPickFileTableViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
