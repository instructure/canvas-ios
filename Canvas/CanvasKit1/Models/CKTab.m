//
//  CKTab.m
//  CanvasKit
//
//  Created by David M. Brown on 11/12/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
