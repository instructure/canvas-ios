
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
    
    

#import "CKIModule+ModuleProgression.h"

@implementation CKIModule (ModuleProgression)

- (CKIModuleItem *)moduleItemAfterModuleItem:(CKIModuleItem *)moduleItem
{
    NSInteger index = [self.items indexOfObject:moduleItem];

    if (index == NSNotFound) {
        return nil;
    }

    for (NSInteger i = index + 1; i < [self.items count]; i++) {
        if (i >= 0 && i < [self.items count]) {
            CKIModuleItem *item = [self.items objectAtIndex:i];
            if (![item.type isEqualToString:CKIModuleItemTypeSubHeader]) {
                return item;
            }
        }
    }

    return nil;
}

- (CKIModuleItem *)moduleItemBeforeModuleItem:(CKIModuleItem *)moduleItem
{
    NSInteger index = [self.items indexOfObject:moduleItem];

    if (index == NSNotFound) {
        return nil;
    }

    for (NSInteger i = index - 1; i >= 0; i--) {
        if (i >= 0 && i < [self.items count]) {
            CKIModuleItem *item = [self.items objectAtIndex:i];
            if (![item.type isEqualToString:CKIModuleItemTypeSubHeader]) {
                return item;
            }
        }
    }

    return nil;
}

@end
