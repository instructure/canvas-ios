
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
    
    

#import "NSURL+RemoveFragment.h"

@implementation NSURL (RemoveFragment)

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

@end
