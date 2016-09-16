//
//  UIViewController+Transitions.m
//  iCanvas
//
//  Created by derrick on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UIViewController+Transitions.h"
#import "CBISplitViewControllerTransitioningDelegate.h"
#import "CBIAlwaysPushTransitioningDelegate.h"
#import <objc/runtime.h>

@implementation UIViewController (Transitions)

- (id<CBITransitioningDelegate>)cbi_transitioningDelegate
{
    id <CBITransitioningDelegate> delegate = objc_getAssociatedObject(self, @selector(cbi_transitioningDelegate));
    if (delegate == nil) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.cbi_transitioningDelegate = [CBISplitViewControllerTransitioningDelegate new];
        } else {
            self.cbi_transitioningDelegate = [CBIAlwaysPushTransitioningDelegate new];
        }
    }
    return objc_getAssociatedObject(self, @selector(cbi_transitioningDelegate));
}

- (BOOL)cbi_canBecomeMaster
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCbi_canBecomeMaster:(BOOL)canBecomeMaster
{
    return objc_setAssociatedObject(self, @selector(cbi_canBecomeMaster), @(canBecomeMaster), OBJC_ASSOCIATION_RETAIN);
}

- (void)setCbi_transitioningDelegate:(id<CBITransitioningDelegate>)cbiTransitioningDelegate
{
    return objc_setAssociatedObject(self, @selector(cbi_transitioningDelegate), cbiTransitioningDelegate, OBJC_ASSOCIATION_RETAIN);
}

- (void)cbi_transitionToViewController:(UIViewController *)destinationViewController animated:(BOOL)animated
{
    [self.cbi_transitioningDelegate transitionFromViewController:self toViewController:destinationViewController animated:animated];
}
@end
