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

