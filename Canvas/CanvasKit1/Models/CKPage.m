//
//  CKPage.m
//  CanvasKit
//
//  Created by BJ Homer on 10/31/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKPage.h"
#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter.h"
#import "CKCommonTypes.h"
#import "CKContentLock.h"

@implementation CKPage

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _identifier = [info objectForKeyCheckingNull:@"url"];
        _hiddenFromStudents = [[info objectForKeyCheckingNull:@"hide_from_students"] boolValue];
        _title = [info objectForKeyCheckingNull:@"title"];
        _body = [info objectForKeyCheckingNull:@"body"];
        
        ISO8601DateFormatter *dateFormatter = [ISO8601DateFormatter new];
        NSString *creationDateStr = [info objectForKeyCheckingNull:@"created_at"];
        if (creationDateStr) {
            _creationDate = [dateFormatter dateFromString:creationDateStr];
        }
        
        NSString *updatedDateStr = [info objectForKeyCheckingNull:@"updated_at"];
        if (updatedDateStr) {
            _updatedDate = [dateFormatter dateFromString:updatedDateStr];
        }
        
        _contentLock = [[CKContentLock alloc] initWithInfo:info];
        _isFrontPage = [[info objectForKeyCheckingNull:@"front_page"] boolValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: (title = %@)", [super description], _identifier];
}


- (NSUInteger)hash {
    return [_identifier hash];
}

- (BOOL)hasSameIdentityAs:(id)object {
    if ([object isKindOfClass:[CKPage class]]) {
        CKPage *other = object;
        return [self.identifier isEqualToString:other.identifier];
    }
    else {
        return [super hasSameIdentityAs:object];
    }
}

@end
