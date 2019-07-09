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

#import "NSURL+TechDebt.h"

@implementation NSURL (TechDebt)

- (NSURL *)urlByRemovingFragment {
    NSString *urlString = [self absoluteString];
    // Find that last component in the string from the end to make sure to get the last one
    NSRange fragmentRange = [urlString rangeOfString:@"#" options:NSBackwardsSearch].location != NSNotFound ? [urlString rangeOfString:@"#" options:NSBackwardsSearch] : [urlString rangeOfString:@"%23" options:NSBackwardsSearch];
    if (fragmentRange.location != NSNotFound) {
        // Chop the fragment.
        NSString* newURLString = [urlString substringToIndex:fragmentRange.location];
        return [NSURL URLWithString:newURLString];
    } else {
        return self;
    }
}

- (NSURL *)urlByAddingQueryParamWithName:(NSString *)name value:(NSString *)value {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    if (components.queryItems) {
        NSMutableArray *query = [NSMutableArray arrayWithArray:components.queryItems];
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:name value:value];
        [query addObject:queryItem];
        components.queryItems = query;
    }
    NSURL *newURL = [components URL];
    if (newURL) { return newURL; }
    return self;
}
    
@end
