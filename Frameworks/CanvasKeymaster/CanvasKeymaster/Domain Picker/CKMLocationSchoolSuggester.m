//
//  CKMLocationSchoolSuggester.m
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMLocationSchoolSuggester.h"

@import ReactiveObjC;

#import "CKMLocationManager.h"
#import "CLLocation+CKMDistance.h"
@import Mantle;
@import CanvasKit;
@import CocoaLumberjack;

static double const CKMDistanceThreshold = 50.0;

int ddLogLevel =
#ifdef DEBUG
    DDLogLevelVerbose;
#else
    DDLogLevelError;
#endif

@interface CKMLocationSchoolSuggester ()
@property (nonatomic, strong) NSMutableArray *availableSchools;
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
        [self loadSchools];
    }
    return self;
}

- (void)loadSchools {
    self.availableSchools = [NSMutableArray new];

    // fetch the schools and when we're done, check to see if cache is expired.  Then download the new file for next time
    @weakify(self);
    [[CKIClient fetchAccountDomains] subscribeNext:^(NSArray *accountDomains) {
        @strongify(self);
        [self.availableSchools addObjectsFromArray:accountDomains];
    } error:^(NSError *error) {
        DDLogError(@"ERROR DOWNLOADING ACCOUNT DOMAINS: %@", error.localizedDescription);
    } completed:^{
        // Nothing to do here.  Searching will happen as soon as results start returning
    }];
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
    [array insertObject:[CKIAccountDomain canvasNetSchool] atIndex:0];
    
#if DEBUG
    NSArray *developmentDomains = [CKIAccountDomain developmentSchools];
    [array insertObjects:developmentDomains atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, developmentDomains.count)]];
#endif
}

@end
