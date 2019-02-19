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
    
    

#import "UITableView+in_fix10550644.h"


@implementation UITableView (in_fix10550644)

- (id)in_dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        NSDictionary *nibDictionary = [self valueForKey:@"_nibMap"];
        UINib *nib = nibDictionary[identifier];
        
        NSDictionary *externals = [self valueForKey:@"_nibExternalObjectsTables"];
        NSDictionary *externalsForIdentifier = externals[identifier];
        
        NSDictionary *options = nil;
        if (externalsForIdentifier != nil) {
            options = @{UINibExternalObjects: externalsForIdentifier};
            cell = [nib instantiateWithOwner:self options:options][0];
        }
    }
    return cell;
}

@end
