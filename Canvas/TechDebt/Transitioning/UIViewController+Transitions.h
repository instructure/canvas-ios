//
//  UIViewController+Transitions.h
//  iCanvas
//
//  Created by derrick on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBITransitioningDelegate <NSObject>
- (void)transitionFromViewController:(UIViewController *)source toViewController:(UIViewController *)destination animated:(BOOL)animated;
@end

@interface UIViewController (Transitions)

@property (nonatomic) BOOL cbi_canBecomeMaster;

@property (nonatomic) id<CBITransitioningDelegate> cbi_transitioningDelegate;

- (void)cbi_transitionToViewController:(UIViewController *)destinationViewController animated:(BOOL)animated;

@end
