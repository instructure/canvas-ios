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
