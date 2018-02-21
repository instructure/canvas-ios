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

#import "CKMLocationSchoolSuggester.h"

@import ReactiveObjC;

#import "CKMLocationManager.h"
#import "CLLocation+CKMDistance.h"
@import Mantle;
@import CanvasKit;
@import CocoaLumberjack;

static double const CKMDistanceThreshold = 50.0;
static CKMLocationSchoolSuggester* _sharedInstance = nil;

int ddLogLevel =
#ifdef DEBUG
    DDLogLevelVerbose;
#else
    DDLogLevelError;
#endif

@interface CKMLocationSchoolSuggester ()
@property (nonatomic, strong) NSMutableSet *availableSchools;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation CKMLocationSchoolSuggester

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, currentLocation) = [[[CKMLocationManager sharedInstance] locationSignal] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        self.availableSchools = [NSMutableSet new];
        [self loadSchools];
    }
    return self;
}
    
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [CKMLocationSchoolSuggester new];
    });
    
    return _sharedInstance;
}
    
- (void)loadSchools {
    self.fetching = YES;

    // fetch the schools and when we're done, check to see if cache is expired.  Then download the new file for next time
    @weakify(self);
    [[CKIClient fetchAccountDomains] subscribeNext:^(NSArray *accountDomains) {
        @strongify(self);
        [self.availableSchools addObjectsFromArray:accountDomains];
        self.schoolSearchString = [self.schoolSearchString copy];
    } error:^(NSError *error) {
        DDLogError(@"ERROR DOWNLOADING ACCOUNT DOMAINS: %@", error.localizedDescription);
        self.fetching = NO;
    } completed:^{
        self.fetching = NO;
        // Nothing to do here.  Searching will happen as soon as results start returning
    }];
}

- (void)fetchSchools {
    if (!self.fetching) {
        [self loadSchools];
    }
}
    
- (RACSignal *)suggestionsSignal
{
    return [RACSignal combineLatest:@[RACObserve(self, schoolSearchString), RACObserve(self, currentLocation) ] reduce:^id(NSString *schoolSearchString, CLLocation *currentLocation) {
        if (!schoolSearchString || schoolSearchString.length == 0) {
            // if location is not available sort by name
            if (!currentLocation) {
                // if location is not available sort based on name
                return [self availableSchoolsSortedByName];
            } else {
                // if location is available sort based on location
                return  [self availableSchoolsSortedByCurrentLocation:currentLocation];
            }
        }
        
        NSMutableArray *availableSchools = [NSMutableArray arrayWithArray:[[self.availableSchools.rac_sequence filter:^BOOL(CKIAccountDomain *school) {
            NSRange nameRange = [school.name rangeOfString:schoolSearchString options:NSCaseInsensitiveSearch];
            NSRange domainRange = [school.domain rangeOfString:schoolSearchString options:NSCaseInsensitiveSearch];
            return (nameRange.location != NSNotFound) || (domainRange.location != NSNotFound);
        }] array]];
        
        [availableSchools addObject:[CKIAccountDomain cantFindSchool]];
        
        // if we have a search string, search based on the search string
        return availableSchools;
    }];
}

- (NSArray *)availableSchoolsSortedByName {
    NSMutableArray *availableSchools = [NSMutableArray arrayWithArray:[[self.availableSchools.rac_sequence filter:^BOOL(CKIAccountDomain *school) {
        return school.distance && [school.distance floatValue] < CKMDistanceThreshold;
    }] array]];
    [availableSchools sortUsingComparator:^NSComparisonResult(CKIAccountDomain *school1, CKIAccountDomain *school2) {
        return [school1.name compare:school2.name];
    }];
    
    [self addStandardDomainsToArray:availableSchools];
    
    return availableSchools;
}

- (NSArray *)availableSchoolsSortedByCurrentLocation:(CLLocation *)currentLocation {
    NSMutableArray *availableSchools = [NSMutableArray arrayWithArray:[[self.availableSchools.rac_sequence filter:^BOOL(CKIAccountDomain *school) {
        return school.distance && [school.distance floatValue] < CKMDistanceThreshold;
    }] array]];
    [availableSchools sortUsingComparator:^NSComparisonResult(CKIAccountDomain *school1, CKIAccountDomain *school2) {
        return [school1.distance compare:school2.distance];
    }];
    
    [self addStandardDomainsToArray:availableSchools];
    
    return availableSchools;
}

- (void)addStandardDomainsToArray:(NSMutableArray *)array {
#if DEBUG
    NSArray *developmentDomains = [CKIAccountDomain developmentSchools];
    [array insertObjects:developmentDomains atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, developmentDomains.count)]];
#endif
}

@end
