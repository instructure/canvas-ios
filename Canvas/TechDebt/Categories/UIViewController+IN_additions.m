//
//  UIViewController+IN_additions.m
//  iCanvas
//
//  Created by BJ Homer on 11/2/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "UIViewController+IN_additions.h"

@implementation UIViewController (IN_additions)

- (void)presentViewController:(UIViewController *)viewControllerToPresent inNavigationControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
    [self presentViewController:navController animated:flag completion:completion];
}

@end

@implementation ModalNavigationSegue

- (void)perform {
    [self.sourceViewController presentViewController:self.destinationViewController
                      inNavigationControllerAnimated:YES
                                          completion:NULL];
}

@end