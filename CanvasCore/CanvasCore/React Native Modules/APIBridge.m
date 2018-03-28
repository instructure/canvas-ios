//
//  APIBridge.m
//  CanvasCore
//
//  Created by Layne Moseley on 3/27/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import "APIBridge.h"
#import <CanvasCore/CanvasCore-Swift.h>

static APIBridge *_shared = nil;

@interface APIBridge ()

@property (nonatomic) NSMutableDictionary *requests;

@end

@implementation APIBridge

RCT_EXPORT_MODULE();

+ (instancetype)shared {
    return _shared;
}

- (id)init {
    self = [super init];
    self.requests = [NSMutableDictionary new];
    _shared = self;
    return self;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"APICall"];
}

- (void)call:(NSString *)name args:(NSArray *)args callback:(APIBridgeCallback)callback {
    NSString *requestID = [[NSUUID UUID] UUIDString];
    self.requests[requestID] = callback;
    NSDictionary *body = @{ @"requestID": requestID, @"name": name, @"args": args ?: @[]};
    [self sendEventWithName:@"APICall" body:body];
}

RCT_EXPORT_METHOD(requestCompleted:(NSString *)requestID result:(id)result error:(NSString *)errorString) {
    APIBridgeCallback callback = self.requests[requestID];
    if (!callback) {
        NSLog(@"APIBridge: Cannot find callback for request: %@", requestID);
        return;
    }
    
    NSError *error = nil;
    if (errorString) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorString };
        error = [NSError errorWithDomain:@"com.instructure.apibridge" code:0 userInfo:userInfo];
    }
    callback(result, error);
    self.requests[requestID] = nil;
}

@end
