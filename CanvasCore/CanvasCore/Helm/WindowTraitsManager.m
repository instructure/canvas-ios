//
//  WindowTraitsManager.m
//  CanvasCore
//
//  Created by Layne Moseley on 12/1/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

#import "WindowTraitsManager.h"

@implementation WindowTraitsManager

RCT_EXPORT_MODULE();

- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(traitsUpdated:) name:@"HelmSplitViewControllerTraitsUpdated" object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"Update"];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)traits {
    return @{ @"window": [WindowTraits current] };
}

- (void)traitsUpdated:(NSNotification *)notification {
    [self sendEventWithName:@"Update" body:[self traits]];
}

RCT_EXPORT_METHOD(currentWindowTraits:(RCTResponseSenderBlock)callback) {
    callback(@[[self traits]]);
}

@end
