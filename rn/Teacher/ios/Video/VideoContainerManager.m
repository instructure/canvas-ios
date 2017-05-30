//
//  VideoViewManager.m
//  Teacher
//
//  Created by Derrick Hathaway on 5/22/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Teacher-Swift.h"
#import <React/RCTUIManager.h>

@interface VideoContainerManager : RCTViewManager
@end

@implementation VideoContainerManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [VideoContainerView new];
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary *)
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL)

@end
