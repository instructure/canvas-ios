//
//  APIBridge.h
//  CanvasCore
//
//  Created by Layne Moseley on 3/27/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^APIBridgeCallback)(id _Nullable response, NSError * _Nullable error);

@interface APIBridge : RCTEventEmitter

+ (instancetype)shared;
- (void)call:(NSString *)name args:(nullable NSArray *)args callback:(APIBridgeCallback)callback;

@end

NS_ASSUME_NONNULL_END
