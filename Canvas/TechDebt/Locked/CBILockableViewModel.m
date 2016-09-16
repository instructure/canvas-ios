//
//  CBILockableViewModel.m
//  iCanvas
//
//  Created by derrick on 2/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
