//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
