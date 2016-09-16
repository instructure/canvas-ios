//
//  CBISplitViewControllerTransitioningDelegate.m
//  iCanvas
//
//  Created by derrick on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBISplitViewControllerTransitioningDelegate.h"
#import "CBISplitViewController.h"
@import MyLittleViewController;

@interface CBISplitViewControllerTransitioningDelegate () <UINavigationControllerDelegate>
@end

@implementation CBISplitViewControllerTransitioningDelegate
- (void)transitionFromViewController:(UIViewController *)source toViewController:(UIViewController *)destination animated:(BOOL)animated
{
    UIViewController *masterOrDetail = source;
    CBISplitViewController *split = (CBISplitViewController *)source.parentViewController;
    
    while (split && ![split isKindOfClass:[CBISplitViewController class]]) {
        masterOrDetail = split;
        split = (CBISplitViewController *)split.parentViewController;
    }
    
    if (split == nil && destination.cbi_canBecomeMaster){
        CBISplitViewController *nextSplit = [CBISplitViewController new];
        nextSplit.master = destination;
        [source.navigationController pushViewController:nextSplit animated:animated];
    } else if (split == nil){
        [source.navigationController pushViewController:destination animated:animated];
    } else if (split.master == masterOrDetail) {
        split.detail = destination;
    } else if (split.detail == masterOrDetail) {
        
        if(masterOrDetail.cbi_canBecomeMaster){
            [split pushNextDetailViewController:destination animated:animated];
        }
        else if(destination.cbi_canBecomeMaster) {
            CBISplitViewController *nextSplit = [CBISplitViewController new];
            nextSplit.master = destination;
            [source.navigationController pushViewController:nextSplit animated:animated];
        }
        else {
            [split.navigationController pushViewController:destination animated:animated];
        }
    }
}
@end

