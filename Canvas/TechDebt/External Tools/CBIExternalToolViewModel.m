//
//  CBIExternalToolViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 3/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIExternalToolViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBIExternalToolViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.name);
        self.icon = [[UIImage techDebtImageNamed:@"icon_application"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

@end
