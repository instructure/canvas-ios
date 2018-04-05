//
//  LTITools.m
//  CanvasCore
//
//  Created by Matt Sessions on 3/9/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface LTITools: NSObject<RCTBridgeModule>

@end

@implementation LTITools

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(launchExternalTool, launchExternalTool:(NSString *)url resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *current = [[HelmManager shared] topMostViewController];
    NSURL *launchURL = [[NSURL alloc] initWithString:url];
    Session *session = [CanvasKeymaster theKeymaster].currentClient.authSession;
    
    [[ExternalToolManager shared] launch:launchURL in:session from:current completionHandler:^{
        resolve(nil);
    }];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
