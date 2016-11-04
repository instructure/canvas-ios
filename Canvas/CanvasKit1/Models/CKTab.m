
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CKTab.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKTab

@synthesize htmlURL;
@synthesize identStr;
@synthesize label;
@synthesize tabType;

#pragma mark - Initialization

- (id)initWithInfo:(NSDictionary *)info {
    if (!info[@"id"]) {
        self = nil;
        return nil;
    }
    self = [super init];
    if (self) {
        identStr = [info objectForKeyCheckingNull:@"id"];
        htmlURL = [NSURL URLWithString:[info objectForKeyCheckingNull:@"html_url"]];
        label = [info objectForKeyCheckingNull:@"label"];
        tabType = [self tabTypeFromString:[info objectForKeyCheckingNull:@"type"]];

        if (info[@"url"] && ![info[@"url"] isKindOfClass:[NSNull class]]) {
            _externalToolCreateSessionURL = [NSURL URLWithString:info[@"url"]];
        }
    }
    return self;
}

#pragma mark - Helpers

#pragma mark Public

- (BOOL)hasSameIdentityAs:(NSObject *)object {
    if (![object isKindOfClass:[CKTab class]]) return NO;
    return [((CKTab *)object).identStr isEqualToString:self.identStr];
}

- (NSUInteger)hash {
    // Idents are most likely unique, so let's just stick with them for now.
    return [self.identStr hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (identStr:%@, htmlURL:%@, label:%@, tabType:%@)",
            [super description],
            identStr,
            htmlURL,
            label,
            [self stringFromTabType:tabType]];
}

#pragma mark Private

- (CKTabType)tabTypeFromString:(NSString *)str {
    if ([str isEqualToString:@"internal"]) return CKTabTypeInternal;
    if ([str isEqualToString:@"external"]) return CKTabTypeExternal;
    return CKTabTypeUnknown;
}

- (NSString *)stringFromTabType:(CKTabType)type {
    switch (type) {
        case CKTabTypeExternal:
            return @"external";
            break;
        case CKTabTypeInternal:
            return @"internal";
            break;
        case CKTabTypeUnknown:
            return @"unknown";
            break;
        default:
            break;
    }
}

@end
