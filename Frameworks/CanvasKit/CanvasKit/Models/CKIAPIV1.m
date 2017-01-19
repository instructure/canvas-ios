//
//  CKIAPIV1.m
//  CanvasKit
//
//  Created by derrick on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIAPIV1.h"

@implementation CKIAPIV1
+ (instancetype)context {
    static CKIAPIV1 *apiV1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiV1 = [CKIAPIV1 new];
    });
    return apiV1;
}

- (NSString *)path
{
    return @"/api/v1";
}

- (void)setContext:(id<CKIContext>)context
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id<CKIContext>)context {
    return nil;
}

@end
