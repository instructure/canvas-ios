//
//  UIViewController+IN_additions.h
//  iCanvas
//
//  Created by BJ Homer on 11/2/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (IN_additions)

- (void)presentViewController:(UIViewController *)viewControllerToPresent inNavigationControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end


@interface ModalNavigationSegue : UIStoryboardSegue
@end