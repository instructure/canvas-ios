//
//  FeatureFlags.m
//  CanvasCore
//
//  Created by Matt Sessions on 3/7/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface FeatureFlagsManager : NSObject <RCTBridgeModule>

@end

@implementation FeatureFlagsManager

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(syncFeatureFlags, syncFeatureFlags:(NSDictionary *) flags exemptDomains:(NSArray *)domains resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    FeatureFlags.featureFlags = flags;
    FeatureFlags.exemptDomains = domains;
    resolve(nil);
};

@end
