//
//  CBIAlwaysPushTransitioningDelegate.m
//  iCanvas
//
//  Created by derrick on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIAlwaysPushTransitioningDelegate.h"

@implementation CBIAlwaysPushTransitioningDelegate
- (void)transitionFromViewController:(UIViewController *)source toViewController:(UIViewController *)destination animated:(BOOL)animated
{
    [source.navigationController pushViewController:destination animated:animated];
}
@end
