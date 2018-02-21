//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKMDomainSuggestionTableViewController.h"

@import Mantle;
#import "CKMLocationSchoolSuggester.h"
@import ReactiveObjC;
#import <CoreLocation/CoreLocation.h>
#import <CanvasKit/CanvasKit.h>
#import "CKMLocationManager.h"
#import "CLLocation+CKMDistance.h"

@interface CKMDomainSuggestionTableViewController ()

@property (nonatomic, strong) RACSubject *suggestionSelectionSubject;
@property (nonatomic, strong) RACSubject *selectedHelpSubject;
@property (nonatomic, strong) CKMLocationSchoolSuggester *schoolSuggester;
@property (nonatomic, strong) NSArray *suggestions;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) CKMLocationManager *locationManager;

@end

@implementation CKMDomainSuggestionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.f;
    
    self.numberFormatter = [NSNumberFormatter new];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.numberFormatter setMaximumFractionDigits:1];

    RAC(self, schoolSuggester.schoolSearchString) = RACObserve(self, query);
    RAC(self, suggestions) = self.schoolSuggester.suggestionsSignal;
    
    @weakify(self);
    [RACObserve(self, suggestions) subscribeNext:^(NSArray *suggestions) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

#pragma mark - Subject

- (RACSubject *)suggestionSelectionSubject
{
    if (!_suggestionSelectionSubject) {
        _suggestionSelectionSubject = [RACSubject subject];
    }
    return _suggestionSelectionSubject;
}

#pragma mark - Domain Suggester

- (CKMLocationSchoolSuggester *)schoolSuggester
{
    if (!_schoolSuggester) {
        _schoolSuggester = [CKMLocationSchoolSuggester shared];
    }
    return _schoolSuggester;
}

- (CKIAccountDomain *)suggestionForIndexPath:(NSIndexPath *)indexPath
{
    return self.suggestions[indexPath.row];
}

- (RACSignal *)selectedSchoolSignal
{
    return self.suggestionSelectionSubject;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLocation *currentLocation = [[CKMLocationManager sharedInstance] currentLocation];
    CKIAccountDomain *school = [self suggestionForIndexPath:indexPath];
    UITableViewCell *cell;
    if (school.domain != nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HelpCell" forIndexPath:indexPath];
    }
    
    cell.textLabel.text = school.name;
    if (school.domain == nil) {
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Tap here for help.", nil, [NSBundle bundleForClass:[self class]], @"Subtitle help text describing how to find a school.");
    }
    // if we have a current location, let's show it off
    else if (currentLocation && school.distance) {
        NSString *template = NSLocalizedStringFromTableInBundle(@"%@ miles away", nil, [NSBundle bundleForClass:[self class]], @"The distance in miles that a user is from a school.");
        cell.detailTextLabel.text = [NSString stringWithFormat:template, [self.numberFormatter stringFromNumber:school.distance]];

    } else {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKIAccountDomain *school = [self suggestionForIndexPath:indexPath];
    if (!school.domain) {
        [self.selectedHelpSubject sendNext:nil];
        return;
    }
    
    [self.suggestionSelectionSubject sendNext:school];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (RACSubject *)selectedHelpSubject
{
    if (!_selectedHelpSubject) {
        _selectedHelpSubject = [RACSubject subject];
    }
    return _selectedHelpSubject;
}

- (RACSignal *)selectedHelpSignal {
    return self.selectedHelpSubject;
}

@end
