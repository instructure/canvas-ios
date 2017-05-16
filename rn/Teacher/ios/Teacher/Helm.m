//
//  Helm.m
//  Teacher
//
//  Created by Ben Kraus on 4/28/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Helm, NSObject)

RCT_EXTERN_METHOD(setScreenConfig:(NSDictionary *)config forScreenWithID:(NSString *)screenInstanceID hasRendered:(BOOL)hasRendered)
RCT_EXTERN_METHOD(setDefaultScreenConfig:(NSDictionary *)config forModule:(NSString *)module)
RCT_EXTERN_METHOD(pushFrom:(NSString *)sourceModule destinationModule:(NSString*)module withProps:(NSDictionary *)props options:(NSDictionary *)options)
RCT_EXTERN_METHOD(popFrom:(NSString *)sourceModule)
RCT_EXTERN_METHOD(present:(NSString *)module withProps:(NSDictionary *)props options:(NSDictionary *)options)
RCT_EXTERN_METHOD(dismiss:(NSDictionary *)options)
RCT_EXTERN_METHOD(dismissAllModals:(NSDictionary *)options)
RCT_EXTERN_METHOD(traitCollection:(RCTResponseSenderBlock *)callback)

@end
