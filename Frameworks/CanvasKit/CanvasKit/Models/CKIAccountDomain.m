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

#import "CKIAccountDomain.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIAccountDomain

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
            @"name": @"name",
            @"domain": @"domain",
            @"distance": @"distance",
            @"authenticationProvider": @"authentication_provider",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)distanceJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

- (instancetype)initWithDomain:(NSString *)domain
{
    if ((self = [self init])) {
        self.domain = domain;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    self.type = CKIAccountDomainTypeNormal;
    return self;
}

- (NSString *)path
{
    return CKIRootContext.path;
}

+ (CKIAccountDomain *)canvasNetSchool {
    CKIAccountDomain *canvasNetSchool = [CKIAccountDomain new];
    canvasNetSchool.name = @"Canvas Network";
    canvasNetSchool.domain = @"learn.canvas.net";
    canvasNetSchool.distance = @(0);
    return canvasNetSchool;
}

+ (CKIAccountDomain *)cantFindSchool {
    CKIAccountDomain *domain = [CKIAccountDomain new];
    domain.type = CKIAccountDomainTypeCantFindSchool;
    return domain;
}

+ (CKIAccountDomain *)howDoIFindMySchool {
    CKIAccountDomain *domain = [CKIAccountDomain new];
    domain.type = CKIAccountDomainTypeHowDoIFindMySchool;
    return domain;
}

+ (NSArray *)developmentSchools {
    NSArray *devDomains = @[@"twilson", @"mobiledev", @"mobileqa", @"mobileqat"];
    
    __block NSMutableArray *devSchools = [NSMutableArray array];
    [devDomains enumerateObjectsUsingBlock:^(NSString *domain, NSUInteger idx, BOOL *stop) {
        CKIAccountDomain *canvasNetSchool = [CKIAccountDomain new];
        canvasNetSchool.name = domain;
        canvasNetSchool.domain = domain;
        canvasNetSchool.distance = @(0);
        [devSchools addObject:canvasNetSchool];
    }];
    
    return devSchools;
}

- (BOOL)isEqual:(id)object {
    CKIAccountDomain *other = (CKIAccountDomain *)object;
    if (![other isKindOfClass:[CKIAccountDomain class]]) {
        return NO;
    }
    return [other.id isEqualToString:self.id];
}
    
- (NSUInteger)hash {
    return self.id.hash;
}
    
@end
