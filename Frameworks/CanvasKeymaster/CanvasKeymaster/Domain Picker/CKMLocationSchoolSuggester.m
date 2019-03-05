//
// Copyright (C) 2017-present Instructure, Inc.
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

static CKMLocationSchoolSuggester* _sharedInstance = nil;

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

        @weakify(self);
        [RACObserve(self, schoolSearchString) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            self.fetching = YES;
        }];
        [self.suggestionsSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            self.fetching = NO;
        }];
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
    
- (RACSignal *)suggestionsSignal
{
    return [[RACObserve(self, schoolSearchString) map:^id(NSString *query) {
        if (!query || query.length == 0) {
            return [RACSignal return:@[]];
        }
        return [[CKIClient fetchAccountDomains:query] map:^id(NSArray *accountDomains) {
            NSMutableArray *schools = [NSMutableArray arrayWithArray:accountDomains];
            [schools addObject:[CKIAccountDomain cantFindSchool]];
            return schools;
        }];
    }] switchToLatest];
}

- (void)addStandardDomainsToArray:(NSMutableArray *)array {
    [array insertObject:[CKIAccountDomain howDoIFindMySchool] atIndex:0];
}

@end
