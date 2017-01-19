//
// Created by Jason Larsen on 2/25/14.
// Copyright (c) 2014 Instructure. All rights reserved.
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
