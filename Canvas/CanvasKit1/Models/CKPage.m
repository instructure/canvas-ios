
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
