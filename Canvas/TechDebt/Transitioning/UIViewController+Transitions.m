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
    
    

#import "UIViewController+Transitions.h"
@import CanvasCore;

@implementation UIViewController (Transitions)

- (void)cbi_transitionToViewController:(UIViewController *)destinationViewController animated:(BOOL)animated
{
    if (self.splitViewController) {
        if (self.splitViewController.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassCompact) {
            UIBarButtonItem *splitThing = self.splitViewController.prettyDisplayModeButtonItem;
            destinationViewController.navigationItem.leftBarButtonItem = splitThing;
            destinationViewController.navigationItem.leftItemsSupplementBackButton = YES;
        }

        if ([self.splitViewController.viewControllers.firstObject isKindOfClass:[UINavigationController class]] && self.splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            [((UINavigationController *)self.splitViewController.viewControllers.firstObject) pushViewController:destinationViewController animated:YES];
        } else if (self.splitViewController.viewControllers.firstObject == self || ([self.splitViewController.viewControllers.firstObject isKindOfClass:[UINavigationController class]] && ((UINavigationController *)self.splitViewController.viewControllers.firstObject).topViewController == self)) {
            // If the presenting view controller is a master list, swap out the detail entirely so as to clear the nav stack
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:destinationViewController];
            [self.splitViewController showDetailViewController:nav sender:nil];
        } else if ([self.splitViewController.viewControllers.lastObject isKindOfClass:[UINavigationController class]] && self.splitViewController.viewControllers.count == 2) {
            [((UINavigationController *)self.splitViewController.viewControllers.lastObject) pushViewController:destinationViewController animated:YES];
        } else {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:destinationViewController];
            [self.splitViewController showDetailViewController:nav sender:nil];
        }
    } else {
        if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
            [self presentViewController:destinationViewController animated:YES completion:nil];
        } else {
            [self.navigationController pushViewController:destinationViewController animated:animated];
        }
    }
}
@end

