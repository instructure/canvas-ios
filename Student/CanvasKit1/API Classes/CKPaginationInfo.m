//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import "CKPaginationInfo.h"
#import "NSHTTPURLResponse+CKAdditions.h"

@implementation CKPaginationInfo

- (id)initWithResponse:(NSHTTPURLResponse *)httpResponse {
    self = [super init];
    if (self) {
        
        _currentPage = [httpResponse.URL copy];
        
        NSRange pathLocation = [httpResponse.URL.absoluteString rangeOfString:httpResponse.URL.path];
        NSURL *baseURL = nil;
        if (pathLocation.location != NSNotFound) {
            NSString *rootString = [httpResponse.URL.absoluteString substringToIndex:pathLocation.location];
            baseURL = [NSURL URLWithString:rootString];
        }
        
        NSDictionary *values = [httpResponse ck_linkHeaderValues];
        
        // In theory, all these URLs should be absolute URLs. In practice, the API sometimes
        // returns relative URLs. So we pass the baseURL in, just in case. If the original
        // is an absolute URL, it will be ignored.
        NSString *firstValue = values[@"first"];
        if (firstValue) {
            _firstPage = [[NSURL URLWithString:firstValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *prevValue = values[@"prev"];
        if (prevValue) {
            _previousPage = [[NSURL URLWithString:prevValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *nextValue = values[@"next"];
        if (nextValue) {
            _nextPage = [[NSURL URLWithString:nextValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *lastValue = values[@"last"];
        if (lastValue) {
            _lastPage = [[NSURL URLWithString:lastValue relativeToURL:baseURL] absoluteURL];
        }
    }
    return self;
}

@end
