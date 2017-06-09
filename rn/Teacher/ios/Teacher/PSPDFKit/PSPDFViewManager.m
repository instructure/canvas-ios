//
//  PSPDFViewManager.m
//  Teacher
//
//  Created by Ben Kraus on 5/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Teacher-Swift.h"
#import <React/RCTUIManager.h>

@interface PSPDFViewManager : RCTViewManager
@end

@implementation PSPDFViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [PSPDFView new];
}

RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary *)

@end
