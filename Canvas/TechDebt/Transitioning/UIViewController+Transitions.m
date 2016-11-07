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
