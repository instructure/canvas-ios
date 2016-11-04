
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
    
    

#import "CBIModuleItemTransitioningDelegate.h"
#import "CBIModuleProgressionViewController.h"
#import "CBIModuleViewModel.h"
@import MyLittleViewController;

#pragma mark - CBIModuleProgressionTransitioningDelegate

/**
 Used privately for transitioning between view controllers within the CBIModuleProgressionViewController.
 */
@interface CBIModuleProgressionTransitioningDelegate : NSObject <CBITransitioningDelegate>

@end

@implementation CBIModuleProgressionTransitioningDelegate

- (void)transitionFromViewController:(UIViewController *)source toViewController:(UIViewController *)destination animated:(BOOL)animated
{
    CBIModuleProgressionViewController *progressionViewController = (CBIModuleProgressionViewController *)source;
    [progressionViewController embedChildViewController:destination];
}

@end

#pragma mark - CBIModuleItemTransitioningDelegate


@interface CBIModuleItemTransitioningDelegate ()

@property (nonatomic, strong) id<CBITransitioningDelegate> transitioningDelegate;

@end

@implementation CBIModuleItemTransitioningDelegate

- (instancetype)initWithTransitioningDelegate:(id<CBITransitioningDelegate>)transitioningDelegate
{
    self = [super init];
    self.transitioningDelegate = transitioningDelegate;
    return self;
}

/**
 @param source should be a MLVCTableViewController with a viewModel of class `CBIModuleViewModel`
 */
- (void)transitionFromViewController:(UIViewController *)source toViewController:(UIViewController *)destination animated:(BOOL)animated
{
    // do not embed prerequisite modules
    if ([destination isKindOfClass:[MLVCTableViewController class]]) {
        if ([((MLVCTableViewController *)destination).viewModel isKindOfClass:[CBIModuleViewModel class]]) {
            [self.transitioningDelegate transitionFromViewController:source toViewController:destination animated:animated];
            return;
        }
    }

    CBIModuleItemViewModel *itemViewModel = (CBIModuleItemViewModel *)((MLVCTableViewController *)destination).viewModel;

    CBIModuleProgressionViewController *progressionViewController = [[UIStoryboard storyboardWithName:@"CBIModuleProgression" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    [progressionViewController setModuleItemViewModel:itemViewModel];
    progressionViewController.cbi_transitioningDelegate = [CBIModuleProgressionTransitioningDelegate new];

    [self.transitioningDelegate transitionFromViewController:source toViewController:progressionViewController animated:animated];
}

@end
