//
//  NativeNotificationCenter.m
//  CanvasCore
//
//  Created by Nathan Armstrong on 12/15/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

#import "NativeNotificationCenter.h"

@implementation NativeNotificationCenter

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(postNotification:(NSString *)name userInfo:(NSDictionary *)userInfo)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
