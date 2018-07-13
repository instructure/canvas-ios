//
//  VCRManager.h
//  CanvasCore
//
//  Created by Matt Sessions on 7/2/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface VCR : NSObject <RCTBridgeModule>

+ (instancetype)shared;
- (void)recordResponse:(NSString *)value for:(NSString *)key;
- (NSString *)responseFor:(NSString *)key;
- (void)recordCassette:(NSString *)testSuite completionHandler:(void (^)(NSError *error))completionHandler;
- (void)loadCassette:(NSString *)testSuite completionHandler:(void (^)(NSError *error))completionHandler;

@end
