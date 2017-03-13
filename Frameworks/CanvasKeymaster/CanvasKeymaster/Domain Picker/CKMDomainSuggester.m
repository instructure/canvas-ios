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

#import "CKMDomainSuggester.h"
@import ReactiveObjC;

static NSString * const CBISavedDomainsKey = @"com.instructure.domains";

@interface CKMDomainSuggester ()
@property (nonatomic, strong) NSMutableSet *savedDomains;
@end

@implementation CKMDomainSuggester

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *domains = [defaults objectForKey:CBISavedDomainsKey];
        self.savedDomains = [NSMutableSet setWithArray:domains];
    }
    return self;
}

- (void)saveDomain:(NSURL *)domain
{
    NSString *domainString = [domain host];
    [self.savedDomains addObject:domainString];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arrayToSave = [self.savedDomains allObjects];
    [defaults setObject:arrayToSave forKey:CBISavedDomainsKey];
}

- (RACSignal *)suggestionsSignal
{
    return [RACObserve(self, domainString) map:^id(NSString *domainString) {
        if (!domainString || domainString.length == 0) {
            return [self.savedDomains allObjects];
        }

        return [[self.savedDomains.rac_sequence filter:^BOOL(NSString *savedDomain) {
            return [savedDomain hasPrefix:domainString];
        }] array];
    }];
}

@end
