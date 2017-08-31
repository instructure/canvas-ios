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
    
    

#import "CBILockableViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBILockableViewModel
@dynamic model;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, icon) = [RACSignal combineLatest:@[RACObserve(self, model.lockedForUser), RACObserve(self, unlockedIcon)] reduce:^id(NSNumber *lockedForUser, UIImage *unlockedImage){
            if ([lockedForUser boolValue]) {
                return [[UIImage techDebtImageNamed:@"icon_locked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            return unlockedImage;
        }];
    }
    return self;
}

@end
