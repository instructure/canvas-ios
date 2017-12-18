//
//  NativeNotificationCenter.m
//  CanvasCore
//
//  Created by Nathan Armstrong on 12/15/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

#import "NativeNotificationCenter.h"

NSString * const AsyncActionNotificationName = @"com.instructure.CanvasCore.AsyncActionNotification";

@implementation NativeNotificationCenter

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(postNotification:(NSString *)name userInfo:(NSDictionary *)userInfo)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
}

RCT_EXPORT_METHOD(postAsyncActionNotification:(NSDictionary *)action)
{
    [self postNotification:AsyncActionNotificationName userInfo:action];
}

- (NSDictionary *)constantsToExport
{
    return @{ @"asyncActionNotification": AsyncActionNotificationName };
}

@end
