//
//  CanvadocViewManager.m
//  Teacher
//
//  Created by Ben Kraus on 5/30/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Teacher-Swift.h"
#import <React/RCTUIManager.h>

@interface CanvadocViewManager : RCTViewManager
@end

@implementation CanvadocViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [CanvadocView new];
}

RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary *)

@end
