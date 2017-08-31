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
    
    

#import "CKTerm.h"
#import "ISO8601DateFormatter.h"
#import "CKSafeDictionary.h"

@implementation CKTerm

// {
// "end_at": "2012-06-15T00:00:00-06:00",
// "id": 4699,
// "name": "Spring 2012",
// "start_at": "2012-03-16T00:00:00-06:00"
//}

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        CKSafeDictionary *safeInfo = [CKSafeDictionary dictionaryWithDictionary:info];
        _ident = [safeInfo[@"id"] unsignedLongLongValue];
        _name = safeInfo[@"name"];
        
        if (safeInfo[@"start_at"]) {
            _startDate = [self.apiDateFormatter dateFromString:safeInfo[@"start_at"]];
        }
        if (safeInfo[@"end_at"]) {
            _endDate = [self.apiDateFormatter dateFromString:safeInfo[@"end_at"]];
        }
    }
    return self;
}

- (NSUInteger)hash {
    return (NSUInteger)self.ident;
}

@end
