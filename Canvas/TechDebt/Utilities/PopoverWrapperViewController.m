//
//  PopoverWrapperViewController.m
//  iCanvas
//
//  Created by BJ Homer on 4/27/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "PopoverWrapperViewController.h"

@interface PopoverWrapperViewController ()

@end

@implementation PopoverWrapperViewController {
    UIView *wrappedView;
}

- (id)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        wrappedView = view;
    }
    return self;
}

- (void)loadView {
    self.view = wrappedView;
    self.preferredContentSize = self.view.bounds.size;
}


@end
