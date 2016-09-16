//
//  CBIPageViewModel.m
//  iCanvas
//
//  Created by rroberts on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIPageViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"

@implementation CBIPageViewModel

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, lockedItemName) = RACObserve(self, model.title);
        RAC(self, viewControllerTitle) = RACObserve(self, model.title);
        RAC(self, frontPage, @NO) = RACObserve(self, model.frontPage);
    }
    return self;
}

@end
