//
//  CBIDomainSuggestionTableViewController.m
//  iCanvas
//
//  Created by Jason Larsen on 2/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMDomainSuggestionTableViewController.h"

@import Mantle;
#import "CKMLocationSchoolSuggester.h"
#import "CKMDomainSuggestionTableViewCell.h"
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
        _schoolSuggester = [CKMLocationSchoolSuggester new];
    }
    return _schoolSuggester;
}

- (CKIAccountDomain *)suggestionForIndexPath:(NSIndexPath *)indexPath
{
    return self.suggestions[indexPath.row];
}

- (RACSignal *)selectedTextSignal
{
    return self.suggestionSelectionSubject;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CKMDomainSuggestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CKIAccountDomain *school = [self suggestionForIndexPath:indexPath];
    cell.textLabel.text = school.name;
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    CLLocation *currentLocation = [[CKMLocationManager sharedInstance] currentLocation];
    
    if ([school.name isEqualToString:@"Canvas Network"]) {
        cell.detailTextLabel.text = NSLocalizedString(@"Right Behind You", nil);

    }
    // No domain means the user clicked on the help cell
    else if (!school.domain) {
        cell.detailTextLabel.text = NSLocalizedString(@"Enter your school's domain or tap for help.", @"Subtitle help text describing how to find a school.");

    }
    // if we have a current location, let's show it off
    else if (currentLocation && school.distance) {
        NSString *template = NSLocalizedString(@"%@ miles away", @"The distance in miles that a user is from a school.");
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
    
    [self.suggestionSelectionSubject sendNext:school.domain];
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
