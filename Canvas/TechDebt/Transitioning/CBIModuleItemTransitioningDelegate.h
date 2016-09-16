//
//  CBIModuleItemTransitioningDelegate.h
//  iCanvas
//
//  Created by Nathan Armstrong on 1/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+Transitions.h"

@interface CBIModuleItemTransitioningDelegate : NSObject <CBITransitioningDelegate>

- (instancetype)initWithTransitioningDelegate:(id<CBITransitioningDelegate>)transitioningDelegate;

@end
