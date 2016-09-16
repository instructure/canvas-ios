//
//  CBIModuleProgressionViewController.h
//  iCanvas
//
//  Created by Nathan Armstrong on 1/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBIModuleViewModel;
@class CBIModuleItemViewModel;
@class CBIModuleProgressionViewController;

@interface CBIModuleProgressionViewController : UIViewController

@property (nonatomic, strong) CBIModuleItemViewModel *moduleItemViewModel;

- (void)embedChildViewController:(UIViewController *)childViewController;

@end
